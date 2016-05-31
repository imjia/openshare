//
//  UIViewController+TCHelper.m
//  TCKit
//
//  Created by dake on 15/3/10.
//  Copyright (c) 2015年 dake. All rights reserved.
//

#import "UIViewController+TCHelper.h"
#import <objc/runtime.h>
#import "NSObject+TCUtilities.h"

@implementation UIViewController (TCHelper)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self tc_swizzle:@selector(viewWillAppear:)];
        [self tc_swizzle:@selector(viewWillDisappear:)];
        [self tc_swizzle:@selector(viewDidAppear:)];
        [self tc_swizzle:@selector(viewDidDisappear:)];
        [self tc_swizzle:@selector(prefersStatusBarHidden)];
        [self tc_swizzle:@selector(preferredStatusBarStyle)];
        [self tc_swizzle:@selector(preferredStatusBarUpdateAnimation)];
        [self tc_swizzle:@selector(supportedInterfaceOrientations)];
    });
}


- (BOOL)tc_prefersStatusBarHidden
{
    NSNumber *value = objc_getAssociatedObject(self, @selector(setPrefersStatusBarHidden:));
    return nil != value ? value.boolValue : [self tc_prefersStatusBarHidden];
}

- (void)setPrefersStatusBarHidden:(BOOL)prefersStatusBarHidden
{
    objc_setAssociatedObject(self, _cmd, @(prefersStatusBarHidden), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIStatusBarStyle)tc_preferredStatusBarStyle
{
    NSNumber *value = objc_getAssociatedObject(self, @selector(setPreferredStatusBarStyle:));
    return nil != value ? value.integerValue : [self tc_preferredStatusBarStyle];
}

- (void)setPreferredStatusBarStyle:(UIStatusBarStyle)preferredStatusBarStyle
{
    objc_setAssociatedObject(self, _cmd, @(preferredStatusBarStyle), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIStatusBarAnimation)tc_preferredStatusBarUpdateAnimation
{
    NSNumber *value = objc_getAssociatedObject(self, @selector(setPreferredStatusBarUpdateAnimation:));
    return nil != value ? value.integerValue : [self tc_preferredStatusBarUpdateAnimation];
}

- (void)setPreferredStatusBarUpdateAnimation:(UIStatusBarAnimation)preferredStatusBarUpdateAnimation
{
    objc_setAssociatedObject(self, _cmd, @(preferredStatusBarUpdateAnimation), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIInterfaceOrientationMask)tc_supportedInterfaceOrientations
{
    NSNumber *value = objc_getAssociatedObject(self, @selector(setSupportedInterfaceOrientations:));
    return nil != value ? value.unsignedIntegerValue : [self tc_supportedInterfaceOrientations];
}

- (void)setSupportedInterfaceOrientations:(UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    objc_setAssociatedObject(self, _cmd, @(supportedInterfaceOrientations), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (BOOL)enableCustomTitleView
{
    NSNumber *value = objc_getAssociatedObject(self, @selector(setEnableCustomTitleView:));
    return nil != value ? value.boolValue : NO;
}

- (void)setEnableCustomTitleView:(BOOL)enableCustomTitleView
{
    objc_setAssociatedObject(self, _cmd, @(enableCustomTitleView), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (TCViewControllerCallbackType)viewWillAppearCallback
{
    return objc_getAssociatedObject(self, @selector(setViewWillAppearCallback:));
}

- (void)setViewWillAppearCallback:(TCViewControllerCallbackType)viewWillAppearCallback
{
    objc_setAssociatedObject(self, _cmd, viewWillAppearCallback, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (TCViewControllerCallbackType)viewWillDisappearCallback
{
    return objc_getAssociatedObject(self, @selector(setViewWillDisappearCallback:));
}

- (void)setViewWillDisappearCallback:(TCViewControllerCallbackType)viewWillDisappearCallback
{
    objc_setAssociatedObject(self, _cmd, viewWillDisappearCallback, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (TCViewControllerCallbackType)viewDidAppearCallback
{
    return objc_getAssociatedObject(self, @selector(setViewDidAppearCallback:));
}

- (void)setViewDidAppearCallback:(TCViewControllerCallbackType)viewDidAppearCallback
{
    objc_setAssociatedObject(self, _cmd, viewDidAppearCallback, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (TCViewControllerCallbackType)viewDidDisappearCallback
{
    return objc_getAssociatedObject(self, @selector(setViewDidDisappearCallback:));
}

- (void)setViewDidDisappearCallback:(TCViewControllerCallbackType)viewDidDisappearCallback
{
    objc_setAssociatedObject(self, _cmd, viewDidDisappearCallback, OBJC_ASSOCIATION_COPY_NONATOMIC);
}


#pragma mark - 

- (void)tc_viewWillAppear:(BOOL)animated
{
    [self tc_viewWillAppear:animated];
    
    if ([self respondsToSelector:@selector(tc_viewWillAppearCallback)]) {
        [self tc_viewWillAppearCallback];
    }
    
    if (nil != self.viewWillAppearCallback) {
        self.viewWillAppearCallback(self);
    }
    
    // titleView container
    if (self.enableCustomTitleView && nil == self.navigationItem.titleView) {
        
        UIView *titleContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 160.0f, self.navigationBarHeight)];
        titleContainer.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin
        | UIViewAutoresizingFlexibleRightMargin
        | UIViewAutoresizingFlexibleHeight;
        titleContainer.backgroundColor = [UIColor clearColor];
        
        self.navigationItem.titleView = titleContainer;
    }
}

- (void)tc_viewWillDisappear:(BOOL)animated
{
    [self tc_viewWillDisappear:animated];
    
    if (nil != self.viewWillDisappearCallback) {
        self.viewWillDisappearCallback(self);
    }
}

- (void)tc_viewDidAppear:(BOOL)animated
{
    [self tc_viewDidAppear:animated];
    
    if (nil != self.viewDidAppearCallback) {
        self.viewDidAppearCallback(self);
    }
}

- (void)tc_viewDidDisappear:(BOOL)animated
{
    [self tc_viewDidDisappear:animated];
    if ([self respondsToSelector:@selector(tc_viewDidDisappearCallback)]) {
        [self tc_viewDidDisappearCallback];
    }
    
    if (nil != self.viewDidDisappearCallback) {
        self.viewDidDisappearCallback(self);
    }
}

+ (CGFloat)statusBarHeight
{
    // Landscape mode on iPad, the [UIApplication sharedApplication].statusBarFrame.size.height is bigger, so we get the smaller
    CGSize size = [UIApplication sharedApplication].statusBarFrame.size;
    return MIN(size.width, size.height);
}

- (CGFloat)statusBarHeight
{
    return self.class.statusBarHeight;
}

- (CGFloat)navigationBarHeight
{
    return self.navigationController.isNavigationBarHidden ? 0 : self.navigationController.navigationBar.bounds.size.height;
}


#pragma mark - register redo undo Command Methods

- (void)executeInvocation:(NSInvocation *)invocation
       withUndoInvocation:(NSInvocation *)undoInvocation
                  manager:(NSUndoManager *)manager
{
    if (!invocation.argumentsRetained) {
        [invocation retainArguments];
    }
    
    if (!undoInvocation.argumentsRetained) {
        [undoInvocation retainArguments];
    }
    
    [[manager prepareWithInvocationTarget:self]
     unexecuteInvocation:undoInvocation
     withRedoInvocation:invocation
     manager:manager];
    
    [invocation invoke];
}

- (void)unexecuteInvocation:(NSInvocation *)invocation
         withRedoInvocation:(NSInvocation *)redoInvocation
                    manager:(NSUndoManager *)manager
{
    if (!invocation.argumentsRetained) {
        [invocation retainArguments];
    }
    
    [[manager prepareWithInvocationTarget:self]
     executeInvocation:redoInvocation
     withUndoInvocation:invocation
     manager:manager];
    
    [invocation invoke];
}

@end
