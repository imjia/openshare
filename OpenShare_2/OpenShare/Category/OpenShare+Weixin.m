//
//  OpenShare+Weixin.m
//  OpenShare_2
//
//  Created by jia on 16/3/22.
//  Copyright © 2016年 Jia. All rights reserved.
//

#import "OpenShare+Weixin.h"
#import "OpenShare+Helper.h"
#import "OSWXParameter.h"
#import "NSObject+TCDictionaryMapping.h"

static NSString *const kWXScheme = @"Weixin";
static NSString *const kWXPasterBoardKey = @"content";
static NSString *const kWXShareApi = @"mqqapi://share/to_fri";
static NSString *const kWXSDKVersion = @"1.5";

typedef NS_ENUM(NSInteger, WXObjectType) {
    kWXObjectTypeImage = 2,
    kWXObjectTypeAudio,
    kWXObjectTypeVideo,
    kWXObjectTypeNews,
    kWXObjectTypeFile,
    kWXObjectTypeApp,
    kWXObjectTypeGif,
};

@implementation OpenShare (Weixin)

+ (BOOL)isWeixinInstalled
{
    return [self canOpenURL:[NSURL URLWithString:@"weixin://"]];
}

+ (void)registWeixinWithAppId:(NSString *)appId
{
    [self registAppWithScheme:kWXScheme
                         data:@{@"appid": appId}];
}

+ (void)shareToWeixinSession:(OSMessage *)msg completion:(OSShareCompletionHandle)completionHandle
{
    if ([self isAppRegisted:kWXScheme]) {
        [self openAppWithURL:[self wxurlWithMessage:msg flag:kOSPlatformWXSession] completionHandle:completionHandle];
    }
}

+ (void)shareToWeixinTimeLine:(OSMessage *)msg completion:(OSShareCompletionHandle)completionHandle
{
    if ([self isAppRegisted:kWXScheme]) {
        [self openAppWithURL:[self wxurlWithMessage:msg flag:kOSPlatformWXTimeLine] completionHandle:completionHandle];
    }
}

// Data
static OSWXParameter *s_wxParam = nil;

+ (OSWXParameter *)wxParameter
{
    if (nil == s_wxParam) {
        s_wxParam = [[OSWXParameter alloc] init];
        s_wxParam.result = @"1";
        s_wxParam.returnFromApp = @"0";
        s_wxParam.sdkver = kWXSDKVersion;
        s_wxParam.command = @"1010";
    }
    return s_wxParam;
}

+ (NSURL *)wxurlWithMessage:(OSMessage *)msg flag:(NSInteger)flag
{
    msg.app = kOSAppWeixin;
    OSDataItem *data = msg.dataItem;
    data.platform = flag;
    
    OSWXParameter *wxParam = self.wxParameter;
    // 朋友圈/朋友
    wxParam.scene = kOSPlatformWXSession == flag ? 0 : 1;

    switch (msg.multimediaType) {
        case OSMultimediaTypeText: {
            wxParam.command = @"1020";
            wxParam.title = data.content;
            break;
        }
        case OSMultimediaTypeImage: {
            wxParam.command = @"1010";
            wxParam.title = data.title;
            wxParam.desc = data.content;
            
            // gif or not gif
            BOOL isGif = nil != data.wxFileData;
            if (isGif) {
                wxParam.fileData = data.wxFileData;
            }
            
            NSData *imgData = isGif ? data.wxFileData : data.imageData;
            if (nil != imgData) {
                wxParam.fileData = imgData;
                wxParam.thumbData = imgData;
                wxParam.objectType = isGif ? kWXObjectTypeGif : kWXObjectTypeImage;
            }
            break;
        }
        case OSMultimediaTypeAudio:
        case OSMultimediaTypeVideo:
        {
            //music & video
            wxParam.command = @"1010";
            wxParam.title = data.title;
            wxParam.desc = data.content;
            wxParam.thumbData = data.thumbnailData;
            wxParam.mediaUrl = data.link;
            wxParam.mediaDataUrl = data.mediaDataUrl;
            wxParam.objectType = msg.multimediaType == OSMultimediaTypeAudio ? kWXObjectTypeAudio : kWXObjectTypeVideo;
            
            break;
        }
        case OSMultimediaTypeNews: {
            wxParam.command = @"1010";
            wxParam.title = data.title;
            wxParam.desc = data.content;
            wxParam.thumbData = data.thumbnailData;
            wxParam.mediaUrl = data.link;
            wxParam.objectType = kWXObjectTypeNews;
            break;
        }
        case OSMultimediaTypeFile: {
            //file
            wxParam.command = @"1010";
            wxParam.title = data.title;
            wxParam.desc = data.content;
            wxParam.fileData = data.wxFileData;
            wxParam.fileExt = data.wxFileExt;
            wxParam.thumbData = data.thumbnailData;
            wxParam.objectType = kWXObjectTypeFile;
            break;
        }
        case OSMultimediaTypeApp: {
            //app
            wxParam.command = @"1010";
            wxParam.title = data.title;
            wxParam.desc = data.content;
            wxParam.extInfo = data.wxExtInfo;
            wxParam.fileExt = data.wxFileExt;
            wxParam.fileData = data.imageData;
            wxParam.thumbData = data.thumbnailData;
            wxParam.mediaUrl = data.link;
            wxParam.objectType = kWXObjectTypeApp;
            break;
        }
       
        default:
            break;
    }

    NSString *appId = msg.platformAccount.appId;
    if (nil == appId) {
        appId = [self dataForRegistedScheme:kWXScheme][@"appid"];
    }
    
    NSData *output = [NSPropertyListSerialization dataWithPropertyList:@{appId: wxParam.tc_dictionary}
                                                                format:NSPropertyListBinaryFormat_v1_0
                                                               options:0
                                                                 error:nil];
    [[UIPasteboard generalPasteboard] setData:output
                            forPasteboardType:kWXPasterBoardKey];


    
    NSString *urlStr = [NSString stringWithFormat:@"weixin://app/%@/sendreq/?", appId];
    return [NSURL URLWithString:urlStr];
}

+ (BOOL)Weixin_handleOpenURL:(NSURL *)url
{
    BOOL canHandle = [url.scheme hasPrefix:@"wx"];
    if (canHandle) {
        
        NSData *content = [[UIPasteboard generalPasteboard] dataForPasteboardType:@"content"];
        if (nil == content) {
            return canHandle;
        }
        
        NSString *appId = [self dataForRegistedScheme:kWXScheme][@"appid"];
        NSDictionary *contentDic = [NSPropertyListSerialization propertyListWithData:content
                                                                             options:0
                                                                              format:0 error:nil][appId];

        /* 登录、支付 暂时没写这功能
        NSString *urlStr = url.absoluteString;
        if ([urlStr rangeOfString:@"://oauth"].location != NSNotFound) {
        
        } else if([urlStr rangeOfString:@"://pay/"].location != NSNotFound) {
    
        } else {
         */
        
        OSWXResponse *response = [OSWXResponse tc_mappingWithDictionary:contentDic];
        if (nil != response.state && [response.state isEqualToString:@"Weixinauth"] && response.result != 0) {
            // 登录失败
            return canHandle;
        }
        
        OSShareCompletionHandle handle = self.shareCompletionHandle;
        if (nil != handle) {
            handle(nil, kOSPlatformCommon, response.result ? kOSStateFail : kOSStateSuccess, nil);
            handle = nil;
        }
    }

    return canHandle;
}

@end
