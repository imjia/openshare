//
//  OpenShare.m
//  OpenShare_2
//
//  Created by jia on 16/3/21.
//  Copyright © 2016年 Jia. All rights reserved.
//

#import "OpenShare.h"
#import <objc/runtime.h>

static NSString *const kDefaultKey = @"defaultData";

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
    NSMutableDictionary<NSString */*app scheme*/, NSDictionary *> *_dic;
}

@end

@implementation OSMessage

- (void)setDataDic:(NSDictionary *)dataDic
{
    if (nil != dataDic) {
        if (nil == _dic) {
            _dic = [[NSMutableDictionary alloc] init];
        }
        _dic[kDefaultKey] = dataDic;
    }
}

- (void)setupObject:(id)object forKey:(NSString *)key forApp:(NSString *)app
{
    if (nil == object) {
        return;
    }
    
    NSMutableDictionary *dataDic = _dic[app];
    if (nil == dataDic) {
        dataDic = [[NSMutableDictionary alloc] init];
        _dic[app] = dataDic;
    }
    dataDic[key] = object;
}

- (id)objectForKey:(NSString *)key
{
    NSString *obj = _dic[_appScheme][key];
    if (nil == obj) {
        obj = _dic[kDefaultKey][key];
    }
    return obj;
}

- (NSString *)title
{
    return [self objectForKey:@"title"];
}

- (NSString *)desc
{
    return [self objectForKey:@"desc"];
}

- (NSString *)link
{
    return [self objectForKey:@"link"];
}

- (NSData *)imageData
{
    id img = [self objectForKey:@"image"];
    if ([img isKindOfClass:[NSData class]]) {
        return img;
    } else if ([img isKindOfClass:[UIImage class]]){
        return UIImageJPEGRepresentation(img, 0.6);
    }
    return img;
}

// TODO: 
- (NSData *)thumbnailData
{
    return self.imageData;
}


#pragma mark - 微信方法

- (NSData *)wxFileData
{
    return [self objectForKey:@"gif"];
}

- (NSString *)wxExtInfo
{
    return [self objectForKey:@"extInfo"];
}

- (NSString *)wxFileExt
{
    return [self objectForKey:@"fileExt"];
}

@end