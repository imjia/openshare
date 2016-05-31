//
//  UILabel+TCHelper.m
//  TCKit
//
//  Created by dake on 15/3/10.
//  Copyright (c) 2015年 dake. All rights reserved.
//

#import "UILabel+TCHelper.h"
#import <objc/runtime.h>

static char const kTextVerticalAlignmentKey;
static char const kContentEdgeInsetsKey;

@implementation UILabel (TCHelper)

@dynamic contentEdgeInsets;

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        method_exchangeImplementations(class_getInstanceMethod(self, @selector(textRectForBounds:limitedToNumberOfLines:)), class_getInstanceMethod(self, @selector(verticalAlignTextRectForBounds:limitedToNumberOfLines:)));
        method_exchangeImplementations(class_getInstanceMethod(self, @selector(drawTextInRect:)), class_getInstanceMethod(self, @selector(verticalAlignDrawTextInRect:)));
    });
}

- (UIEdgeInsets)contentEdgeInsets
{
    NSValue *value = objc_getAssociatedObject(self, &kContentEdgeInsetsKey);
    return nil != value ? [value UIEdgeInsetsValue] : UIEdgeInsetsZero;
}

- (void)setContentEdgeInsets:(UIEdgeInsets)contentEdgeInsets
{
    objc_setAssociatedObject(self, &kContentEdgeInsetsKey, [NSValue valueWithUIEdgeInsets:contentEdgeInsets], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self setNeedsDisplay];
}

- (TCTextVerticalAlignment)textVerticalAlignment
{
    NSNumber *alignment = objc_getAssociatedObject(self, &kTextVerticalAlignmentKey);
    
    if (nil != alignment) {
        return alignment.integerValue;
    }
    
    objc_setAssociatedObject(self, &kTextVerticalAlignmentKey, @(TCTextVerticalAlignmentDefault), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return TCTextVerticalAlignmentDefault;
}

- (void)setTextVerticalAlignment:(TCTextVerticalAlignment)textVerticalAlignment
{
    objc_setAssociatedObject(self, &kTextVerticalAlignmentKey, @(textVerticalAlignment), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self setNeedsDisplay];
}

- (CGRect)verticalAlignTextRectForBounds:(CGRect)bounds limitedToNumberOfLines:(NSInteger)numberOfLines
{
    CGRect textRect = [self verticalAlignTextRectForBounds:bounds limitedToNumberOfLines:numberOfLines];
    
    switch (self.textVerticalAlignment) {
        case TCTextVerticalAlignmentTop:
            textRect.origin.y = bounds.origin.y;
            break;
            
        case TCTextVerticalAlignmentBottom:
            textRect.origin.y = bounds.origin.y + bounds.size.height - textRect.size.height;
            break;
            
        case TCTextVerticalAlignmentDefault:
        case TCTextVerticalAlignmentMiddle:
            textRect.origin.y = bounds.origin.y + (bounds.size.height - textRect.size.height) / 2.0;
            break;
            
        default:
            break;
    }
    
    return textRect;
}

- (void)verticalAlignDrawTextInRect:(CGRect)rect
{
    CGRect fixRect = rect;
    UIEdgeInsets edge = self.contentEdgeInsets;
    if (self.textVerticalAlignment != TCTextVerticalAlignmentDefault || !UIEdgeInsetsEqualToEdgeInsets(edge, UIEdgeInsetsZero)) {
        CGRect actualRect = [self textRectForBounds:rect limitedToNumberOfLines:self.numberOfLines];
        fixRect = UIEdgeInsetsInsetRect(actualRect, edge);
    }
    [self verticalAlignDrawTextInRect:fixRect];
}



@end
