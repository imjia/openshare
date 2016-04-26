//
//  OpenShare+QQ.m
//  OpenShare_2
//
//  Created by jia on 16/3/21.
//  Copyright © 2016年 Jia. All rights reserved.
//

#import "OpenShare+QQ.h"
#import "OpenShare+Helper.h"

NSString *const kQQScheme = @"QQ";
static NSString *const kQQPasteboardKey = @"com.tencent.mqq.api.apiLargeData";
static NSString *const kQQShareApi = @"mqqapi://share/to_fri";

enum {
    kQQ,
    kQQZone,
};

@implementation OpenShare (QQ)

+ (BOOL)isQQInstalled
{
    return [self canOpenURL:[NSURL URLWithString:@"mqqapi://"]];
}

+ (NSString *)callBackName
{
    return [self dataForRegistedScheme:kQQScheme][@"callback_name"];
}

+ (void)registQQWithAppId:(NSString *)appId
{
    [self registAppWithScheme:kQQScheme
                         data:@{@"appid": appId,
                                @"callback_name": [NSString stringWithFormat: @"QQ%02llx", appId.longLongValue]}];
}

+ (void)shareToQQ:(OSMessage *)msg completion:(OSShareCompletionHandle)completionHandle
{
    if ([self shouldOpenApp:kQQScheme message:msg completionHandle:completionHandle]) {
        [self openAppWithURL:[self urlWithMessage:msg flag:kQQ]];
    }
}

+ (void)shareToQQZone:(OSMessage *)msg completion:(OSShareCompletionHandle)completionHandle
{
    if ([self shouldOpenApp:kQQScheme message:msg completionHandle:completionHandle]) {
        [self openAppWithURL:[self urlWithMessage:msg flag:kQQZone]];
    }
}

// Data
static NSMutableDictionary *s_openUrlParameters = nil;

+ (NSMutableDictionary *)qqOpenUrlParameters
{
    if (nil == s_openUrlParameters) {
        s_openUrlParameters = @{@"thirdAppDisplayName" : [OpenShare base64EncodedString:TCAppInfo.displayName],
                                @"version" : @"1",
                                @"callback_type" : @"scheme",
                                @"callback_name" : self.callBackName,
                                @"generalpastboard" : @"1",
                                @"src_type" : @"app",
                                @"shareType" : @"0"}.mutableCopy;
    }
    return s_openUrlParameters;
}

+ (NSURL *)urlWithMessage:(OSMessage *)msg flag:(NSInteger)flag
{
    NSMutableDictionary *parameters = self.qqOpenUrlParameters;
    msg.appScheme = kQQScheme;
    
    parameters[@"cflag"] = @(flag);
    
    switch (msg.multimediaType) {
        case OSMultimediaTypeText: {
            parameters[@"file_type"] = @"text";
            if (nil != msg.title) {
                parameters[@"file_data"] = [OpenShare base64AndURLEncodedString:msg.title];
            }
            break;
        }
        case OSMultimediaTypeImage: {
            
            NSAssert(nil != msg.imageData, @"图片不能为空");
            
            parameters[@"file_type"] = @"img";
            parameters[@"objectlocation"] = @"pasteboard";
            if (nil != msg.title) {
                parameters[@"title"] = msg.title;
            }
            if (nil != msg.desc) {
                parameters[@"description"] = msg.desc;
            }
            
            NSMutableDictionary *pbData = [[NSMutableDictionary alloc] init];
            if (nil != msg.imageData) {
                pbData[@"file_data"] = msg.imageData;
            }
            if (nil != msg.thumbnailData) {
                pbData[@"previewimagedata"] = msg.thumbnailData;
            }
            
            [self setGeneralPasteboardData:pbData
                                    forKey:kQQPasteboardKey
                                  encoding:kOSPasteboardEncodingKeyedArchiver];
            break;
        }
        case OSMultimediaTypeNews:
        case OSMultimediaTypeAudio:
        case OSMultimediaTypeVideo: {
            if (msg.multimediaType == OSMultimediaTypeNews) {
                parameters[@"file_type"] = @"news";
            } else if (msg.multimediaType == OSMultimediaTypeAudio) {
                parameters[@"file_type"] = @"audio";
            } else if (msg.multimediaType == OSMultimediaTypeVideo) {
                parameters[@"file_type"] = @"video";
            }
            parameters[@"objectlocation"] = @"pasteboard";
            
            if (nil != msg.title) {
                parameters[@"title"] = [OpenShare base64AndURLEncodedString:msg.title];
            }
            
            if (nil != msg.desc) {
                parameters[@"description"] = [OpenShare base64AndURLEncodedString:msg.desc];
            }
            
            if (nil != msg.link) {
                parameters[@"url"] = [OpenShare base64AndURLEncodedString:msg.link];
            }
            
            NSMutableDictionary *pbData = [[NSMutableDictionary alloc] init];
            if (nil != msg.thumbnailData) {
                pbData[@"previewimagedata"] = msg.thumbnailData;
            }
            [self setGeneralPasteboardData:pbData
                                    forKey:kQQPasteboardKey
                                  encoding:kOSPasteboardEncodingKeyedArchiver];
            break;
        }
        default:
            break;
    }
    
    NSString *urlStr = [kQQShareApi stringByAppendingFormat:@"?%@", [OpenShare urlStr:parameters]];
    return [NSURL URLWithString:urlStr];
}

+ (BOOL)QQ_handleOpenURL:(NSURL *)url
{
    //分享
    if ([url.scheme hasPrefix:@"QQ"]) {
        NSDictionary *parametersDic = [self parametersOfURL:url];
        if (nil != parametersDic[@"error_description"]) {
            [parametersDic setValue:[self base64DecodedString:parametersDic[@"error_description"]] forKey:@"error_description"];
        }
        
        BOOL success = nil == parametersDic[@"error"];
        NSError *error = nil;
        if (!success) {
            error = [NSError errorWithDomain:@"response_from_qq" code:[parametersDic[@"error"] intValue] userInfo:parametersDic];
        }
        if (nil != self.shareCompletionHandle) {
            self.shareCompletionHandle(success, error);
        }

        return YES;
    }
    else {
        return NO;
    }
}

@end
