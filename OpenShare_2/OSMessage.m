//
//  OSMessage.m
//  OpenShare_2
//
//  Created by jia on 16/5/4.
//  Copyright © 2016年 Jia. All rights reserved.
//

#import "OSMessage.h"

#pragma mark - OSDataItem

@implementation OSDataItem


#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone
{
    return self.tc_copy;
}

- (NSString *)msgBody
{
    if (nil == _msgBody) {
        return _title;
    }
    return _msgBody;
}

- (NSString *)emailBody
{
    if (nil == _emailBody) {
        return _title;
    }
    return _emailBody;
}

@end


#pragma mark - OSAppItem

@implementation OSAppItem

@end


#pragma mark - OSMessage

static NSString *const kDefaultData = @"defaultData";

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
