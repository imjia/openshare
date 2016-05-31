//
//  OpenShareConfig.h
//  SudiyiClient
//
//  Created by jia on 16/5/18.
//  Copyright © 2016年 Sudiyi. All rights reserved.
//

#import <Foundation/Foundation.h>

// 分享支持的平台
typedef NS_ENUM(NSInteger, OSPlatformCode) {
    kOSPlatformCommon,
    kOSPlatformQQ,
    kOSPlatformQQZone,
    kOSPlatformWXTimeLine,
    kOSPlatformWXSession,
    kOSPlatformSina,
    kOSPlatformSms,
    kOSPlatformEmail,
};

typedef NS_ENUM(NSInteger, OSShareState) {
    kOSStateNotInstalled,
    kOSStateSuccess,
    kOSStateFail,
};

extern NSString *const kOSQQIdentifier;
extern NSString *const kOSWeixinIdentifier;
extern NSString *const kOSSinaIdentifier;

extern NSString *const kOSErrorDomainSms;
extern NSString *const kOSErrorDomainQQ;
extern NSString *const kOSErrorDomainWeixin;
extern NSString *const kOSErrorDomainSina;
extern NSString *const kOSErrorDomainEmail;

extern NSString *const kOSQQScheme;
extern NSString *const kOSWeixinScheme;
extern NSString *const kOSSinaScheme;


@interface OpenShareConfig : NSObject

@end
