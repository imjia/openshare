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
    return [self canOpenURL:[NSURL URLWithString:kOSWeixinScheme]];
}

+ (void)registWeixinWithAppId:(NSString *)appId
{
    [self registAppWithName:kOSWeixinIdentifier
                       data:@{@"appid": appId}];
}

+ (void)shareToWeixinSession:(OSMessage *)msg
{
    if ([self isAppRegisted:kOSWeixinIdentifier]) {
        [self openAppWithURL:[self wxurlWithMessage:msg flag:kOSPlatformWXSession]];
    }
}

+ (void)shareToWeixinTimeLine:(OSMessage *)msg
{
    if ([self isAppRegisted:kOSWeixinIdentifier]) {
        [self openAppWithURL:[self wxurlWithMessage:msg flag:kOSPlatformWXTimeLine]];
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
    OSDataItem *data = msg.dataItem;
    data.platformCode = flag;
    
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
            
            NSData *imageData = data.imageData;
            if (nil != imageData) {
                NSString *type = [OpenShare contentTypeForImageData:imageData];
                BOOL isGif = [type hasPrefix:@"gif"];
                if (isGif) {
                    wxParam.fileData = imageData;
                    wxParam.objectType = kWXObjectTypeGif;
                } else {
                    wxParam.fileData = imageData;
                    wxParam.thumbData = data.thumbnailData;
                    wxParam.objectType = kWXObjectTypeImage;
                }
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
            wxParam.objectType = msg.multimediaType;
            
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
        default:
            break;
    }
    
    OSPlatformAccount *account = [msg accountForApp:kOSAppWeixin];
    NSString *appId = account.appId;
    if (nil == appId) {
        appId = [self dataForRegistedApp:kOSWeixinIdentifier][@"appid"];
    }
    
    NSData *output = nil;
    @try {
        output = [NSPropertyListSerialization dataWithPropertyList:@{appId: wxParam.tc_dictionary}
                                                            format:NSPropertyListBinaryFormat_v1_0
                                                           options:kNilOptions
                                                             error:NULL];
    } @catch (NSException *exception) {
        DLog_e(@"%@", exception);
    } @finally {
        if (nil != output) {
            [[UIPasteboard generalPasteboard] setData:output
                                    forPasteboardType:kWXPasterBoardKey];
        }
    }
    
    NSString *urlStr = [NSString stringWithFormat:@"%@app/%@/sendreq/?",kOSWeixinScheme, appId];
    return [NSURL URLWithString:urlStr];
}

+ (BOOL)wx_handleOpenURL:(NSURL *)url
{
    BOOL canHandle = [url.scheme hasPrefix:kOSWeixinIdentifier];
    if (!canHandle) {
        return NO;
    }
    
    NSData *content = [[UIPasteboard generalPasteboard] dataForPasteboardType:@"content"];
    if (nil == content) {
        return canHandle;
    }
    
    // 清除数据
    [self clearGeneralPasteboardDataForKey:kWXPasterBoardKey];
    [self clearGeneralPasteboardDataForKey:@"content"];
    if ([url.absoluteString rangeOfString:self.identifier].location == NSNotFound) {
        return canHandle;
    }
    self.identifier = nil;
    
    NSString *appId = [self dataForRegistedApp:kOSWeixinIdentifier][@"appid"];
    NSDictionary *contentDic = nil;
    @try {
        contentDic = [NSPropertyListSerialization propertyListWithData:content
                                                               options:kNilOptions
                                                                format:nil
                                                                 error:NULL][appId];
    } @catch (NSException *exception) {
        DLog_e(@"%@", exception);
    } @finally {
        OSWXResponse *response = [OSWXResponse tc_mappingWithDictionary:contentDic];
        [[NSNotificationCenter defaultCenter] postNotificationName:kOSShareFinishedNotification object:response];
        return canHandle;
    }
    
    /* 登录、支付 暂时没写这功能
     NSString *urlStr = url.absoluteString;
     if ([urlStr rangeOfString:@"://oauth"].location != NSNotFound) {
     
     } else if([urlStr rangeOfString:@"://pay/"].location != NSNotFound) {
     
     } else {
     */
}

@end
