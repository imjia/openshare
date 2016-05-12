//
//  OSSnsItemController.h
//  OpenShare_2
//
//  Created by jia on 16/5/3.
//  Copyright © 2016年 Jia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OpenShareConfig.h"

@class OSSnsItem;
@protocol OSSnsItemControllerDelegate;
@interface OSSnsItemController : UIViewController
@property (nonatomic, weak) id<OSSnsItemControllerDelegate> delegate;

- (instancetype)initWithSns:(NSArray<NSNumber *> *)sns;

@end

@protocol OSSnsItemControllerDelegate <NSObject>

@optional
- (void)OSSnsItemController:(OSSnsItemController *)ctrler didSelectSnsItem:(OSSnsItem *)sns;
- (void)OSSnsItemControllerWillDismiss:(OSSnsItemController *)ctrler;

@end

@interface OSSnsItem : NSObject

@property (nonatomic, copy) NSString *displayName; // 展示字段（国际化）
@property (nonatomic, strong) UIImage *displayIcon;
@property (nonatomic, assign) OSPlatform platform;

@end
