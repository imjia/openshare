//
//  TCAppInfo.m
//  TCKit
//
//  Created by dake on 13-4-15.
//  Copyright (c) 2013年 dake. All rights reserved.
//

#import "TCAppInfo.h"
#import <mach/mach.h>
#import <mach/mach_time.h>
#import <UIKit/UIApplication.h>
#import "FCUUID.h"

#define DEFAULT_PLIST_FOR_KEY(key)      ([[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)(key)] ?: @"")


static NSString *const kTCMigrationLastVersionKey = @"lastMigrationVersion.TCMigration.TCKit";
static NSString *const kTCMigrationLastBuildKey = @"lastMigrationBuild.TCMigration.TCKit";

static NSString *const kTCMigrationLastAppVersionKey = @"lastAppVersion.TCMigration.TCKit";
static NSString *const kTCMigrationLastAppBuildKey = @"lastAppBuild.TCMigration.TCKit";

NSString *const kTCApplicationDidReceiveDiskSpaceWarning = @"TCApplicationDidReceiveDiskSpaceWarning.TCKit";


@implementation TCAppInfo

+ (void)initialize
{
    void (^block)(NSNotification *note) = ^(NSNotification * _Nonnull note) {
        NSDictionary *fattributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:NULL];
        NSNumber *size = [fattributes objectForKey:NSFileSystemFreeSize];
        if (nil != size && size.unsignedLongLongValue < 500e6) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kTCApplicationDidReceiveDiskSpaceWarning object:size];
        }
    };
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidFinishLaunchingNotification object:nil queue:nil usingBlock:block];
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillEnterForegroundNotification object:nil queue:nil usingBlock:block];
}

+ (NSString *)appVersion:(TCMigrationVersionType)type
{
    if (TCMigrationShortVersion == type) {
        return DEFAULT_PLIST_FOR_KEY(@"CFBundleShortVersionString");
    } else if (TCMigrationBuildVersion == type) {
        return DEFAULT_PLIST_FOR_KEY(kCFBundleVersionKey);
    }
    
    return @"";
}

+ (NSString *)bundleName
{
    return DEFAULT_PLIST_FOR_KEY(kCFBundleNameKey);
}

+ (NSString *)displayName
{
    return DEFAULT_PLIST_FOR_KEY(@"CFBundleDisplayName");
}

+ (NSString *)bundleIdentifier
{
    return DEFAULT_PLIST_FOR_KEY(@"CFBundleIdentifier");
}

+ (NSString *)uuidForDevice
{
    return FCUUID.uuidForDevice ?: @"";
}


#pragma mark - TCMigration

+ (void)migrateToVersion:(NSString *)version type:(TCMigrationVersionType)type domain:(NSString *)domain block:(dispatch_block_t)block
{
    NSParameterAssert(version);
    NSParameterAssert(block);
    
    if (nil == version || nil == block) {
        return;
    }
    
    if (nil == domain) {
        domain = @"default";
    }
    
    // version > lastMigrationVersion && version <= appVersion
    if ([version compare:[self lastMigrationVersion:type domain:domain] options:NSNumericSearch] == NSOrderedDescending &&
        [version compare:[self appVersion:type] options:NSNumericSearch] != NSOrderedDescending) {
        block();
        [self setLastMigrationVersion:version type:type domain:domain];
    }
}

+ (void)migrateResetDomain:(NSString *)domain type:(TCMigrationVersionType)type
{
    if (nil == domain) {
        domain = @"default";
    }
    
    [self setLastMigrationVersion:nil type:type domain:domain];
}

+ (BOOL)migratedVersion:(NSString *)version type:(TCMigrationVersionType)type domain:(NSString *)domain
{
    NSParameterAssert(version);
    if (nil == version) {
        return YES;
    }
    
    if (nil == domain) {
        domain = @"default";
    }
    
    NSString *ver = [self lastMigrationVersion:type domain:domain];
    return ver.length < 1 ? NO : [ver compare:version options:NSNumericSearch] != NSOrderedAscending;
}

+ (void)applicationUpdateBlock:(dispatch_block_t)block type:(TCMigrationVersionType)type domain:(NSString *)domain
{
    NSParameterAssert(block);
    
    if (nil == block) {
        return;
    }
    
    if (nil == domain) {
        domain = @"default";
    }
    
    NSString *version = [self appVersion:type];
    if (![[self lastUpdateVersionForType:type domain:domain] isEqualToString:version]) {
        block();
        [self setLastUpdateVersion:version type:type domain:domain];
    }
}

+ (void)updateResetDomain:(NSString *)domain type:(TCMigrationVersionType)type
{
    if (nil == domain) {
        domain = @"default";
    }
    
    [self setLastUpdateVersion:nil type:type domain:domain];
}

+ (BOOL)updatedVersion:(TCMigrationVersionType)type domain:(NSString *)domain
{
    if (nil == domain) {
        domain = @"default";
    }
    
    NSString *ver = [self lastUpdateVersionForType:type domain:domain];
    
    return ver.length < 1 ? NO : [ver isEqualToString:[self appVersion:type]];
}


// migrate version

+ (NSString *)versionMigrationKeyForType:(TCMigrationVersionType)type domain:(NSString *)domain
{
    NSString *rootKey = nil;
    if (TCMigrationShortVersion == type) {
        rootKey = kTCMigrationLastVersionKey;
    } else if (TCMigrationBuildVersion == type) {
        rootKey = kTCMigrationLastBuildKey;
    } else {
        rootKey = kTCMigrationLastBuildKey;
    }
    
    return [domain stringByAppendingFormat:@".%@", rootKey];
}

+ (NSString *)lastMigrationVersion:(TCMigrationVersionType)type domain:(NSString *)domain
{
    NSString *res = [[NSUserDefaults standardUserDefaults] valueForKey:[self versionMigrationKeyForType:type domain:domain]];
    return res ?: @"";
}

+ (void)setLastMigrationVersion:(NSString *)version type:(TCMigrationVersionType)type domain:(NSString *)domain
{
    [[NSUserDefaults standardUserDefaults] setValue:version forKey:[self versionMigrationKeyForType:type domain:domain]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


// update vesion

+ (NSString *)versionUpdateKeyForType:(TCMigrationVersionType)type domain:(NSString *)domain
{
    NSString *rootKey = nil;
    if (TCMigrationShortVersion == type) {
        rootKey = kTCMigrationLastAppVersionKey;
    } else if (TCMigrationBuildVersion == type) {
        rootKey = kTCMigrationLastAppBuildKey;
    } else {
        rootKey = kTCMigrationLastAppBuildKey;
    }
    
    return [domain stringByAppendingFormat:@".%@", rootKey];
}

+ (NSString *)lastUpdateVersionForType:(TCMigrationVersionType)type domain:(NSString *)domain
{
    NSString *res = [[NSUserDefaults standardUserDefaults] valueForKey:[self versionUpdateKeyForType:type domain:domain]];
    return res ?: @"";
}

+ (void)setLastUpdateVersion:(NSString *)version type:(TCMigrationVersionType)type domain:(NSString *)domain
{
    [[NSUserDefaults standardUserDefaults] setValue:version forKey:[self versionUpdateKeyForType:type domain:domain]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}



@end
