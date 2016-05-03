//
//  OpenShare.h
//  OpenShare_2
//
//  Created by jia on 16/3/21.
//  Copyright © 2016年 Jia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OSDataItem.h"
#import "OSAppItem.h"

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

@interface OSMessage : NSObject

@property (nonatomic, strong) OSAppItem *appItem;
@property (nonatomic, strong) OSDataItem *dataItem;
@property (nonatomic, assign) OSMultimediaType multimediaType;
@property (nonatomic, copy) NSString *appScheme;

- (void)configDataItem:(void(^)(OSDataItem *item))config forApp:(NSString *)app;
- (void)configAppItem:(void(^)(OSAppItem *item))config forApp:(NSString *)app;

@end

// OpenShare
typedef NS_ENUM(NSInteger, OSPasteboardEncoding){
    kOSPasteboardEncodingKeyedArchiver,
    kOSPasteboardEncodingPropertyListSerialization
};

typedef void(^OSShareCompletionHandle)(NSError *error);

@interface OpenShare : NSObject

+ (OSShareCompletionHandle)shareCompletionHandle;

+ (BOOL)canOpenURL:(NSURL *)url;
+ (void)openAppWithURL:(NSURL *)url;
+ (BOOL)handleOpenURL:(NSURL *)url;

+ (void)registAppWithScheme:(NSString *)appScheme data:(NSDictionary *)data;
+ (NSDictionary *)dataForRegistedScheme:(NSString *)appScheme;
+ (BOOL)isAppRegisted:(NSString *)appScheme;

+ (BOOL)shouldOpenApp:(NSString *)appScheme message:(OSMessage *)msg completionHandle:(OSShareCompletionHandle)handle;

+ (void)setGeneralPasteboardData:(NSDictionary *)value forKey:(NSString *)key encoding:(OSPasteboardEncoding)encoding;
+ (NSDictionary *)generalPasteboardDataForKey:(NSString *)key encoding:(OSPasteboardEncoding)encoding;
+ (void)clearGeneralPasteboardDataForKey:(NSString *)key;

// 分享方法
+ (void)shareMsg:(OSMessage *)msg inController:(UIViewController *)ctrler defaultIconValid:(BOOL)defaultIconValid sns:(NSArray<NSNumber *> *)sns;

@end


