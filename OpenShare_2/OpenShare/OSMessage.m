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
    NSMutableDictionary<NSString */*property*/, NSMutableDictionary */*{platform: customValue}*/> *_dataDic;
}

@end

@implementation OSDataItem
@dynamic title;
@dynamic desc;
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

- (NSMutableDictionary *)valueDicForKey:(NSString *)key;
{
    NSMutableDictionary *valueDic = _dataDic[key];
    if (nil == valueDic) {
        valueDic = [NSMutableDictionary dictionary];
        _dataDic[key] = valueDic;
    }
    return valueDic;
}

- (NSString *)getterStringFromSetter:(SEL)setter
{
    NSString *setterStr = NSStringFromSelector(setter);
    NSRange rangeOfStrSet = [setterStr rangeOfString:@"set"];
    NSString *getterStr = nil;
    if (rangeOfStrSet.location != NSNotFound) {
        CGFloat location = rangeOfStrSet.location + rangeOfStrSet.length;
        NSRange range = NSMakeRange(location, setterStr.length - location - 1);
        getterStr = [[setterStr substringWithRange:range] lowercaseString];
    }
    
    return getterStr;
}

- (void)setValue:(id)value forPlatform:(OSPlatform)platform withKey:(NSString *)key
{
    [self valueDicForKey:key][@(platform)] = value;
}

- (void)setValues:(NSArray *)values forKeys:(NSArray *)keys forPlatform:(OSPlatform)platform
{
    for (NSInteger i = 0; i < keys.count; i++) {
        [self valueDicForKey:keys[i]][@(platform)] = values[i];
    }
}

- (id)platformValueForKey:(NSString *)key
{
    NSMutableDictionary *valueDic = [self valueDicForKey:key];
    id value = valueDic[@(_platform)];
    if (nil == value) {
        value = valueDic[@(kOSPlatformUnknown)];
    }
    return value;
}

- (void)setTitle:(NSString *)title
{
    if (nil != title) {
        [self setValue:title forKey:[self getterStringFromSetter:_cmd] forPlatform:kOSPlatformUnknown];
    }
}

- (void)setDesc:(NSString *)desc
{
    if (nil != desc) {
        [self setValue:desc forKey:[self getterStringFromSetter:_cmd] forPlatform:kOSPlatformUnknown];
    }
}

- (void)setLink:(NSString *)link
{
    if (nil != link) {
        [self setValue:link forKey:[self getterStringFromSetter:_cmd] forPlatform:kOSPlatformUnknown];
    }
}

- (void)setImageData:(NSData *)imageData
{
    if (nil != imageData) {
        [self setValue:imageData forKey:[self getterStringFromSetter:_cmd] forPlatform:kOSPlatformUnknown];
    }
}

- (void)setThumbnailData:(NSData *)thumbnailData
{
    if (nil != thumbnailData) {
        [self setValue:thumbnailData forKey:[self getterStringFromSetter:_cmd] forPlatform:kOSPlatformUnknown];
    }
}

- (void)setImageUrl:(NSString *)imageUrl
{
    if (nil != imageUrl) {
        [self setValue:imageUrl forKey:[self getterStringFromSetter:_cmd] forPlatform:kOSPlatformUnknown];
    }
}

- (void)setThumbnailUrl:(NSString *)thumbnailUrl
{
    if (nil != thumbnailUrl) {
        [self setValue:thumbnailUrl forKey:[self getterStringFromSetter:_cmd] forPlatform:kOSPlatformUnknown];
    }
}

- (NSString *)title
{
   return [self platformValueForKey:NSStringFromSelector(_cmd)];
}

- (NSString *)desc
{
    return [self platformValueForKey:NSStringFromSelector(_cmd)];
}

- (NSString *)link
{
   return [self platformValueForKey:NSStringFromSelector(_cmd)];
}

- (NSData *)imageData
{
   return [self platformValueForKey:NSStringFromSelector(_cmd)];
}

- (NSData *)thumbnailData
{
   return [self platformValueForKey:NSStringFromSelector(_cmd)];
}

- (NSString *)imageUrl
{
   return [self platformValueForKey:NSStringFromSelector(_cmd)];
}

- (NSString *)thumbnailUrl
{
   return [self platformValueForKey:NSStringFromSelector(_cmd)];
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

