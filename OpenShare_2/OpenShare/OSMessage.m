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
    NSMutableDictionary<NSString */*app scheme*/, OSAppItem *> *_appDic; // app配置
}

@end

@implementation OSMessage

- (NSMutableDictionary *)appDic
{
    if (nil == _appDic) {
        _appDic = [[NSMutableDictionary alloc] init];
    }
    return _appDic;
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

- (OSAppItem *)appItem
{
    return self.appDic[_appScheme];
}

- (void)setAppScheme:(NSString *)appScheme
{
    _appScheme = appScheme;
}

@end


#pragma mark - OSDataItem

static NSString *const kDefaultData = @"defaultData";

@interface OSDataItem () {
    @private
    NSMutableDictionary<NSString *, NSMutableDictionary *> *_dataDic;
}

@end

@implementation OSDataItem

- (instancetype)init
{
    if (self = [super init]) {
        _dataDic = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)configValue:(id)value forProperty:(NSString *)property forApp:(NSNumber *)app
{
    NSMutableDictionary *propertyDic = [self propertyDicWithProperty:property];
    propertyDic[app] = value;
    _dataDic[property] = propertyDic;
}

- (NSMutableDictionary *)propertyDicWithProperty:(NSString *)property
{
    NSMutableDictionary *propertyDic = _dataDic[property];
    if (nil == propertyDic) {
        propertyDic = [NSMutableDictionary dictionary];
        _dataDic[property] = propertyDic;
    }
    return propertyDic;
}

- (void)setTitle:(NSString *)title
{
    if (nil != title) {
        NSMutableDictionary *propertyDic = [self propertyDicWithProperty:@"title"];
        propertyDic[kDefaultData] = title;
    }
}

- (void)setDesc:(NSString *)desc
{
    if (nil != desc) {
        NSMutableDictionary *propertyDic = [self propertyDicWithProperty:@"desc"];
        propertyDic[kDefaultData] = desc;
    }
}

- (void)setLink:(NSString *)link
{
    if (nil != link) {
        NSMutableDictionary *propertyDic = [self propertyDicWithProperty:@"link"];
        propertyDic[kDefaultData] = link;
    }
}

- (void)setImageData:(NSData *)imageData
{
    if (nil != imageData) {
        NSMutableDictionary *propertyDic = [self propertyDicWithProperty:@"imageData"];
        propertyDic[kDefaultData] = imageData;
    }
}

- (void)setThumbnailData:(NSData *)thumbnailData
{
    if (nil != thumbnailData) {
        NSMutableDictionary *propertyDic = [self propertyDicWithProperty:@"thumbnailData"];
        propertyDic[kDefaultData] = thumbnailData;
    }
}

- (void)setImageUrl:(NSString *)imageUrl
{
    if (nil != imageUrl) {
        NSMutableDictionary *propertyDic = [self propertyDicWithProperty:@"imageUrl"];
        propertyDic[kDefaultData] = imageUrl;
    }
}

- (void)setThumbnailUrl:(NSString *)thumbnailUrl
{
    if (nil != thumbnailUrl) {
        NSMutableDictionary *propertyDic = [self propertyDicWithProperty:@"thumbnailUrl"];
        propertyDic[kDefaultData] = thumbnailUrl;
    }
}

- (NSString *)title
{
    NSMutableDictionary *propertyDic = [self propertyDicWithProperty:@"title"];
    return propertyDic[_app] ?: propertyDic[kDefaultData];
}

- (NSString *)desc
{
    NSMutableDictionary *propertyDic = [self propertyDicWithProperty:@"desc"];
    return propertyDic[_app] ?: propertyDic[kDefaultData];
}

- (NSString *)link
{
    NSMutableDictionary *propertyDic = [self propertyDicWithProperty:@"link"];
    return propertyDic[_app] ?: propertyDic[kDefaultData];
}

- (NSData *)imageData
{
    NSMutableDictionary *propertyDic = [self propertyDicWithProperty:@"imageData"];
    return propertyDic[_app] ?: propertyDic[kDefaultData];
}

- (NSData *)thumbnailData
{
    NSMutableDictionary *propertyDic = [self propertyDicWithProperty:@"thumbnailData"];
    return propertyDic[_app] ?: propertyDic[kDefaultData];
}

- (NSString *)imageUrl
{
    NSMutableDictionary *propertyDic = [self propertyDicWithProperty:@"imageUrl"];
    return propertyDic[_app] ?: propertyDic[kDefaultData];
}

- (NSString *)thumbnailUrl
{
    NSMutableDictionary *propertyDic = [self propertyDicWithProperty:@"thumbnailUrl"];
    return propertyDic[_app] ?: propertyDic[kDefaultData];
}

- (NSString *)msgBody
{
    if (nil == _msgBody) {
        return self.title;
    }
    return _msgBody;
}

- (NSString *)emailBody
{
    if (nil == _emailBody) {
        return self.title;
    }
    return _emailBody;
}

@end


#pragma mark - OSAppItem

@implementation OSAppItem

@end

