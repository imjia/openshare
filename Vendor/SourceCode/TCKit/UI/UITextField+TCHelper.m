//
//  UITextField+TCHelper.m
//  TCKit
//
//  Created by dake on 15/9/15.
//  Copyright (c) 2015年 dake. All rights reserved.
//

#import "UITextField+TCHelper.h"
#import <objc/runtime.h>


@interface TCTextFieldTarget : NSObject

+ (void)textFieldEditChanged:(UITextField *)textField;

@end


@implementation TCTextFieldTarget

+ (void)textFieldEditChanged:(UITextField *)textField
{
    NSString *toBeString = textField.text;
    UITextRange *selectedRange = textField.markedTextRange;
    // check highlight selection position
    UITextPosition *position = nil;
    if (nil != selectedRange) {
        position = [textField positionFromPosition:selectedRange.start offset:0];
    }
    // no highlight selection
    if (nil == position) {
        NSInteger maxLength = textField.tc_maxTextLength;
        
        if (maxLength >= 0 && toBeString.length > maxLength) {
            NSRange range = [toBeString rangeOfComposedCharacterSequenceAtIndex:maxLength];
            textField.text = [toBeString substringToIndex:range.location == NSNotFound ? maxLength : range.location];
        }
    } else {
    }
    
    id<TCTextFieldHelperDelegate> tc_delegate = textField.tc_delegate;
    if (nil != tc_delegate && [tc_delegate respondsToSelector:@selector(tc_textFieldValueChanged:)]) {
        [tc_delegate tc_textFieldValueChanged:textField];
    }
}

@end


@implementation UITextField (TCHelper)

- (id<TCTextFieldHelperDelegate>)tc_delegate
{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setTc_delegate:(id<TCTextFieldHelperDelegate>)tc_delegate
{
    objc_setAssociatedObject(self, @selector(tc_delegate), tc_delegate, OBJC_ASSOCIATION_ASSIGN);
    
    id target = (id)TCTextFieldTarget.class;
    if (![self.allTargets containsObject:target]) {
        [self addTarget:target action:@selector(textFieldEditChanged:) forControlEvents:UIControlEventEditingChanged];
    }
}


- (NSInteger)tc_maxTextLength
{
    NSNumber *value = objc_getAssociatedObject(self, _cmd);
    return nil == value ? -1 : value.integerValue;
}

- (void)setTc_maxTextLength:(NSInteger)tc_maxTextLength
{
    objc_setAssociatedObject(self, @selector(tc_maxTextLength), @(tc_maxTextLength), OBJC_ASSOCIATION_RETAIN);
    
    id target = (id)TCTextFieldTarget.class;
    if (![self.allTargets containsObject:target]) {
        [self addTarget:target action:@selector(textFieldEditChanged:) forControlEvents:UIControlEventEditingChanged];
    }
}

@end
