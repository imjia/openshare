//
//  TCPopupContainer.h
//  TCKit
//
//  Created by dake on 14-9-4.
//  Copyright (c) 2014年 dake. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, TCPopupStyle) {
    kTCPopupStyleCenter,
    kTCPopupStyleFromTop,
    kTCPopupStyleFade,
};

@interface TCPopupContainer : UIView

@property (nonatomic, assign) CGSize shownAreaSize; // default: CGSizeZero
@property (nonatomic, strong) UIViewController *shownCtrler;
@property (nonatomic, strong) UIView *containerView;

@property (nonatomic, assign) TCPopupStyle presentStyle; // default: TCPopupStyleCenter
@property (nonatomic, assign) BOOL disableTouchOutSide; // default: NO
@property (nonatomic, assign) BOOL shouldShowCloseBtn; // default: YES, only for TCPopupStyleCenter
@property (nonatomic, assign) BOOL shouldFlexContainerWidth; // default: NO, only for kTCPopupStyleFromTop
@property (nonatomic, assign) BOOL allowCustomContainerRect; // default: NO
@property (nonatomic, copy) void(^dismissdBlock)(void);

@property (nonatomic, strong) UIColor *maskBackgroundColor NS_AVAILABLE_IOS(5_0) UI_APPEARANCE_SELECTOR;

+ (BOOL)anyContainerVisible;

// animated YES
- (void)show;
- (void)dismiss;

- (void)show:(BOOL)animated;
- (void)dismiss:(BOOL)animated;

- (BOOL)isVisible;

- (UIImage *)closeImageForState:(UIControlState)state;

@end
