//
//  UIScrollView+TCHelper.m
//  TCKit
//
//  Created by dake on 16/4/19.
//  Copyright © 2016年 dake. All rights reserved.
//

#import "UIScrollView+TCHelper.h"
#import <objc/runtime.h>
#import "NSObject+TCUtilities.h"


@implementation UIScrollView (TCHelper)

@dynamic tc_touchesShouldCancelInContentViewBlock;


+ (void)load
{
    [self tc_swizzle:@selector(touchesShouldCancelInContentView:)];
}


- (BOOL (^)(UIView *, BOOL (^)(UIView *)))tc_touchesShouldCancelInContentViewBlock
{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setTc_touchesShouldCancelInContentViewBlock:(BOOL (^)(UIView * _Nonnull, BOOL (^ _Nonnull)(UIView * _Nonnull)))tc_touchesShouldCancelInContentViewBlock
{
    objc_setAssociatedObject(self, @selector(tc_touchesShouldCancelInContentViewBlock), tc_touchesShouldCancelInContentViewBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (BOOL)tc_touchesShouldCancelInContentView:(UIView *)view
{
    if (nil != self.tc_touchesShouldCancelInContentViewBlock) {
        return self.tc_touchesShouldCancelInContentViewBlock(view, ^BOOL (UIView *view){
            return [self tc_touchesShouldCancelInContentView:view];
        });
    }
    
    return [self tc_touchesShouldCancelInContentView:view];
}

@end
