//
//  OpenShare+SinaWeibo.m
//  OpenShare_2
//
//  Created by jia on 16/3/23.
//  Copyright © 2016年 Jia. All rights reserved.
//

#import "OpenShare+SinaWeibo.h"
#import "OSSinaParameter.h"
#import "NSObject+TCDictionaryMapping.h"

@implementation OpenShare (SinaWeibo)

+ (BOOL)isSinaWeiboInstalled
{
    return [self canOpenURL:[NSURL URLWithString:kOSSinaScheme]];
}

+ (void)registSinaWeiboWithAppKey:(NSString *)appKey
{
    [self registAppWithName:kOSSinaIdentifier
                       data:@{@"appKey": appKey}];
}

+ (void)shareToSinaWeibo:(OSMessage *)msg
{
    if ([self isAppRegisted:kOSSinaIdentifier]) {
        [self openAppWithURL:[self sinaUrlWithMessage:msg]];
    }
}

+ (NSURL *)sinaUrlWithMessage:(OSMessage *)msg
{
    OSSinaParameter *sinaParam = [[OSSinaParameter alloc] init];
    OSDataItem *data = msg.dataItem;
    data.platformCode = kOSPlatformSina;
    
    sinaParam.__class = @"WBMessageObject";
    sinaParam.text = data.sinaContent;
    if (nil != data.imageData) {
        sinaParam.imageObject = @{@"imageData": data.imageData};
    }
    
    OSSinaTransferObject *tfObj = [[OSSinaTransferObject alloc] init];
    tfObj.__class = @"WBSendMessageToWeiboRequest";
    tfObj.message = sinaParam.tc_dictionary;
    tfObj.requestID = TCAppInfo.uuidForDevice;
    
    OSPlatformAccount *account = [msg accountForApp:kOSSinaIdentifier];
    NSString *appId = account.appId;
    if (nil == appId) {
        appId = [self dataForRegistedApp:kOSSinaIdentifier][@"appKey"];
    }
    
    OSSinaApp *app = [[OSSinaApp alloc] init];
    app.appKey = appId;
    app.bundleID = TCAppInfo.bundleIdentifier;
    
    NSData *transferObjectData = [NSKeyedArchiver archivedDataWithRootObject:tfObj.tc_dictionary];
    NSData *appData = [NSKeyedArchiver archivedDataWithRootObject:app.tc_dictionary];

    NSMutableArray *pbItems = [NSMutableArray array];
    if (nil != transferObjectData) {
        [pbItems addObject:@{PropertySTR(transferObject): transferObjectData}];
    }
    if (nil != appData) {
        [pbItems addObject:@{PropertySTR(app): appData}];
    }
    [pbItems addObject:@{PropertySTR(userInfo): [NSKeyedArchiver archivedDataWithRootObject:@{}]}];
    
    [UIPasteboard generalPasteboard].items = pbItems;
    
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@request?id=%@&sdkversion=003013000", kOSSinaScheme, TCAppInfo.uuidForDevice]];
}

+ (BOOL)wb_handleOpenURL:(NSURL *)url
{
    BOOL canHandle = [url.scheme hasPrefix:kOSSinaIdentifier];
    if (!canHandle) {
        return NO;
    }
    
    NSMutableDictionary *responseDic = nil;
    @try {
        NSArray *items = [UIPasteboard generalPasteboard].items;
        NSMutableDictionary *responseDic = [NSMutableDictionary dictionaryWithCapacity:items.count];
        
        for (NSDictionary *item in items) {
            for (NSString *key in item) {
                responseDic[key] = [key isEqualToString:@"sdkVersion"] ? [[NSString alloc] initWithData:item[key] encoding:NSUTF8StringEncoding] : [NSKeyedUnarchiver unarchiveObjectWithData:item[key]];
            }
        }
        
    } @catch (NSException *exception) {
        DLog_e(@"%@", exception);
        responseDic = nil;
        
    } @finally {
        // 清空微博存的数据
        [UIPasteboard generalPasteboard].items = @[];
        if ([url.absoluteString rangeOfString:self.identifier].location == NSNotFound) {
            return canHandle;
        }
        self.identifier = nil;
        
        if (responseDic.count > 0) {
            OSSinaResponse *response = [OSSinaResponse tc_mappingWithDictionary:responseDic];
            if (response.isAuth) {
                // auth
            } else if (response.isShare) {
                // 分享回调
                [[NSNotificationCenter defaultCenter] postNotificationName:kOSShareFinishedNotification object:response];
            }
        }
        
        return canHandle;
    }
}

@end
