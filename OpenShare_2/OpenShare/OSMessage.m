//
//  OSMessage.m
//  OpenShare_2
//
//  Created by jia on 16/5/4.
//  Copyright © 2016年 Jia. All rights reserved.
//

#import "OSMessage.h"
#import <objc/runtime.h>

#pragma mark - OSMessage

@interface OSMessage () {
    NSMutableDictionary<NSNumber */*platform*/, OSPlatformAccount *> *_accountDic; // app配置
}

@end

@implementation OSMessage

- (instancetype)initWithOSMultimediaType:(OSMultimediaType)mediaType
{
    if (self = [super init]) {
        _multimediaType = mediaType;
    }
    return self;
}

- (NSMutableDictionary *)accountDic
{
    if (nil == _accountDic) {
        _accountDic = [[NSMutableDictionary alloc] init];
    }
    return _accountDic;
}

- (void)configAccount:(void (^)(OSPlatformAccount *))config forApp:(OSAPP)app
{
    OSPlatformAccount *account = self.accountDic[@(app)];
    if (nil == account) {
        account = [[OSPlatformAccount alloc] init];
        _accountDic[@(app)] = account;
    }
    
    if (nil != config) {
        config(account);
    }
}

- (OSPlatformAccount *)platformAccount
{
    return self.accountDic[@(_app)];
}

@end


#pragma mark - OSDataItem

static NSString *const kDefaultData = @"defaultData";

@interface OSDataItem () {
@private
    NSMutableDictionary<NSString */*property*/, NSMutableDictionary */*{platform: customValue}*/> *_dataDic;
}

@end

@implementation OSDataItem
@dynamic title;
@dynamic content;
@dynamic link;
@dynamic imageData;
@dynamic thumbnailData;
@dynamic imageUrl;
@dynamic thumbnailUrl;

- (instancetype)init
{
    if (self = [super init]) {
        _dataDic = [NSMutableDictionary dictionary];
    }
    return self;
}

- (NSMutableDictionary *)valueDicForProperty:(NSString *)property;
{
    NSMutableDictionary *valueDic = _dataDic[property];
    if (nil == valueDic) {
        valueDic = [NSMutableDictionary dictionary];
        _dataDic[property] = valueDic;
    }
    return valueDic;
}

- (void)setValue:(id)value forKey:(nonnull NSString *)key forPlatform:(OSPlatformCode)platformCode
{
    if (nil != value) {
        [self valueDicForProperty:key][@(platformCode)] = value;
    }
}

- (void)setValueDic:(NSDictionary<NSString *,id> *)valueDic forPlatform:(OSPlatformCode)platformCode
{
    for (NSString *key in valueDic.allKeys) {
        [self setValue:valueDic[key] forKey:key forPlatform:platformCode];
    }
}

- (id)platformValueForProperty:(NSString *)property
{
    NSMutableDictionary *valueDic = [self valueDicForProperty:property];
    id value = valueDic[@(_platformCode)];
    if (nil == value) {
        value = valueDic[@(kOSPlatformCommon)];
    }
    return value;
}

- (void)setTitle:(NSString *)title
{
    if (nil != title) {
        [self setValue:title forKey:PropertySTR(title) forPlatform:kOSPlatformCommon];
    }
}

- (void)setContent:(NSString *)content
{
    if (nil != content) {
        [self setValue:content forKey:PropertySTR(content) forPlatform:kOSPlatformCommon];
    }
}

- (void)setLink:(NSString *)link
{
    if (nil != link) {
        [self setValue:link forKey:PropertySTR(link) forPlatform:kOSPlatformCommon];
    }
}

- (void)setImageData:(NSData *)imageData
{
    if (nil != imageData) {
        [self setValue:imageData forKey:PropertySTR(imageData) forPlatform:kOSPlatformCommon];
    }
}

- (void)setThumbnailData:(NSData *)thumbnailData
{
    if (nil != thumbnailData) {
        [self setValue:thumbnailData forKey:PropertySTR(thumbnailData) forPlatform:kOSPlatformCommon];
    }
}

- (void)setImageUrl:(NSString *)imageUrl
{
    if (nil != imageUrl) {
        [self setValue:imageUrl forKey:PropertySTR(imageUrl) forPlatform:kOSPlatformCommon];
    }
}

- (void)setThumbnailUrl:(NSString *)thumbnailUrl
{
    if (nil != thumbnailUrl) {
        [self setValue:thumbnailUrl forKey:PropertySTR(thumbnailUrl) forPlatform:kOSPlatformCommon];
    }
}

- (NSString *)title
{
    return [self platformValueForProperty:NSStringFromSelector(_cmd)];
}

- (NSString *)content
{
    return [self platformValueForProperty:NSStringFromSelector(_cmd)];
}

- (NSString *)link
{
    return [self platformValueForProperty:NSStringFromSelector(_cmd)];
}

- (NSData *)imageData
{
    return [self platformValueForProperty:NSStringFromSelector(_cmd)];
}

- (NSData *)thumbnailData
{
    NSData *thumbnailData = [self platformValueForProperty:NSStringFromSelector(_cmd)];
    if (nil == thumbnailData) {
        thumbnailData = self.imageData;
    }
    return thumbnailData;
}

- (NSString *)imageUrl
{
    return [self platformValueForProperty:NSStringFromSelector(_cmd)];
}

- (NSString *)thumbnailUrl
{
    return [self platformValueForProperty:NSStringFromSelector(_cmd)];
}

- (NSString *)msgBody
{
    if (nil == _msgBody) {
        return self.content;
    }
    return _msgBody;
}

- (NSString *)emailBody
{
    if (nil == _emailBody) {
        return self.content;
    }
    return _emailBody;
}

@end


#pragma mark - OSPlatformAccount

@implementation OSPlatformAccount : NSObject

@end

