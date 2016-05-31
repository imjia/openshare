//
//  UIScrollView+TCHelper.h
//  TCKit
//
//  Created by dake on 16/4/19.
//  Copyright © 2016年 dake. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIScrollView (TCHelper)

@property (nonatomic, copy) BOOL (^tc_touchesShouldCancelInContentViewBlock)(UIView * view, BOOL (^originalBlock)(UIView *view));

@end

NS_ASSUME_NONNULL_END