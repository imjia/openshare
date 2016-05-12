//
//  OpenShareManager.h
//  OpenShare_2
//
//  Created by jia on 16/5/3.
//  Copyright © 2016年 Jia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OpenShareHeader.h"
#import "OSSnsItemController.h"

@class OSMessage;
@protocol OSSnsUIDelegate;
@interface OpenShareManager : NSObject

@property (nonatomic, assign) BOOL ignoreNotInstalledApp;
@property (nonatomic, assign) BOOL remindInstall;
@property (nonatomic, weak) id<OSSnsUIDelegate> uiDelegate;
@property (nonatomic, assign) void(^beforeDownloadImage)(); // 用户决定hud
@property (nonatomic, assign) void(^afterDownloadImage)(); // 用户决定hud

+ (instancetype)defaultManager;
- (void)shareMsg:(OSMessage *)msg sns:(NSArray<NSNumber/*OSPlatform*/ *> *)sns completion:(OSShareCompletionHandle)completion;

@end

@protocol OSSnsUIDelegate <NSObject>

@optional
- (void)didSelectSnsItem:(OSSnsItem *)sns message:(OSMessage *)message;

@end
