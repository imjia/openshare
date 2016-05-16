//
//  OpenShareManager.h
//  OpenShare_2
//
//  Created by jia on 16/5/3.
//  Copyright © 2016年 Jia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OpenShareHeader.h"
#import "OSPlatformController.h"

@class OSMessage;
@protocol OSUIDelegate;
@interface OpenShareManager : NSObject

@property (nonatomic, assign) BOOL ignoreNotInstalledApp;
@property (nonatomic, assign) BOOL remindInstall;
@property (nonatomic, weak) id<OSUIDelegate> uiDelegate;
@property (nonatomic, assign) void(^beforeDownloadImage)(); // 用户决定hud
@property (nonatomic, assign) void(^afterDownloadImage)(); // 用户决定hud

+ (instancetype)defaultManager;
- (void)shareMsg:(OSMessage *)msg platformCodes:(NSArray<NSNumber/*OSPlatformCode*/ *> *)codes completion:(OSShareCompletionHandle)completion;

@end

@protocol OSUIDelegate <NSObject>

@optional
- (void)didSelectPlatformItem:(OSPlatformItem *)platform message:(OSMessage *)message;

@end