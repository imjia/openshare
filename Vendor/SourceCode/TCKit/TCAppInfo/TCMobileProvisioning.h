//
//  TCMobileProvisioning.h
//  TCKit
//
//  Created by dake on 16/2/23.
//  Copyright © 2016年 dake. All rights reserved.
//

#if !TARGET_IPHONE_SIMULATOR && \
(defined(__TCKit__) && !defined(TC_IOS_PUBLISH)) || (!defined(__TCKit__) && defined(DEBUG))

#import <Foundation/Foundation.h>

// code from: https://github.com/leverdeterre/iAppInfos

typedef NS_ENUM(NSInteger, TCMobileProvisionningPushConfiguration) {
    TCMobileProvisionningPushConfigurationDisable,
    TCMobileProvisionningPushConfigurationDevelopment,
    TCMobileProvisionningPushConfigurationProduction
};

@interface TCMobileProvisioning : NSObject

@property (nonatomic, copy) NSString *Name;
@property (nonatomic, copy) NSString *TeamName;
@property (nonatomic, copy) NSString *AppIDName;
@property (nonatomic, copy) NSString *apsEnvironment;
@property (nonatomic, assign) BOOL developProvisioning;

@property (nonatomic, strong) NSArray<NSString *> *ApplicationIdentifierPrefix;
@property (nonatomic, strong) NSArray<NSString *> *keychainAccessGroups;
@property (nonatomic, strong) NSArray<NSString *> *ProvisionedDevices; // udid

@property (nonatomic, strong) NSDate *CreationDate;
@property (nonatomic, strong) NSDate *ExpirationDate;

- (TCMobileProvisionningPushConfiguration)pushConfiguration;


+ (instancetype)defaultMobileProvisioning;

@end

#endif


