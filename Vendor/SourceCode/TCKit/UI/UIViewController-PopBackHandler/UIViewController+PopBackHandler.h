//
//  UIViewController+PopBackHandler.h
//
//  Created by dake on 10/4/15.
//  Copyright 2013 dake. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TCPopBackHandlerProtocol <NSObject>
@optional
// Override this method in UIViewController derived class to handle 'Back' button click

/// only backBarButtonItem called
- (BOOL)tc_navigationShouldPopOnBackButton;

// both backBarButtonItem and interactivePopGestureRecognizer called
- (void)tc_navigationWillPopBackController;

@end

@interface UIViewController (TCPopBackHandler) <TCPopBackHandlerProtocol>

@end
