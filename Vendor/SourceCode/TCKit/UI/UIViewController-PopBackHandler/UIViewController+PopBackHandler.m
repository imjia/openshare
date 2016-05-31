//
//  UIViewController+PopBackHandler.m
//
//  Created by dake on 10/4/15.
//  Copyright 2013 dake. All rights reserved.
//

#import "UIViewController+PopBackHandler.h"
#import <objc/runtime.h>

@implementation UINavigationController (TCPopBackHandler)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self tc_swizzle:@selector(navigationBar:shouldPopItem:)];
        [self tc_swizzle:@selector(popViewControllerAnimated:)];
        [self tc_swizzle:@selector(popToViewController:animated:)];
        [self tc_swizzle:@selector(popToRootViewControllerAnimated:)];
    });
}


#pragma mark - UINavigationBarDelegate

- (nullable UIViewController *)tc_popViewControllerAnimated:(BOOL)animated
{
    UIViewController *vc = self.topViewController;
    [vc.view endEditing:YES];
    if ([vc respondsToSelector:@selector(tc_navigationWillPopBackController)]) {
        [vc tc_navigationWillPopBackController];
    }
    return [self tc_popViewControllerAnimated:animated];
}

- (nullable NSArray<__kindof UIViewController *> *)tc_popToViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    UIViewController *vc = self.topViewController;
    [vc.view endEditing:YES];
    if ([vc respondsToSelector:@selector(tc_navigationWillPopBackController)]) {
        [vc tc_navigationWillPopBackController];
    }
    
    return [self tc_popToViewController:viewController animated:animated];
}

- (nullable NSArray<__kindof UIViewController *> *)tc_popToRootViewControllerAnimated:(BOOL)animated
{
    UIViewController *vc = self.topViewController;
    [vc.view endEditing:YES];
    if ([vc respondsToSelector:@selector(tc_navigationWillPopBackController)]) {
        [vc tc_navigationWillPopBackController];
    }
    
    return [self tc_popToRootViewControllerAnimated:animated];
}


- (BOOL)tc_navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item
{
    BOOL shouldPop = YES;
    // normal pop
    if (self.viewControllers.count != navigationBar.items.count) {
        return [self tc_navigationBar:navigationBar shouldPopItem:item];
    }
    
    UIViewController *vc = self.topViewController;
    if ([vc respondsToSelector:@selector(tc_navigationShouldPopOnBackButton)]) {
        shouldPop = [vc tc_navigationShouldPopOnBackButton];
    }
    
    if (shouldPop) {
        return [self tc_navigationBar:navigationBar shouldPopItem:item];
    } else {
        // Workaround for iOS7.1 and iOS9.2. Thanks to @boliva - http://stackoverflow.com/posts/comments/34452906
        NSArray *subviews = [navigationBar.subviews filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"alpha < 1.0"]];
        
        if (subviews.count > 0) {
            [UIView animateWithDuration:0.25f animations:^{
                [subviews setValue:@1.0f forKeyPath:@"alpha"];
            }];
        }
    }
    
    return shouldPop;
}


#ifndef __TCKit__
#pragma mark - helper

+ (void)tc_swizzle:(SEL)aSelector
{
    SEL bSelector = NSSelectorFromString([NSString stringWithFormat:@"tc_%@", NSStringFromSelector(aSelector)]);
    Method m1 = class_getInstanceMethod(self, aSelector);
    Method m2 = NULL;
    if (NULL == m1) {
        m1 = class_getClassMethod(self, aSelector);
        m2 = class_getClassMethod(self, bSelector);
    } else {
        m2 = class_getInstanceMethod(self, bSelector);
    }
    
    const char *type = method_getTypeEncoding(m2);
    if (class_addMethod(self, aSelector, method_getImplementation(m2), method_getTypeEncoding(m2))) {
        if (NULL != m1) {
            class_replaceMethod(self, bSelector, method_getImplementation(m1), method_getTypeEncoding(m1));
        } else { // original method not exist, then add one
            char *rtType = method_copyReturnType(m2);
            NSString *returnType = nil;
            char value = @encode(void)[0];
            if (NULL != rtType) {
                value = rtType[0];
                returnType = @(rtType);
                free(rtType), rtType = NULL;
            }
            
            IMP imp = NULL;
            
            if (value == @encode(void)[0]) {
                imp = imp_implementationWithBlock(^{});
            } else if (value == @encode(id)[0]) {
                imp = imp_implementationWithBlock(^{return nil;});
            } else if (value == @encode(Class)[0]) {
                imp = imp_implementationWithBlock(^{return Nil;});
            } else if (value == @encode(SEL)[0] || value == @encode(void *)[0] || value == @encode(int[1])[0]) {
                imp = imp_implementationWithBlock(^{return NULL;});
            } else if ([returnType isEqualToString:@(@encode(CGPoint))]) {
                imp = imp_implementationWithBlock(^{return CGPointZero;});
            } else if ([returnType isEqualToString:@(@encode(CGSize))]) {
                imp = imp_implementationWithBlock(^{return CGSizeZero;});
            } else if ([returnType isEqualToString:@(@encode(CGRect))]) {
                imp = imp_implementationWithBlock(^{return CGRectZero;});
            } else if ([returnType isEqualToString:@(@encode(CGAffineTransform))]) {
                imp = imp_implementationWithBlock(^{return CGAffineTransformIdentity;});
            } else if ([returnType isEqualToString:@(@encode(UIEdgeInsets))]) {
                imp = imp_implementationWithBlock(^{return UIEdgeInsetsZero;});
            } else if ([returnType isEqualToString:@(@encode(NSRange))]) {
                imp = imp_implementationWithBlock(^{return NSMakeRange(NSNotFound, 0);});
            } else if (value == @encode(CGPoint)[0] || value == '(') { // FIXME: 0
                imp = imp_implementationWithBlock(^{return 0;});
            } else {
                imp = imp_implementationWithBlock(^{return 0;});
            }
            
            class_replaceMethod(self, bSelector, imp, type);
            imp_removeBlock(imp);
        }
    } else {
        method_exchangeImplementations(m1, m2);
    }
}

#endif

@end
