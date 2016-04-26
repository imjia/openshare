//
//  OpenShare+SinaWeibo.m
//  OpenShare_2
//
//  Created by jia on 16/3/23.
//  Copyright © 2016年 Jia. All rights reserved.
//

#import "OpenShare+SinaWeibo.h"

static NSString *const kSinaWbScheme = @"SinaWeibo";

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
    if ([self shouldOpenApp:kSinaWbScheme message:msg completionHandle:completionHandle]) {
        [self openAppWithURL:[self sinaUrlWithMessage:msg]];
    }
}

+ (NSURL *)sinaUrlWithMessage:(OSMessage *)msg
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    
    switch (msg.multimediaType) {
        case OSMultimediaTypeText: {
            parameters[@"__class"] = @"WBMessageObject";
            if (nil != msg.title) {
                parameters[@"text"] = msg.title;
            }
            break;
        }
        case OSMultimediaTypeImage: {
            parameters[@"__class"] = @"WBMessageObject";
            if (nil != msg.imageData) {
                parameters[@"imageObject"] = @{@"imageData": msg.imageData};
            }
            if (nil != msg.title) {
                parameters[@"text"] = msg.title;
            }
            break;
        }
        case OSMultimediaTypeNews: {
            parameters[@"__class"] = @"WBMessageObject";
            NSMutableDictionary *mediaObjectDic = @{@"__class": @"WBWebpageObject",
                                                    @"objectID": @"identifier1"}.mutableCopy;
            if (nil != msg.title) {
                mediaObjectDic[@"title"] = msg.title;
            }
            if (nil != msg.desc) {
                mediaObjectDic[@"description"] = msg.desc;
            }
            if (nil != msg.thumbnailData) {
                mediaObjectDic[@"thumbnailData"] = msg.thumbnailData;
            }
            if (nil != msg.link) {
                mediaObjectDic[@"webpageUrl"] = msg.link;
            }
            parameters[@"mediaObject"] = mediaObjectDic;
            
            break;
        }
        default:
            break;
    }
    
    NSData *transferObjectData = [NSKeyedArchiver archivedDataWithRootObject:@{@"__class": @"WBSendMessageToWeiboRequest",
                                                                               @"message": parameters,
                                                                               @"requestID": TCAppInfo.uuidForDevice}];
    NSData *appData = [NSKeyedArchiver archivedDataWithRootObject:@{@"appKey": [self dataForRegistedScheme:kSinaWbScheme][@"appKey"],
                                                                    @"bundleID": [TCAppInfo bundleIdentifier]}];
    [UIPasteboard generalPasteboard].items = @[@{@"transferObject": transferObjectData},
                                               @{@"userInfo": [NSKeyedArchiver archivedDataWithRootObject:@{}]},
                                               @{@"app": appData}];

    return [NSURL URLWithString:[NSString stringWithFormat:@"weibosdk://request?id=%@&sdkversion=003013000",TCAppInfo.uuidForDevice]];
}

+ (BOOL)SinaWeibo_handleOpenURL:(NSURL *)url
{
    if ([url.scheme hasPrefix:@"wb"]) {
       
        NSArray *items = [UIPasteboard generalPasteboard].items;
        NSMutableDictionary *responseDic = [NSMutableDictionary dictionaryWithCapacity:items.count];
        for (NSDictionary *item in items) {
            for (NSString *key in item) {
                responseDic[key] = [key isEqualToString:@"sdkVersion"] ? item[key] : [NSKeyedUnarchiver unarchiveObjectWithData:item[key]];
            }
        }
        
        NSDictionary *transferObject = responseDic[@"transferObject"];
        if ([transferObject[@"__class"] isEqualToString:@"WBAuthorizeResponse"]) {
            //auth
        }else if ([transferObject[@"__class"] isEqualToString:@"WBSendMessageToWeiboResponse"]) {
            //分享回调
            BOOL success = ![transferObject[@"statusCode"] boolValue];
            NSError *error = nil;
            if (!success) {
                error = [NSError errorWithDomain:@"weibo_share_response" code:[transferObject[@"statusCode"] intValue] userInfo:transferObject];
            }
            
            if (nil != self.shareCompletionHandle) {
                self.shareCompletionHandle(success, error);
            }
        }
        
        return YES;
    } else {
        return NO;
    }
}

@end
