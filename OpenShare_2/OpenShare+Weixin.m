//
//  OpenShare+Weixin.m
//  OpenShare_2
//
//  Created by jia on 16/3/22.
//  Copyright © 2016年 Jia. All rights reserved.
//

#import "OpenShare+Weixin.h"
#import "OpenShare+Helper.h"

NSString *const kWXScheme = @"Weixin";
static NSString *const kWXShareApi = @"mqqapi://share/to_fri";

static NSString *const kWXSDKVersion = @"1.5";

enum {
    kWXSession,
    kWXTimeLine
};

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
    if ([self shouldOpenApp:kWXScheme message:msg completionHandle:completionHandle]) {
        [self openAppWithURL:[self wxurlWithMessage:msg flag:kWXSession]];
    }
}

+ (void)shareToWeixinTimeLine:(OSMessage *)msg completion:(OSShareCompletionHandle)completionHandle
{
    if ([self shouldOpenApp:kWXScheme message:msg completionHandle:completionHandle]) {
        [self openAppWithURL:[self wxurlWithMessage:msg flag:kWXTimeLine]];
    }
}

// Data
static NSMutableDictionary *s_openUrlParameters = nil;

+ (NSMutableDictionary *)wxOpenUrlParameters
{
    if (nil == s_openUrlParameters) {
        s_openUrlParameters = @{@"result": @"1",
                                @"returnFromApp": @"0",
                                @"sdkver": kWXSDKVersion,
                                @"command": @"1010"}.mutableCopy;
    }
    return s_openUrlParameters;
}

+ (NSURL *)wxurlWithMessage:(OSMessage *)msg flag:(NSInteger)flag
{
    NSMutableDictionary *parameters = self.wxOpenUrlParameters;
    msg.appScheme = kWXScheme;

    // 朋友圈/朋友
    parameters[@"scene"] = @(flag);
    if (nil != msg.title) {
        parameters[@"title"] = msg.title;
    }
    if (nil != msg.desc) {
        parameters[@"description"] = msg.desc;
    }
    
    switch (msg.multimediaType) {
        case OSMultimediaTypeText: {
            parameters[@"command"] = @"1020";
            break;
        }
        case OSMultimediaTypeImage: {
            parameters[@"command"] = @"1010";
            
            // gif or not gif
            BOOL isGif = nil != msg.wxFileData;
            NSData *data = isGif ? msg.wxFileData : msg.imageData;
            if (nil != data) {
                parameters[@"fileData"] = data;
                parameters[@"thumbData"] = data;
                parameters[@"objectType"] = isGif ? @(kWXObjectTypeGif) : @(kWXObjectTypeImage);
            }
            break;
        }
        case OSMultimediaTypeAudio:
        case OSMultimediaTypeVideo:
        {
            //music
            parameters[@"command"] = @"1010";
            if (nil != msg.thumbnailData) {
                parameters[@"thumbData"] = msg.thumbnailData;
            }
            if (nil != msg.link) {
                parameters[@"mediaUrl"] = msg.link;
            }
            if (nil != msg.mediaDataUrl) {
                parameters[@"mediaDataUrl"] = msg.mediaDataUrl;
            }
            parameters[@"objectType"] = msg.multimediaType == OSMultimediaTypeAudio ? @(kWXObjectTypeAudio) : @(kWXObjectTypeVideo);
            break;
        }
        case OSMultimediaTypeNews: {
            parameters[@"command"] = @"1010";
            if (nil != msg.thumbnailData) {
                parameters[@"thumbData"] = msg.thumbnailData;
            }
            if (nil != msg.link) {
                parameters[@"mediaUrl"] = msg.link;
            }
            parameters[@"objectType"] = @(kWXObjectTypeNews);
            break;
        }
        case OSMultimediaTypeFile: {
            //file
            parameters[@"command"] = @"1010";
            if (nil != msg.wxFileData) {
                parameters[@"fileData"] = msg.wxFileData;
            }
            if (nil != msg.wxFileExt) {
                parameters[@"fileExt"] = msg.wxFileExt;
            }

            if (nil != msg.thumbnailData) {
                parameters[@"thumbData"] = msg.thumbnailData;
            }
            parameters[@"objectType"] = @(kWXObjectTypeFile);
            break;
        }
        case OSMultimediaTypeApp: {
            //app
            NSString *extInfo = msg.extInfo;
            if (nil != extInfo) {
                parameters[@"extInfo"] = extInfo;
            }
            parameters[@"command"] = @"1010";
            if (nil != msg.imageData) {
                parameters[@"fileData"] = msg.imageData;
            }
            if (nil != msg.thumbnailData) {
                parameters[@"thumbData"] = msg.thumbnailData;
            }
            if (nil != msg.link) {
                parameters[@"mediaUrl"] = msg.link;
            }

            parameters[@"objectType"] = @(kWXObjectTypeApp);
            break;
        }
       
        default:
            break;
    }
    
    NSData *output = [NSPropertyListSerialization dataWithPropertyList:@{[self dataForRegistedScheme:kWXScheme][@"appid"]: parameters}
                                                                format:NSPropertyListBinaryFormat_v1_0 options:0
                                                                 error:nil];
    [[UIPasteboard generalPasteboard] setData:output forPasteboardType:@"content"];
    NSString *urlStr = [NSString stringWithFormat:@"weixin://app/%@/sendreq/?", [self dataForRegistedScheme:kWXScheme][@"appid"]];
    return [NSURL URLWithString:urlStr];
}


+ (BOOL)Weixin_handleOpenURL:(NSURL *)url
{
    if ([url.scheme hasPrefix:@"wx"]) {
        NSData *content = [[UIPasteboard generalPasteboard] dataForPasteboardType:@"content"];
        if (nil == content) {
            return YES;
        }
        
        NSString *appId = [self dataForRegistedScheme:kWXScheme][@"appid"];
        NSDictionary *responseDic = [NSPropertyListSerialization propertyListWithData:content options:0 format:0 error:nil][appId];
        
        if ([url.absoluteString rangeOfString:@"://oauth"].location != NSNotFound) {
        
        } else if([url.absoluteString rangeOfString:@"://pay/"].location != NSNotFound) {
    
        } else {
            if (responseDic[@"state"] && [responseDic[@"state"] isEqualToString:@"Weixinauth"] && [responseDic[@"result"] intValue] != 0) {
                // 登录失败
                return YES;
            }
            
            BOOL success = ![responseDic[@"result"] boolValue];
            
            NSError *error = nil;
            if (!success) {
                error = [NSError errorWithDomain:@"weixin_share" code:[responseDic[@"result"] intValue] userInfo:responseDic];
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
