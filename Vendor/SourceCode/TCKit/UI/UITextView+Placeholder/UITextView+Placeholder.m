/*
 The MIT License (MIT)

 Copyright (c) 2014 Suyeol Jeon (http://xoul.kr)

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
*/

#import <objc/runtime.h>
#import "UITextView+Placeholder.h"

@implementation UITextView (Placeholder)

#pragma mark - Swizzle Dealloc

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self tc_swizzle:NSSelectorFromString(@"dealloc")];
    });
}

- (void)tc_dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if (nil != objc_getAssociatedObject(self, @selector(placeholderLabel))) {
        @try {
            for (NSString *key in self.class.observingKeys) {
                [self removeObserver:self forKeyPath:key];
            }
        }
        @catch (NSException *exception) {
            // Do nothing
        }
    }
    [self tc_dealloc];
}


#pragma mark - Class Methods
#pragma mark `defaultPlaceholderColor`

+ (UIColor *)defaultPlaceholderColor {
    static UIColor *color = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        UITextField *textField = [[UITextField alloc] init];
        textField.placeholder = @" ";
        color = [textField valueForKeyPath:@"_placeholderLabel.textColor"];
    });
    return color;
}


#pragma mark - `observingKeys`

+ (NSArray *)observingKeys {
    return @[@"attributedText",
             @"bounds",
             @"font",
             @"frame",
             @"text",
             @"textAlignment",
             @"textContainerInset"];
}


#pragma mark - Properties
#pragma mark `placeholderLabel`

- (UILabel *)placeholderLabel {
    UILabel *(^block) (void) = ^{
        UILabel *label = objc_getAssociatedObject(self, @selector(placeholderLabel));
        if (nil == label) {
            NSAttributedString *originalText = self.attributedText;
            self.text = @" "; // lazily set font of `UITextView`.
            self.attributedText = originalText;
            
            label = [[UILabel alloc] init];
            label.textColor = self.class.defaultPlaceholderColor;
            label.numberOfLines = 0;
            label.userInteractionEnabled = NO;
            objc_setAssociatedObject(self, @selector(placeholderLabel), label, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(updatePlaceholderLabel)
                                                         name:UITextViewTextDidChangeNotification
                                                       object:self];
            
            for (NSString *key in self.class.observingKeys) {
                [self addObserver:self forKeyPath:key options:NSKeyValueObservingOptionNew context:NULL];
            }
        }
        return label;
    };
    
    if (![NSThread isMainThread]) {
        __block UILabel *label = nil;
        dispatch_sync(dispatch_get_main_queue(), ^{
            label = block();
        });
        
        return label;
    }
    
    return block();
}


#pragma mark `placeholder`

- (NSString *)placeholder {
    return self.placeholderLabel.text;
}

- (void)setPlaceholder:(NSString *)placeholder {
    if ([NSThread isMainThread]) {
        self.placeholderLabel.text = placeholder;
        [self updatePlaceholderLabel];
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.placeholderLabel.text = placeholder;
            [self updatePlaceholderLabel];
        });
    }
}


#pragma mark `placeholderColor`

- (UIColor *)placeholderColor {
    return self.placeholderLabel.textColor;
}

- (void)setPlaceholderColor:(UIColor *)placeholderColor {
    self.placeholderLabel.textColor = placeholderColor;
}


#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if (object == self) {
        if ([self.class.observingKeys containsObject:keyPath]) {
            [self updatePlaceholderLabel];
        }
    }
}


#pragma mark - Update

- (void)updatePlaceholderLabel {
    if (self.text.length > 0) {
        [self.placeholderLabel removeFromSuperview];
        return;
    }

    [self insertSubview:self.placeholderLabel atIndex:0];

    self.placeholderLabel.font = self.font;
    self.placeholderLabel.textAlignment = self.textAlignment;

    // `NSTextContainer` is available since iOS 7
    CGFloat lineFragmentPadding;
    UIEdgeInsets textContainerInset;

#pragma deploymate push "ignored-api-availability"
    // iOS 7+
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
        lineFragmentPadding = self.textContainer.lineFragmentPadding;
        textContainerInset = self.textContainerInset;
    }
#pragma deploymate pop

    // iOS 6
    else {
        lineFragmentPadding = 5;
        textContainerInset = UIEdgeInsetsMake(8, 0, 8, 0);
    }

    CGFloat x = lineFragmentPadding + textContainerInset.left;
    CGFloat y = textContainerInset.top;
    CGFloat width = CGRectGetWidth(self.bounds) - x - lineFragmentPadding - textContainerInset.right;
    CGFloat height = [self.placeholderLabel sizeThatFits:CGSizeMake(width, 0)].height;
    self.placeholderLabel.frame = CGRectMake(x, y, width, height);
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
