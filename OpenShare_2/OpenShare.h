//
//  OpenShare.h
//  OpenShare_2
//
//  Created by jia on 16/3/21.
//  Copyright © 2016年 Jia. All rights reserved.
//

#import <Foundation/Foundation.h>

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

@property (nonatomic, strong) NSDictionary *dataDic;
@property (nonatomic, assign) OSMultimediaType multimediaType;
@property (nonatomic, copy) NSString *appScheme;

//for 微信
@property (nonatomic, copy) NSString *extInfo;
@property (nonatomic, copy) NSString *mediaDataUrl;
@property (nonatomic, copy) NSString *fileExt;
@property (nonatomic, strong) NSData *file;   /// 微信分享gif/文件

- (NSString *)title;
- (NSString *)desc;
- (NSString *)link;
- (UIImage *)image;
- (UIImage *)thumbImage;

- (NSData *)imageData;
- (NSData *)thumbnailData;

- (NSData *)wxFileData;
- (NSString *)wxExtInfo;
- (NSString *)wxFileExt;
- (void)setupObject:(id)object forKey:(NSString *)key forApp:(NSString *)app;

@end

// OpenShare
typedef NS_ENUM(NSInteger, OSPasteboardEncoding){
    kOSPasteboardEncodingKeyedArchiver,
    kOSPasteboardEncodingPropertyListSerialization
};

typedef void(^OSShareCompletionHandle)(BOOL success, NSError *error);

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

@end

