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
    _dataItem.scheme = appScheme;
    _appScheme = appScheme;
}

@end


#pragma mark - OSDataItem

static NSString *const kDefaultData = @"defaultData";

@interface OSDataItem () {
    @private
    NSMutableDictionary<NSString *, NSString *> *_titleDic;
    NSMutableDictionary<NSString *, NSString *> *_descDic;
    NSMutableDictionary<NSString *, NSString *> *_linkDic;
    NSMutableDictionary<NSString *, NSData *> *_imageDataDic;
    NSMutableDictionary<NSString *, NSData *> *_thumbnailDataDic;
    NSMutableDictionary<NSString *, NSString *> *_imageUrlDic;
    NSMutableDictionary<NSString *, NSString *> *_thumbnailUrlDic;
}

@end

@implementation OSDataItem


#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone
{
    return self.tc_copy;
}

- (void)configValue:(id)value forProperty:(NSString *)property forApp:(NSString *)app
{
    if ([property isEqualToString:PropertySTR(title)]) {
        _titleDic[app] = value;
    } else if ([property isEqualToString:PropertySTR(desc)]) {
        _descDic[app] = value;
    } else if ([property isEqualToString:PropertySTR(link)]) {
        _linkDic[app] = value;
    } else if ([property isEqualToString:PropertySTR(imageData)]) {
        _imageDataDic[app] = value;
    } else if ([property isEqualToString:PropertySTR(thumbnailData)]) {
        _thumbnailDataDic[app] = value;
    } else if ([property isEqualToString:PropertySTR(imageUrl)]) {
        _imageUrlDic[app] = value;
    } else if ([property isEqualToString:PropertySTR(thumbnailUrl)]) {
        _thumbnailUrlDic[app] = value;
    }
}

- (NSMutableDictionary *)titleDic
{
    if (nil == _titleDic) {
        _titleDic = [NSMutableDictionary dictionary];
    }
    return _titleDic;
}

- (NSMutableDictionary *)descDic
{
    if (nil == _descDic) {
        _descDic = [NSMutableDictionary dictionary];
    }
    return _descDic;
}

- (NSMutableDictionary *)linkDic
{
    if (nil == _linkDic) {
        _linkDic = [NSMutableDictionary dictionary];
    }
    return _linkDic;
}

- (NSMutableDictionary *)imageDataDic
{
    if (nil == _imageDataDic) {
        _imageDataDic = [NSMutableDictionary dictionary];
    }
    return _imageDataDic;
}

- (NSMutableDictionary *)thumbnailDataDic
{
    if (nil == _thumbnailDataDic) {
        _thumbnailDataDic = [NSMutableDictionary dictionary];
    }
    return _thumbnailDataDic;
}

- (NSMutableDictionary *)imageUrlDic
{
    if (nil == _imageUrlDic) {
        _imageUrlDic = [NSMutableDictionary dictionary];
    }
    return _imageUrlDic;
}

- (NSMutableDictionary *)thumbnailUrlDic
{
    if (nil == _thumbnailUrlDic) {
        _thumbnailUrlDic = [NSMutableDictionary dictionary];
    }
    return _thumbnailUrlDic;
}

- (void)setTitle:(NSString *)title
{
    if (nil != title) {
        self.titleDic[kDefaultData] = title;
    }
}

- (void)setDesc:(NSString *)desc
{
    if (nil != desc) {
        self.descDic[kDefaultData] = desc;
    }
}

- (void)setLink:(NSString *)link
{
    if (nil != link) {
        self.linkDic[kDefaultData] = link;
    }
}

- (void)setImageData:(NSData *)imageData
{
    if (nil != imageData) {
        self.imageDataDic[kDefaultData] = imageData;
    }
}

- (void)setThumbnailData:(NSData *)thumbnailData
{
    if (nil != thumbnailData) {
        self.thumbnailDataDic[kDefaultData] = thumbnailData;
    }
}

- (void)setImageUrl:(NSString *)imageUrl
{
    if (nil != imageUrl) {
        self.imageUrlDic[kDefaultData] = imageUrl;
    }
}

- (void)setThumbnailUrl:(NSString *)thumbnailUrl
{
    if (nil != thumbnailUrl) {
        self.thumbnailUrlDic[kDefaultData] = thumbnailUrl;
    }
}

- (NSString *)title
{
    return self.titleDic[_scheme] ?: self.titleDic[kDefaultData];
}

- (NSString *)desc
{
    return self.descDic[_scheme] ?: self.descDic[kDefaultData];
}

- (NSString *)link
{
    return self.linkDic[_scheme] ?: self.linkDic[kDefaultData];
}

- (NSData *)imageData
{
    return self.imageDataDic[_scheme] ?: self.imageDataDic[kDefaultData];
}

- (NSData *)thumbnailData
{
    return self.thumbnailDataDic[_scheme] ?: self.thumbnailDataDic[kDefaultData];
}

- (NSString *)imageUrl
{
    return self.imageUrlDic[_scheme] ?: self.imageUrlDic[kDefaultData];
}

- (NSString *)thumbnailUrl
{
    return self.thumbnailUrlDic[_scheme] ?: self.thumbnailUrlDic[kDefaultData];
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

