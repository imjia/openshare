//
//  UIViewController+TCHelper.h
//  TCKit
//
//  Created by dake on 15/3/10.
//  Copyright (c) 2015年 dake. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol TC_UIViewControllerCallback <NSObject>

@optional
- (void)tc_viewWillAppearCallback;
- (void)tc_viewDidDisappearCallback;

@end


typedef void (^TCViewControllerCallbackType)(UIViewController *ctrler);

@interface UIViewController (TCHelper) <TC_UIViewControllerCallback>

@property (nonatomic, assign) BOOL prefersStatusBarHidden;
@property (nonatomic, assign) UIStatusBarStyle preferredStatusBarStyle;
@property (nonatomic, assign) UIStatusBarAnimation preferredStatusBarUpdateAnimation;
@property (nonatomic, assign) UIInterfaceOrientationMask supportedInterfaceOrientations;

@property (nonatomic, assign) BOOL enableCustomTitleView; // default NO

@property (nonatomic, copy) TCViewControllerCallbackType viewWillAppearCallback;
@property (nonatomic, copy) TCViewControllerCallbackType viewWillDisappearCallback;
@property (nonatomic, copy) TCViewControllerCallbackType viewDidAppearCallback;
@property (nonatomic, copy) TCViewControllerCallbackType viewDidDisappearCallback;


+ (CGFloat)statusBarHeight;
- (CGFloat)statusBarHeight;
- (CGFloat)navigationBarHeight;



/**
 @brief	redo undo infrastructure
 注册 [self unexecuteInvocation:withRedoInvocation:] as undo
 手动注册
 
 @param invocation [IN] redo
 @param undoInvocation [IN] undo
 @param manager [IN] undoManager
 */
- (void)executeInvocation:(NSInvocation *)invocation
       withUndoInvocation:(NSInvocation *)undoInvocation
                  manager:(NSUndoManager *)manager;

/**
 @brief	redo undo infrastructure
 注册 [self executeInvocation:withUndoInvocation:] as redo
 被 NSUndoManager 注册
 
 @param invocation [IN] undo
 @param redoInvocation [IN] redo
 @param manager [IN] undoManager
 */
- (void)unexecuteInvocation:(NSInvocation *)invocation
         withRedoInvocation:(NSInvocation *)redoInvocation
                    manager:(NSUndoManager *)manager;

@end
