//
//  OpenShare.h
//  OpenShare_2
//
//  Created by jia on 16/3/21.
//  Copyright © 2016年 Jia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OSMessage.h"
#import "OpenShareConfig.h"

typedef NS_ENUM(NSInteger, OSPasteboardEncoding){
    kOSPasteboardEncodingKeyedArchiver,
    kOSPasteboardEncodingPropertyListSerialization
};

typedef void(^OSShareCompletionHandle)(OSPlatform platform, OSShareState state, NSString *errorDescription);

@interface OpenShare : NSObject

+ (OSShareCompletionHandle)shareCompletionHandle;

+ (BOOL)canOpenURL:(NSURL *)url;
+ (void)openAppWithURL:(NSURL *)url completionHandle:(OSShareCompletionHandle)handle;
+ (BOOL)handleOpenURL:(NSURL *)url;

+ (void)registAppWithScheme:(NSString *)appScheme data:(NSDictionary *)data;
+ (NSDictionary *)dataForRegistedScheme:(NSString *)appScheme;
+ (BOOL)isAppRegisted:(NSString *)appScheme;

+ (void)setGeneralPasteboardData:(NSDictionary *)value forKey:(NSString *)key encoding:(OSPasteboardEncoding)encoding;
+ (NSDictionary *)generalPasteboardDataForKey:(NSString *)key encoding:(OSPasteboardEncoding)encoding;
+ (void)clearGeneralPasteboardDataForKey:(NSString *)key;

@end


