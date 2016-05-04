//
//  OpenShare+SinaWeibo.m
//  OpenShare_2
//
//  Created by jia on 16/3/23.
//  Copyright © 2016年 Jia. All rights reserved.
//

#import "OpenShare+SinaWeibo.h"
#import "OSSinaParameter.h"

NSString *const kSinaWbScheme = @"SinaWeibo";

@implementation OpenShare (SinaWeibo)

+ (BOOL)isSinaWeiboInstalled
{
    return [self canOpenURL:[NSURL URLWithString:@"weibosdk://request"]];
}

+ (void)registSinaWeiboWithAppKey:(NSString *)appKey
{
    [self registAppWithScheme:kSinaWbScheme
                         data:@{@"appKey": appKey}];
}

+ (void)shareToSinaWeibo:(OSMessage *)msg completion:(OSShareCompletionHandle)completionHandle
{
    if ([self isAppRegisted:kSinaWbScheme]) {
        [self openAppWithURL:[self sinaUrlWithMessage:msg] completionHandle:completionHandle];
    }
}

+ (NSURL *)sinaUrlWithMessage:(OSMessage *)msg
{
    OSSinaParameter *sinaParam = [[OSSinaParameter alloc] init];
    OSDataItem *data = msg.dataItem;
    
    switch (msg.multimediaType) {
        case OSMultimediaTypeText: {
            sinaParam.__class = @"WBMessageObject";
            sinaParam.text = data.title;
            break;
        }
        case OSMultimediaTypeImage: {
            sinaParam.__class = @"WBMessageObject";
            sinaParam.text = data.title;
            if (nil != data.imageData) {
                sinaParam.imageObject = @{@"imageData": data.imageData};
            }
            break;
        }
        case OSMultimediaTypeNews: {

            OSSinaMediaObject *mediaObj = [[OSSinaMediaObject alloc] init];
            mediaObj.__class = @"WBWebpageObject";
            mediaObj.objectID = @"identifier1";
            mediaObj.title = data.title;
            mediaObj.desc = data.desc;
            mediaObj.thumbnailData = data.thumbnailData;
            mediaObj.webpageUrl = data.link;
        
            sinaParam.__class = @"WBMessageObject";
            sinaParam.mediaObject = mediaObj;
            
            break;
        }
        default:
            break;
    }
    
    OSSinaTransferObject *tfObj = [[OSSinaTransferObject alloc] init];
    tfObj.__class = @"WBSendMessageToWeiboRequest";
    tfObj.message = sinaParam.tc_dictionary;
    tfObj.requestID = TCAppInfo.uuidForDevice;
    
    NSString *appId = msg.appItem.appId;
    if (nil == appId) {
        appId = [self dataForRegistedScheme:kSinaWbScheme][@"appKey"];
    }
    
    OSSinaApp *app = [[OSSinaApp alloc] init];
    app.appKey = appId;
    app.bundleID = TCAppInfo.bundleIdentifier;
    
    NSData *transferObjectData = [NSKeyedArchiver archivedDataWithRootObject:tfObj.tc_dictionary];
    NSData *appData = [NSKeyedArchiver archivedDataWithRootObject:app.tc_dictionary];
    [UIPasteboard generalPasteboard].items = @[@{@"transferObject": transferObjectData},
                                               @{@"userInfo": [NSKeyedArchiver archivedDataWithRootObject:@{}]},
                                               @{@"app": appData}];

    return [NSURL URLWithString:[NSString stringWithFormat:@"weibosdk://request?id=%@&sdkversion=003013000", TCAppInfo.uuidForDevice]];
}

+ (BOOL)SinaWeibo_handleOpenURL:(NSURL *)url
{
    BOOL canHandle = [url.scheme hasPrefix:@"wb"];
    if (canHandle) {
        NSArray *items = [UIPasteboard generalPasteboard].items;
        NSMutableDictionary *responseDic = [NSMutableDictionary dictionaryWithCapacity:items.count];
        for (NSDictionary *item in items) {
            for (NSString *key in item) {
                responseDic[key] = [key isEqualToString:@"sdkVersion"] ? [[NSString alloc] initWithData:item[key] encoding:NSUTF8StringEncoding] : [NSKeyedUnarchiver unarchiveObjectWithData:item[key]];
            }
        }
        // 清空微博存的数据
        [UIPasteboard generalPasteboard].items = @[];
        
        OSSinaResponse *response = [OSSinaResponse tc_mappingWithDictionary:responseDic];
        if (response.isAuth) {
            //auth
        }else if (response.isShare) {
            //分享回调
            OSShareCompletionHandle handle = self.shareCompletionHandle;
            if (nil != handle) {
                handle(response.error);
                handle = nil;
            }
        }
    }
    
    return canHandle;
}

@end
