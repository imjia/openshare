//
//  OpenShareConfig.h
//  OpenShare_2
//
//  Created by chenhuanhuan on 16/5/4.
//  Copyright © 2016年 Jia. All rights reserved.
//

#ifndef OpenShareConfig_h
#define OpenShareConfig_h

typedef NS_ENUM(NSInteger, OSAPP) {
    kOSAppQQ,
    kOSAppWeixin,
    kOSAppSina,
};

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

//#define kOSPlatformCommon @"common"
//#define kOSPlatformQQ @"qq"
//#define kOSPlatformQQZone @"qzone"
//#define kOSPlatformWXTimeLine @"wxtimeline"
//#define kOSPlatformWXSession @"wxsession"
//#define kOSPlatformSina @"sina"
//#define kOSPlatformSms @"sms"
//#define kOSPlatformEmail @"email"

#define kOSErrorDomainSms @"response_from_sms"
#define kOSErrorDomainQQ @"response_from_qq"
#define kOSErrorDomainWeixin @"response_from_weixin"
#define kOSErrorDomainSina @"response_from_sina"
#define kOSErrorDomainEmail @"response_from_email"

#define kOSQQURL @"mqqapi://"
#define kOSWeixinURL @"weixin://"
#define kOSSinaURL @"weibosdk://request"


#endif /* OpenShareConfig_h */
