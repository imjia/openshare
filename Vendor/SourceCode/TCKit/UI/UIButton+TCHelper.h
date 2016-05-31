//
//  UIButton+TCHelper.h
//  TCKit
//
//  Created by dake on 15/1/24.
//  Copyright (c) 2015年 dake. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef NS_ENUM(NSInteger, TCButtonLayoutStyle) {
    kTCButtonLayoutStyleDefault = 0,
    kTCButtonLayoutStyleImageLeftTitleRight,
    kTCButtonLayoutStyleImageRightTitleLeft,
    kTCButtonLayoutStyleImageTopTitleBottom,
    kTCButtonLayoutStyleImageBottomTitleTop,
};

@interface UIButton (TCHelper)

@property (nonatomic, assign) UIEdgeInsets alignmentRectInsets;
@property (nonatomic, assign) CGFloat paddingBetweenTitleAndImage;

@property (nonatomic, assign) TCButtonLayoutStyle layoutStyle;

/**
 @brief set underline
 
 !!!: shout set behind setTitle:ForState: setTitleColor:ForState:
 
 NSMutableAttributedString *titleString = [[NSMutableAttributedString alloc] initWithString:@"The Underlined text"];
 
 // making text property to underline text-
 [titleString addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange(0, [titleString length])];
 
 // using text on button
 [button setAttributedTitle: titleString forState:UIControlStateNormal];
 
 */
- (void)setEnableUnderline:(BOOL)enableUnderline; // default: NO


- (void)resetImageAndTitleEdges;
- (void)updateLayoutStyle;

- (void)setLayoutSizeNeedChange:(void(^)(CGSize layoutSize))block;


- (UIColor *)backgroundColorForState:(UIControlState)state;
- (void)setBackgroundColor:(UIColor *)color forState:(UIControlState)state;

- (UIColor *)borderColorForState:(UIControlState)state;
- (void)setBorderColor:(UIColor *)color forState:(UIControlState)state;


@end
