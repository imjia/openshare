//
//  OpenShareConfig.h
//  OpenShare_2
//
//  Created by chenhuanhuan on 16/5/4.
//  Copyright © 2016年 Jia. All rights reserved.
//

#ifndef OpenShareConfig_h
#define OpenShareConfig_h

// 分享支持的平台
typedef NS_ENUM(NSInteger, OSApp) {
    kOSAppQQ,
    kOSAppQQZone,
    kOSAppWXTimeLine,
    kOSAppWXSession,
    kOSAppSina,
    kOSAppSms,
    kOSAppEmail,
};

typedef NS_ENUM(NSInteger, OSShareState) {
    kOSStateNotInstalled,
    kOSStateSuccess,
    kOSStateFail,
};

static NSString *const kErrorDomainSms = @"response_from_sms";
static NSString *const kErrorDomainQQ = @"response_from_qq";
static NSString *const kErrorDomainWeixin = @"response_from_weixin";
static NSString *const kErrorDomainSina = @"response_from_sina";
static NSString *const kErrorDomainEmail = @"response_from_email";


#endif /* OpenShareConfig_h */
