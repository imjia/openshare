//
//  UIButton+TCHelper.m
//  TCKit
//
//  Created by dake on 15/1/24.
//  Copyright (c) 2015年 dake. All rights reserved.
//

#import "UIButton+TCHelper.h"
#import <objc/runtime.h>


@interface UIButton (TCLayoutStyle)

- (void)updateLayoutStyle;

@end

@interface TCButtonExtra : NSObject

@property (nonatomic, assign) UIEdgeInsets alignmentRectInsets;
@property (nonatomic, assign) CGFloat paddingBetweenTitleAndImage;
@property (nonatomic, strong) NSMutableDictionary *innerBackgroundColorDic;
@property (nonatomic, strong) NSMutableDictionary *borderColorDic;
@property (nonatomic, weak) UIButton *target;
@property (nonatomic, assign) TCButtonLayoutStyle layoutStyle;
@property (nonatomic, assign) BOOL isFrameObserved;

@end

@implementation TCButtonExtra

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == self.target || object == self.target.imageView) {
        if ([keyPath isEqualToString:@"highlighted"] || [keyPath isEqualToString:@"selected"] || [keyPath isEqualToString:@"enabled"]) {
            NSNumber *state = @(_target.state);
            self.target.backgroundColor = self.innerBackgroundColorDic[state];
            self.target.layer.borderColor = [(UIColor *)self.borderColorDic[state] CGColor];
            
        } else if ([keyPath isEqualToString:@"bounds"] || [keyPath isEqualToString:@"frame"]) {
            CGRect oldFrame = [(NSValue *)change[NSKeyValueChangeOldKey] CGRectValue];
            CGRect newFrame = [(NSValue *)change[NSKeyValueChangeNewKey] CGRectValue];
            
            if (!CGSizeEqualToSize(oldFrame.size, newFrame.size)) {
                [self.target updateLayoutStyle];
            }
        }
    }
}


@end



static char const kBtnExtraKey;

@implementation UIButton (TCHelper)

@dynamic layoutStyle;
@dynamic alignmentRectInsets;
@dynamic paddingBetweenTitleAndImage;

- (void)tc_dealloc
{
    TCButtonExtra *observer = objc_getAssociatedObject(self, &kBtnExtraKey);
    if (nil != observer) {
        if (observer.isFrameObserved) {
            [self removeFrameObserver:observer];
        }
        
        if (nil != observer.innerBackgroundColorDic || nil != observer.borderColorDic) {
            [self removeStateObserver:observer];
        }
        objc_setAssociatedObject(self, &kBtnExtraKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    [self tc_dealloc];
}

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // ARC forbids us to use a selector on dealloc, so we must trick it with NSSelectorFromString()
        [self tc_swizzle:NSSelectorFromString(@"dealloc")];
        [self tc_swizzle:@selector(setImage:forState:)];
        [self tc_swizzle:@selector(setTitle:forState:)];
        [self tc_swizzle:@selector(setAttributedTitle:forState:)];
    });
}

- (TCButtonExtra *)btnExtra
{
    TCButtonExtra *observer = objc_getAssociatedObject(self, &kBtnExtraKey);
    
    if (nil == observer) {
        observer = [[TCButtonExtra alloc] init];
        observer.target = self;
        objc_setAssociatedObject(self, &kBtnExtraKey, observer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    return observer;
}

- (void)tc_setImage:(UIImage *)image forState:(UIControlState)state
{
    UIImage *oldImg = [self imageForState:state];
    [self tc_setImage:image forState:state];
    if (oldImg != image && !CGRectIsEmpty(self.frame)) {
        [self updateLayoutStyle];
    }
}

- (void)tc_setTitle:(NSString *)title forState:(UIControlState)state
{
    NSString *oldTitle = [self titleForState:state];
    [self tc_setTitle:title forState:state];
    if (![oldTitle isEqualToString:title] && !CGRectIsEmpty(self.frame)) {
        [self updateLayoutStyle];
    }
}

- (void)tc_setAttributedTitle:(NSAttributedString *)title forState:(UIControlState)state
{
    NSAttributedString *oldTitle = [self attributedTitleForState:state];
    [self tc_setAttributedTitle:title forState:state];
    if (![oldTitle isEqual:title] && !CGRectIsEmpty(self.frame)) {
        [self updateLayoutStyle];
    }
}

#pragma mark -  underline

- (void)setUnderlineAtrributedStringForState:(UIControlState)state
{
    NSMutableAttributedString *titleString = nil;
    
    NSString *title = [self titleForState:state];
    if (nil != title) {
        
        titleString = [[NSMutableAttributedString alloc] initWithString:title];
        [titleString addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleSingle) range:NSMakeRange(0, titleString.length)];
        UIColor *color = [self titleColorForState:state];
        if (nil == color) {
            color = [self titleColorForState:UIControlStateNormal];
        }
        if (nil != color) {
            [titleString addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0, titleString.length)];
        }
    } else {
        UIColor *color = [self titleColorForState:state];
        if (nil != color) {
            title = [self titleForState:UIControlStateNormal];
            if (nil != title) {
                titleString = [[NSMutableAttributedString alloc] initWithString:title];
                [titleString addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleSingle) range:NSMakeRange(0, titleString.length)];
                [titleString addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0, titleString.length)];
            }
        }
    }
    
    [self setAttributedTitle:titleString forState:state];
}

- (void)setEnableUnderline:(BOOL)enableUnderline
{
    if (enableUnderline) {
        NSString *title = [self titleForState:UIControlStateNormal];
        if (nil != title) {
            NSMutableAttributedString *titleString = [[NSMutableAttributedString alloc] initWithString:title];
            [titleString addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleSingle) range:NSMakeRange(0, titleString.length)];
            UIColor *color = [self titleColorForState:UIControlStateNormal];
            if (nil != color) {
                [titleString addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0, titleString.length)];
            }
            [self setAttributedTitle:titleString forState:UIControlStateNormal];
        }
        
        [self setUnderlineAtrributedStringForState:UIControlStateHighlighted];
        [self setUnderlineAtrributedStringForState:UIControlStateSelected];
        [self setUnderlineAtrributedStringForState:UIControlStateDisabled];
        [self setUnderlineAtrributedStringForState:UIControlStateHighlighted | UIControlStateSelected];
    } else {
        [self setAttributedTitle:nil forState:UIControlStateNormal];
        [self setAttributedTitle:nil forState:UIControlStateHighlighted];
        [self setAttributedTitle:nil forState:UIControlStateSelected];
        [self setAttributedTitle:nil forState:UIControlStateDisabled];
        [self setAttributedTitle:nil forState:UIControlStateHighlighted | UIControlStateSelected];
    }
}


#pragma mark - alignmentRectInsets

- (UIEdgeInsets)alignmentRectInsets
{
    return self.btnExtra.alignmentRectInsets;
}

- (void)setAlignmentRectInsets:(UIEdgeInsets)alignmentRectInsets
{
    self.btnExtra.alignmentRectInsets = alignmentRectInsets;
}


#pragma mark - layoutStyle

- (void)addFrameObserver:(id)observer
{
    [self addObserver:observer forKeyPath:@"bounds" options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:NULL];
    [self addObserver:observer forKeyPath:@"frame" options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:NULL];
}

- (void)removeFrameObserver:(id)observer
{
    [self removeObserver:observer forKeyPath:@"bounds" context:NULL];
    [self removeObserver:observer forKeyPath:@"frame" context:NULL];
}

- (TCButtonLayoutStyle)layoutStyle
{
    return self.btnExtra.layoutStyle;
}

- (void)setLayoutStyle:(TCButtonLayoutStyle)layoutStyle
{
    TCButtonExtra *btnExtra = self.btnExtra;
    if (btnExtra.layoutStyle == layoutStyle) {
        return;
    }
    
    btnExtra.layoutStyle = layoutStyle;
    
    if (!CGRectIsEmpty(self.frame)) {
        [self updateLayoutStyle];
    }
    
    if (layoutStyle != kTCButtonLayoutStyleDefault) {
        if (!btnExtra.isFrameObserved) {
            [self addFrameObserver:btnExtra];
            btnExtra.isFrameObserved = YES;
        }
    } else {
        if (btnExtra.isFrameObserved) {
            [self removeFrameObserver:btnExtra];
            btnExtra.isFrameObserved = NO;
            [self resetImageAndTitleEdges];
        }
    }
}

- (CGFloat)paddingBetweenTitleAndImage
{
    return self.btnExtra.paddingBetweenTitleAndImage;
}

- (void)setPaddingBetweenTitleAndImage:(CGFloat)paddingBetweenTitleAndImage
{
    self.btnExtra.paddingBetweenTitleAndImage = paddingBetweenTitleAndImage;
}

- (void(^)(CGSize layoutSize))layoutSizeNeedChangeBlock
{
    return (void(^)(CGSize layoutSize))objc_getAssociatedObject(self, @selector(setLayoutSizeNeedChange:));
}

- (void)setLayoutSizeNeedChange:(void(^)(CGSize layoutSize))block
{
    objc_setAssociatedObject(self, _cmd, block, OBJC_ASSOCIATION_COPY_NONATOMIC);
}


- (void)updateLayoutStyle
{
    switch (self.layoutStyle) {
        case kTCButtonLayoutStyleImageLeftTitleRight:
            [self imageAndTitleToFitHorizonal];
            break;
            
        case kTCButtonLayoutStyleImageRightTitleLeft:
            [self imageAndTitleToFitHorizonalReverse];
            break;
            
        case kTCButtonLayoutStyleImageTopTitleBottom:
            [self imageAndTitleToFitVertical:YES];
            break;
            
        case kTCButtonLayoutStyleImageBottomTitleTop:
            [self imageAndTitleToFitVertical:NO];
            break;
            
        default:
            break;
    }
}

- (void)noFrameKVOPerform:(dispatch_block_t)block
{
    if (nil == block) {
        return;
    }
    
    TCButtonExtra *btnExtra = self.btnExtra;
    BOOL observed = btnExtra.isFrameObserved;
    if (observed) {
        [self removeFrameObserver:btnExtra];
        btnExtra.isFrameObserved = NO;
    }
    
    block();
    dispatch_async(dispatch_get_main_queue(), ^{
        if (observed && !btnExtra.isFrameObserved) {
            [self addFrameObserver:btnExtra];
            btnExtra.isFrameObserved = YES;
        }
    });
}

- (void)imageAndTitleToFitVertical:(BOOL)up
{
    if (nil != self.titleLabel && nil != self.imageView) {
        
        self.titleEdgeInsets = UIEdgeInsetsZero;
        self.imageEdgeInsets = UIEdgeInsetsZero;
        
        self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        
        CGRect contentRect = [self contentRectForBounds:self.bounds];
        CGSize imageSize = [self imageRectForContentRect:contentRect].size;
        
        self.titleEdgeInsets = UIEdgeInsetsMake(0, -imageSize.width, 0, 0);
        contentRect = [self contentRectForBounds:self.bounds];
        CGSize titleSize = [self titleRectForContentRect:contentRect].size;
        
        CGSize size = contentRect.size;
        CGFloat pad = self.paddingBetweenTitleAndImage * 0.5;
        CGFloat r = (titleSize.height + imageSize.height) * 0.5 - MIN(titleSize.height, imageSize.height);
        CGFloat border = self.layer.borderWidth;
        
        if (up) {
            self.imageEdgeInsets = UIEdgeInsetsMake(-imageSize.height * 0.5 - pad + border + r, (size.width - imageSize.width) * 0.5, imageSize.height * 0.5 + pad - border - r, -(size.width - imageSize.width) * 0.5);
            self.titleEdgeInsets = UIEdgeInsetsMake(titleSize.height * 0.5 + pad + border + r, (size.width - titleSize.width) * 0.5 - imageSize.width, -titleSize.height * 0.5 - pad - border - r, 0);
        } else {
            self.imageEdgeInsets = UIEdgeInsetsMake(imageSize.height * 0.5 + pad - r, (size.width - imageSize.width) * 0.5, -imageSize.height * 0.5 - pad + r, -titleSize.width);
            self.titleEdgeInsets = UIEdgeInsetsMake(-titleSize.height * 0.5 - pad - r, (size.width - titleSize.width) * 0.5 - imageSize.width, titleSize.height * 0.5 + pad + r, 0);
        }
        
        CGSize dstSize = CGSizeMake(MAX(imageSize.width, titleSize.width) + border * 2, imageSize.height + titleSize.height + self.paddingBetweenTitleAndImage + border * 2);
        if (!CGSizeEqualToSize(size, dstSize)) {
            if (nil != self.layoutSizeNeedChangeBlock) {
                self.layoutSizeNeedChangeBlock(dstSize);
            }
        }
        
//        self.backgroundColor = [UIColor yellowColor];
//        self.titleLabel.backgroundColor = [UIColor redColor];
        
        //            CGFloat expand = (titleSize.height + imageSize.height - size.height) * 0.5 + pad + border;
        //            CGRect bounds = self.bounds;
        //            bounds.size.height += expand * 2;
        //            self.bounds = bounds;
    }
}

- (void)imageAndTitleToFitHorizonalReverse
{
    if (nil != self.titleLabel && nil != self.imageView) {
        self.titleEdgeInsets = UIEdgeInsetsZero;
        self.imageEdgeInsets = UIEdgeInsetsZero;
        
        CGRect contentRect = [self contentRectForBounds:self.bounds];
        CGSize imageSize = [self imageRectForContentRect:contentRect].size;
        CGSize titleSize = [self titleRectForContentRect:contentRect].size;
        CGFloat pad = self.paddingBetweenTitleAndImage * 0.5;
        
        self.titleEdgeInsets = UIEdgeInsetsMake(0, -imageSize.width - pad, 0, imageSize.width + pad);
        self.imageEdgeInsets = UIEdgeInsetsMake(0, titleSize.width + pad, 0, -titleSize.width - pad);
        
        [self noFrameKVOPerform:^{
            CGFloat expand = pad + self.layer.borderWidth;
            CGFloat width = expand * 2 + imageSize.width + titleSize.width;
            CGSize size = [self contentRectForBounds:self.bounds].size;
            if (width != size.width) {
                if (nil != self.layoutSizeNeedChangeBlock) {
                    size.width = width;
                    self.layoutSizeNeedChangeBlock(size);
                } else {
                    self.contentEdgeInsets = UIEdgeInsetsMake(0, expand, 0, expand);
                }
            }
        }];
    }
}

- (void)imageAndTitleToFitHorizonal
{
    if (nil != self.titleLabel && nil != self.imageView) {
        
        self.titleEdgeInsets = UIEdgeInsetsZero;
        self.imageEdgeInsets = UIEdgeInsetsZero;
        
        CGFloat pad = self.paddingBetweenTitleAndImage * 0.5;
        CGFloat border = self.layer.borderWidth;
        self.titleEdgeInsets = UIEdgeInsetsMake(0, pad, 0, -pad);
        self.imageEdgeInsets = UIEdgeInsetsMake(0, -pad, 0, pad);
      
        [self noFrameKVOPerform:^{
            CGFloat expand = pad + border;
            CGRect contentRect = [self contentRectForBounds:self.bounds];
            CGSize imageSize = [self imageRectForContentRect:contentRect].size;
            CGSize titleSize = [self titleRectForContentRect:contentRect].size;
            CGFloat width = expand * 2 + imageSize.width + titleSize.width;
            CGSize size = contentRect.size;
            
            if (width != size.width) {
                if (nil != self.layoutSizeNeedChangeBlock) {
                    size.width = width;
                    self.layoutSizeNeedChangeBlock(size);
                } else {
                    self.contentEdgeInsets = UIEdgeInsetsMake(0, expand, 0, expand);
                }
            }
        }];
    }
}

- (void)resetImageAndTitleEdges
{
    self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleEdgeInsets = UIEdgeInsetsZero;
    self.imageEdgeInsets = UIEdgeInsetsZero;
    self.contentEdgeInsets = UIEdgeInsetsZero;
}


#pragma mark - backgroundColor

- (void)addStateObserver:(id)observer
{
    [self addObserver:observer forKeyPath:@"highlighted" options:NSKeyValueObservingOptionNew context:NULL];
    [self addObserver:observer forKeyPath:@"selected" options:NSKeyValueObservingOptionNew context:NULL];
    [self addObserver:observer forKeyPath:@"enabled" options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)removeStateObserver:(id)observer
{
    [self removeObserver:observer forKeyPath:@"highlighted" context:NULL];
    [self removeObserver:observer forKeyPath:@"selected" context:NULL];
    [self removeObserver:observer forKeyPath:@"enabled" context:NULL];
}

- (NSMutableDictionary *)innerBackgroundColorDic
{
    TCButtonExtra *btnExtra = self.btnExtra;
    if (nil == btnExtra.innerBackgroundColorDic) {
        btnExtra.innerBackgroundColorDic = [NSMutableDictionary dictionary];
        if (nil == btnExtra.borderColorDic) {
            [self addStateObserver:btnExtra];
        }
    }
    
    return btnExtra.innerBackgroundColorDic;
}

- (NSMutableDictionary *)borderColorDic
{
    TCButtonExtra *btnExtra = self.btnExtra;
    if (nil == btnExtra.borderColorDic) {
        btnExtra.borderColorDic = [NSMutableDictionary dictionary];
        if (nil == btnExtra.innerBackgroundColorDic) {
            [self addStateObserver:btnExtra];
        }
    }
    
    return btnExtra.borderColorDic;
}


- (UIColor *)backgroundColorForState:(UIControlState)state
{
    return self.innerBackgroundColorDic[@(state)];
}

- (void)setBackgroundColor:(UIColor *)color forState:(UIControlState)state
{
    if (nil == color) {
        [self.innerBackgroundColorDic removeObjectForKey:@(state)];
    } else {
        self.innerBackgroundColorDic[@(state)] = color;
        
        if ((UIControlStateNormal & state) == UIControlStateNormal) {
            if (nil == [self backgroundColorForState:state | UIControlStateHighlighted]) {
                self.innerBackgroundColorDic[@(state | UIControlStateHighlighted)] = color;
            }
            
            if (nil == [self backgroundColorForState:state | UIControlStateSelected]) {
                self.innerBackgroundColorDic[@(state | UIControlStateSelected)] = color;
            }
        }
    }
    
    if (state == self.state) {
        self.backgroundColor = color;
    }
}

- (UIColor *)borderColorForState:(UIControlState)state;
{
    return self.borderColorDic[@(state)];
}

- (void)setBorderColor:(UIColor *)color forState:(UIControlState)state
{
    if (nil == color) {
        [self.borderColorDic removeObjectForKey:@(state)];
    } else {
        self.borderColorDic[@(state)] = color;
        
        if ((UIControlStateNormal & state) == UIControlStateNormal) {
            if (nil == [self borderColorForState:state | UIControlStateHighlighted]) {
                self.borderColorDic[@(state | UIControlStateHighlighted)] = color;
            }
            
            if (nil == [self borderColorForState:state | UIControlStateSelected]) {
                self.borderColorDic[@(state | UIControlStateSelected)] = color;
            }
        }
    }
    
    if (state == self.state) {
        self.layer.borderColor = color.CGColor;
    }
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
