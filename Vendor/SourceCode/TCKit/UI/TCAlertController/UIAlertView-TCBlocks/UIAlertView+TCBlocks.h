//
//  UIAlertView+TCBlocks.h
//  TCKit
//
//  Created by dake on 15/3/12.
//  Copyright (c) 2015年 dake. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TCAlertAction;
@interface UIAlertView (TCBlocks)

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message cancelAction:(TCAlertAction *)cancelAction otherActions:(NSArray<TCAlertAction *> *)otherActions;
- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message cancelAction:(TCAlertAction *)cancelAction otherAction:(TCAlertAction *)otherAction, ... NS_REQUIRES_NIL_TERMINATION;

- (void)addAction:(TCAlertAction *)action;

@end
