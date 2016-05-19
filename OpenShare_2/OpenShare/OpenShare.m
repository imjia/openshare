//
//  OpenShare.m
//  OpenShare_2
//
//  Created by jia on 16/3/21.
//  Copyright © 2016年 Jia. All rights reserved.
//

#import "OpenShare.h"

NSString *const kOSShareFinishedNotification = @"kOSShareFinishedNotification";

@interface OpenShare ()

@end

@implementation OpenShare
static NSString *s_identifier = nil;

+ (NSString *)identifier
{
    return s_identifier;
}

+ (void)setIdentifier:(NSString *)identifier
{
    s_identifier = identifier;
}

static NSMutableDictionary *s_registedApps = nil;
+ (NSMutableDictionary *)registedApps
{
    if (nil == s_registedApps) {
        s_registedApps = [NSMutableDictionary dictionary];
    }
    return s_registedApps;
}

+ (void)registAppWithName:(NSString *)appName data:(NSDictionary *)data
{
    if (nil == self.registedApps[appName]) {
        self.registedApps[appName] = data;
    }
}

+ (NSDictionary *)dataForRegistedApp:(NSString *)appName
{
    return self.registedApps[appName];
}

+ (BOOL)shouldOpenApp:(NSString *)appName
{
    if ([self isAppRegisted:appName]) {
        return YES;
    }
    return NO;
}

+ (BOOL)isAppRegisted:(NSString *)appName
{
    return nil != self.registedApps[appName];
}

+ (BOOL)canOpenURL:(NSURL *)url
{
    return [[UIApplication sharedApplication] canOpenURL:url];
}

+ (BOOL)openAppWithURL:(NSURL *)url
{
    NSParameterAssert(url);
    if (nil == url) {
        return NO;
    }
    
    [self updateIdentifierWithUrl:url.absoluteString];
    
    return [[UIApplication sharedApplication] openURL:url];
}

+ (void)updateIdentifierWithUrl:(NSString *)urlStr
{
    NSString *identifier = nil;
    if ([urlStr hasPrefix:kOSQQScheme]) {
        identifier = @"QQ";
    } else if ([urlStr hasPrefix:kOSWeixinScheme]) {
        identifier = @"wx";
    } else if ([urlStr hasPrefix:kOSSinaScheme]) {
        identifier = @"wb";
    }
    
    self.identifier = identifier;
}

+ (void)setGeneralPasteboardData:(NSDictionary *)value forKey:(NSString *)key encoding:(OSPasteboardEncoding)encoding
{
    if (nil != value && nil != key) {
        NSData *data = nil;
        @try {
            NSError *err = nil;
            switch (encoding) {
                case kOSPasteboardEncodingKeyedArchiver: {
                    data = [NSKeyedArchiver archivedDataWithRootObject:value];
                    break;
                }
                case kOSPasteboardEncodingPropertyListSerialization: {
                    data = [NSPropertyListSerialization dataWithPropertyList:value
                                                                      format:NSPropertyListBinaryFormat_v1_0
                                                                     options:kNilOptions
                                                                       error:&err];
                    break;
                }
                default:
                    DLog(@"encoding not implemented");
                    break;
            }
            
            if (nil != err) {
                DLog(@"error when NSPropertyListSerialization: %@",err);
            }
        } @catch (NSException *exception) {
            DLog_e(@"%@", exception);
            data = nil;
        } @finally {
            if (nil != data) {
                [[UIPasteboard generalPasteboard] setData:data forPasteboardType:key];
            }
        }
    }
}

+ (NSDictionary *)generalPasteboardDataForKey:(NSString *)key encoding:(OSPasteboardEncoding)encoding
{
    NSData *data = [[UIPasteboard generalPasteboard] dataForPasteboardType:key];
    if (nil == data) {
        return nil;
    }
    NSDictionary *dic = nil;
    
    @try {
        NSError *err = nil;
        switch (encoding) {
            case kOSPasteboardEncodingKeyedArchiver: {
                dic = [NSKeyedUnarchiver unarchiveObjectWithData:data];
                break;
            }
            case kOSPasteboardEncodingPropertyListSerialization: {
                dic = [NSPropertyListSerialization propertyListWithData:data
                                                                options:kNilOptions
                                                                 format:NULL
                                                                  error:&err];
                break;
            }
            default:
                break;
        }
        if (nil != err) {
            DLog(@"error when NSPropertyListSerialization: %@",err);
        }
    } @catch (NSException *exception) {
        DLog_e(@"%@", exception);
        dic = nil;
        
    } @finally {
        return dic;
    }
}

+ (void)clearGeneralPasteboardDataForKey:(NSString *)key
{
    if (nil != key) {
        [[UIPasteboard generalPasteboard] setValue:@"" forPasteboardType:key];
    }
}

+ (BOOL)handleOpenURL:(NSURL *)url
{
    if (nil == self.identifier) {
        return YES;
    }
    
    for (NSString *appName in s_registedApps) {
        SEL sel = NSSelectorFromString([appName stringByAppendingString:@"_handleOpenURL:"]);
        if ([self respondsToSelector:sel]) {
            
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:
                                        [self methodSignatureForSelector:sel]];
            invocation.selector = sel;
            invocation.target = self;
            [invocation setArgument:&url atIndex:2]; // 这里设置参数的Index 需要从2开始，因为前两个被selector和target占用
            [invocation invoke];
            
            BOOL returnValue = NO;
            [invocation getReturnValue:&returnValue];
            if (returnValue) { // 如果这个url能处理，就返回YES，否则，交给下一个处理。
                return YES;
            }
        } else{
            DLog(@"fatal error: %@ is should have a method: %@", appName, [appName stringByAppendingString:@"_handleOpenURL"]);
        }
    }
    return NO;
}

@end

