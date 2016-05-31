//
//  UILabel+TCHelper.h
//  TCKit
//
//  Created by dake on 15/3/10.
//  Copyright (c) 2015年 dake. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, TCTextVerticalAlignment) {
    TCTextVerticalAlignmentDefault = 0,
    TCTextVerticalAlignmentTop,
    TCTextVerticalAlignmentMiddle,
    TCTextVerticalAlignmentBottom,
};

@interface UILabel (TCHelper)

@property (nonatomic, assign) TCTextVerticalAlignment textVerticalAlignment;
@property (nonatomic, assign) UIEdgeInsets contentEdgeInsets;

@end
