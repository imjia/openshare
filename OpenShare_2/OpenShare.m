//
//  OpenShare.m
//  OpenShare_2
//
//  Created by jia on 16/3/21.
//  Copyright © 2016年 Jia. All rights reserved.
//

#import "OpenShare.h"
#import <objc/runtime.h>
#import "OSSnsItemView.h"

static NSString *const kDefaultData = @"defaultData";

@interface OpenShare () <OSSnsItemViewDelegate>

@end

@implementation OpenShare

static NSMutableDictionary *s_registedSchemes = nil;
static OSShareCompletionHandle s_shareCompletionHandle = nil;

+ (OSShareCompletionHandle)shareCompletionHandle
{
    return s_shareCompletionHandle;
}

+ (NSMutableDictionary *)registedSchemes
{
    if (nil == s_registedSchemes) {
        s_registedSchemes = [[NSMutableDictionary alloc] init];
    }
    return s_registedSchemes;
}

+ (void)registAppWithScheme:(NSString *)appScheme data:(NSDictionary *)data
{
    if (nil == self.registedSchemes[appScheme]) {
        self.registedSchemes[appScheme] = data;
    }
}

+ (NSDictionary *)dataForRegistedScheme:(NSString *)appScheme
{
    return self.registedSchemes[appScheme];
}

+ (BOOL)shouldOpenApp:(NSString *)appScheme message:(OSMessage *)msg completionHandle:(OSShareCompletionHandle)handle
{
    if ([self isAppRegisted:appScheme]) {
        s_shareCompletionHandle = handle;
        return YES;
    }
    return NO;
}

+ (BOOL)isAppRegisted:(NSString *)appScheme
{
    return nil != self.registedSchemes[appScheme];
}

+ (BOOL)canOpenURL:(NSURL *)url
{
    return [[UIApplication sharedApplication] canOpenURL:url];
}

+ (void)openAppWithURL:(NSURL *)url
{
    [[UIApplication sharedApplication] openURL:url];
}

+ (void)setGeneralPasteboardData:(NSDictionary *)value forKey:(NSString *)key encoding:(OSPasteboardEncoding)encoding
{
    if (nil != value && nil != key) {
        NSData *data = nil;
        NSError *err = nil;
        switch (encoding) {
            case kOSPasteboardEncodingKeyedArchiver: {
                data = [NSKeyedArchiver archivedDataWithRootObject:value];
                break;
            }
            case kOSPasteboardEncodingPropertyListSerialization: {
                data = [NSPropertyListSerialization dataWithPropertyList:value
                                                                  format:NSPropertyListBinaryFormat_v1_0 options:0
                                                                   error:&err];
                break;
            }
            default:
                DLog(@"encoding not implemented");
                break;
        }
        
        if (nil != err) {
            DLog(@"error when NSPropertyListSerialization: %@",err);
        } else if (nil != data){
            [[UIPasteboard generalPasteboard] setData:data forPasteboardType:key];
        }
    }
}

+ (NSDictionary *)generalPasteboardDataForKey:(NSString *)key encoding:(OSPasteboardEncoding)encoding
{
    NSData *data = [[UIPasteboard generalPasteboard] dataForPasteboardType:key];
    NSDictionary *dic = nil;
    if (nil != data) {
        NSError *err = nil;
        switch (encoding) {
            case kOSPasteboardEncodingKeyedArchiver: {
                dic = [NSKeyedUnarchiver unarchiveObjectWithData:data];
                break;
            }
            case kOSPasteboardEncodingPropertyListSerialization: {
                dic = [NSPropertyListSerialization propertyListWithData:data
                                                                options:0
                                                                 format:0
                                                                  error:&err];
                break;
            }
            default:
                break;
        }
        if (nil != err) {
            NSLog(@"error when NSPropertyListSerialization: %@",err);
        }
    }
    
    return dic;
}

+ (void)clearGeneralPasteboardDataForKey:(NSString *)key
{
    if (nil != key) {
        [[UIPasteboard generalPasteboard] setValue:@"" forPasteboardType:key];
    }
}

+ (BOOL)handleOpenURL:(NSURL *)url
{
    for (NSString *scheme in s_registedSchemes) {
        SEL sel = NSSelectorFromString([scheme stringByAppendingString:@"_handleOpenURL:"]);
        if ([self respondsToSelector:sel]) {
            
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:
                                        [self methodSignatureForSelector:sel]];
            invocation.selector = sel;
            invocation.target = self;
            [invocation setArgument:&url atIndex:2]; // 这里设置参数的Index 需要从2开始，因为前两个被selector和target占用
            [invocation invoke];
            
            BOOL returnValue = NO;
            [invocation getReturnValue:&returnValue];
            if (returnValue) { //如果这个url能处理，就返回YES，否则，交给下一个处理。
                return YES;
            }
        } else{
            DLog(@"fatal error: %@ is should have a method: %@", scheme, [scheme stringByAppendingString:@"_handleOpenURL"]);
        }
    }
    return NO;
}

@end

@interface OSMessage () {
    NSMutableDictionary<NSString */*app scheme*/, OSDataItem *> *_dataDic; // 分享内容
    NSMutableDictionary<NSString */*app scheme*/, OSAppItem *> *_appDic; // app配置
}

@end

@implementation OSMessage

- (NSMutableDictionary *)dataDic
{
    if (nil == _dataDic) {
        _dataDic = [[NSMutableDictionary alloc] init];
    }
    return _dataDic;
}

- (NSMutableDictionary *)appDic
{
    if (nil == _appDic) {
        _appDic = [[NSMutableDictionary alloc] init];
    }
    return _appDic;
}

- (void)setDataItem:(OSDataItem *)dataItem
{
    if (nil != dataItem) {
        self.dataDic[kDefaultData] = dataItem;
    }
}

- (void)configDataItem:(void (^)(OSDataItem *))config forApp:(NSString *)app
{
    OSDataItem *dataItem = self.dataDic[app];
    if (nil == dataItem) {
        OSDataItem *defaultData = _dataDic[kDefaultData];
        dataItem = defaultData.copy;
        _dataDic[app] = dataItem;
    }

    if (nil != config) {
        config(dataItem);
    }
}

- (void)configAppItem:(void (^)(OSAppItem *))config forApp:(NSString *)app
{
    OSAppItem *appItem = self.appDic[app];
    if (nil == appItem) {
        appItem = [[OSAppItem alloc] init];
        _appDic[app] = appItem;
    }
    
    if (nil != config) {
        config(appItem);
    }
}

- (OSDataItem *)dataItem
{
    OSDataItem *dataItem = self.dataDic[_appScheme];
    if (nil == dataItem) {
        dataItem = _dataDic[kDefaultData];
    }
    return dataItem;
}

- (OSAppItem *)appItem
{
    return self.appDic[_appScheme];
}

@end