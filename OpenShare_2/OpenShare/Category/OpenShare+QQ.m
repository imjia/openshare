//
//  OpenShare+QQ.m
//  OpenShare_2
//
//  Created by jia on 16/3/21.
//  Copyright © 2016年 Jia. All rights reserved.
//

#import "OpenShare+QQ.h"
#import "OpenShare+Helper.h"
#import "OSQQParameter.h"
#import "NSObject+TCDictionaryMapping.h"

static NSString *const kOSQQScheme = @"QQ";
static NSString *const kQQPasteboardKey = @"com.tencent.mqq.api.apiLargeData";
static NSString *const kQQShareApi = @"mqqapi://share/to_fri";

@implementation OpenShare (QQ)

+ (BOOL)isQQInstalled
{
    return [self canOpenURL:[NSURL URLWithString:kOSQQURL]];
}

+ (NSString *)callBackName
{
    return [self dataForRegistedScheme:kOSQQScheme][@"callback_name"];
}

+ (void)registQQWithAppId:(NSString *)appId
{
    [self registAppWithScheme:kOSQQScheme
                         data:@{@"appid": appId,
                                @"callback_name": [NSString stringWithFormat: @"QQ%02llx", appId.longLongValue]}];
}

+ (void)shareToQQ:(OSMessage *)msg completion:(OSShareCompletionHandle)completionHandle
{
    if ([self isAppRegisted:kOSQQScheme]) {
        [self openAppWithURL:[self urlWithMessage:msg flag:kOSPlatformQQ] completionHandle:completionHandle];
    }
}

+ (void)shareToQQZone:(OSMessage *)msg completion:(OSShareCompletionHandle)completionHandle
{
    if ([self isAppRegisted:kOSQQScheme]) {
        [self openAppWithURL:[self urlWithMessage:msg flag:kOSPlatformQQZone] completionHandle:completionHandle];
    }
}

// Data
static OSQQParameter *s_qqParam = nil;

+ (OSQQParameter *)qqParameter
{
    if (nil == s_qqParam) {
        s_qqParam = [[OSQQParameter alloc] init];
        s_qqParam.thirdAppDisplayName = [OpenShare base64EncodedString:TCAppInfo.displayName];
        s_qqParam.version = @"1";
        s_qqParam.callback_type = @"scheme";
        s_qqParam.callback_name = self.callBackName;
        s_qqParam.generalpastboard = @"1";
        s_qqParam.src_type = @"app";
        s_qqParam.shareType = @"0";
    }
    return s_qqParam;
}

+ (NSURL *)urlWithMessage:(OSMessage *)msg flag:(NSInteger)flag
{
    msg.app = kOSAppQQ;
    
    OSDataItem *data = msg.dataItem;
    data.platform = flag;
    
    OSQQParameter *qqParam = self.qqParameter.copy;
    if (nil != msg.platformAccount.callBackName) {
        qqParam.callback_name = msg.platformAccount.callBackName;
    }
    
    qqParam.cflag = kOSPlatformQQ == flag ? 0 : 1;
    
    switch (msg.multimediaType) {
        case OSMultimediaTypeText: {
            qqParam.file_type = @"text";
            qqParam.file_data = [OpenShare base64AndURLEncodedString:data.title];
            break;
        }
        case OSMultimediaTypeImage: {
        
            qqParam.file_type = @"img";
            qqParam.objectlocation = @"pasteboard";
            qqParam.title = [OpenShare base64AndURLEncodedString:data.title];
            qqParam.desc = [OpenShare base64AndURLEncodedString:data.content];
            
            //不需要设置缩略图，qq自己会处理，设了也不管用
            NSMutableDictionary *pbData = [[NSMutableDictionary alloc] init];
            if (nil != data.imageData) {
                pbData[@"file_data"] = data.imageData;
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
                qqParam.file_type = @"news";
            } else if (msg.multimediaType == OSMultimediaTypeAudio) {
                qqParam.file_type = @"audio";
            } else if (msg.multimediaType == OSMultimediaTypeVideo) {
                qqParam.file_type = @"video";
            }
 
            qqParam.objectlocation = @"pasteboard";
            qqParam.title = [OpenShare base64AndURLEncodedString:data.title];
            qqParam.desc = [OpenShare base64AndURLEncodedString:data.content];
            qqParam.url = [OpenShare base64AndURLEncodedString:data.link];
            qqParam.flashurl = [OpenShare base64AndURLEncodedString:data.mediaDataUrl];
            
            NSMutableDictionary *pbData = [[NSMutableDictionary alloc] init];
            if (nil != data.thumbnailData) {
                pbData[@"previewimagedata"] = data.thumbnailData;
            }

            [self setGeneralPasteboardData:pbData
                                    forKey:kQQPasteboardKey
                                  encoding:kOSPasteboardEncodingKeyedArchiver];
            break;
        }
        default:
            break;
    }
    
    NSString *urlStr = [kQQShareApi stringByAppendingFormat:@"?%@", [OpenShare urlStr:qqParam.tc_dictionary]];
    return [NSURL URLWithString:urlStr];
}

+ (BOOL)QQ_handleOpenURL:(NSURL *)url
{
    BOOL canHandle = [url.scheme hasPrefix:@"QQ"];
    //分享
    if (canHandle) {
        [self clearGeneralPasteboardDataForKey:kQQPasteboardKey];
        OSQQResponse *response = [OSQQResponse tc_mappingWithDictionary:[self parametersOfURL:url]];
        OSShareCompletionHandle handle = self.shareCompletionHandle;
        if (nil != handle) {
            handle(nil, kOSPlatformCommon, 0 != response.errorCode ? kOSStateFail : kOSStateSuccess, response.error);
            handle = nil;
        }
    }
    return canHandle;
}

@end
