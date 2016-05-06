//
//  OSMessage.h
//  OpenShare_2
//
//  Created by jia on 16/5/4.
//  Copyright © 2016年 Jia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OpenShareConfig.h"

@class OSDataItem;
@class OSAppItem;

typedef NS_ENUM(NSInteger, OSMultimediaType) {
    OSMultimediaTypeUnknown,
    OSMultimediaTypeText,
    OSMultimediaTypeImage,
    OSMultimediaTypeNews,
    OSMultimediaTypeAudio,
    OSMultimediaTypeVideo,
    OSMultimediaTypeApp,
    OSMultimediaTypeFile
};


#pragma mark - OSMessage

@interface OSMessage : NSObject
@property (nonatomic, strong) OSAppItem *appItem; // 消息分享到的app {appid, appkey}
@property (nonatomic, strong) OSDataItem *dataItem; // 分享的消息内容
@property (nonatomic, assign) OSMultimediaType multimediaType; // 分享的类型
@property (nonatomic, copy) NSString *appScheme;

// 定制化app
- (void)configAppItem:(void(^)(OSAppItem *item))config forApp:(NSString *)app;

@end


#pragma mark - OSDataItem

@interface OSDataItem : NSObject

@property (nonatomic, strong) NSNumber *app;

// 公共
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *desc;
@property (nonatomic, copy) NSString *link;
@property (nonatomic, strong) NSData *imageData;
@property (nonatomic, strong) NSData *thumbnailData;
@property (nonatomic, copy) NSString *imageUrl; // 网络图片地址 imageUrl 优先
@property (nonatomic, copy) NSString *thumbnailUrl; // 网络缩略图地址

// 微信
@property (nonatomic, copy) NSString *mediaDataUrl;
@property (nonatomic, strong) NSData *wxFileData; // 微信分享gif/文件
@property (nonatomic, copy) NSString *wxExtInfo;
@property (nonatomic, copy) NSString *wxFileExt;

// 短信
@property (nonatomic, strong) NSArray<NSString *> *recipients; // 短信接收者的电话
@property (nonatomic, copy) NSString *msgBody;

// 邮件
@property (nonatomic, copy) NSString *emailSubject;
@property (nonatomic, copy) NSString *emailBody;

- (void)configValue:(id)value forProperty:(NSString *)property forApp:(NSNumber *)app;

@end


#pragma mark - OSAppItem

@interface OSAppItem : NSObject

@property (nonatomic, copy) NSString *appId;
@property (nonatomic, copy) NSString *callBackName;

@end
