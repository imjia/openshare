//
//  TCPopupContainer.m
//  TCKit
//
//  Created by dake on 14-9-4.
//  Copyright (c) 2014年 dake. All rights reserved.
//

#import "TCPopupContainer.h"
#import "UIWindow+TCHelper.h"

@interface TCPopupContainer ()

@property (nonatomic, strong) UIWindow *oldKeyWindow;

@end

@interface TCPopupContainerController : UIViewController

@property (nonatomic, strong) TCPopupContainer *popupView;

@end

@implementation TCPopupContainerController


- (void)loadView
{
    self.view = _popupView;
}

#ifdef __IPHONE_7_0
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        [self setNeedsStatusBarAppearanceUpdate];
    }
}
#endif

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    UIViewController *viewController = [_popupView.oldKeyWindow topMostViewController];
    if (nil != viewController) {
        return viewController.supportedInterfaceOrientations;
    }
    return UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    UIViewController *viewController = [_popupView.oldKeyWindow topMostViewController];
    if (viewController) {
        return [viewController shouldAutorotateToInterfaceOrientation:toInterfaceOrientation];
    }
    return YES;
}

- (BOOL)shouldAutorotate
{
    UIViewController *viewController = [_popupView.oldKeyWindow topMostViewController];
    if (viewController) {
        return viewController.shouldAutorotate;
    }
    return YES;
}

#ifdef __IPHONE_7_0
- (UIStatusBarStyle)preferredStatusBarStyle
{
    UIWindow *window = _popupView.oldKeyWindow;
    if (nil == window) {
        window = [UIApplication sharedApplication].windows.firstObject;
    }
    return window.viewControllerForStatusBarStyle.preferredStatusBarStyle;
}

- (BOOL)prefersStatusBarHidden
{
    UIWindow *window = _popupView.oldKeyWindow;
    if (nil == window) {
        window = [UIApplication sharedApplication].windows.firstObject;
    }
    return window.viewControllerForStatusBarHidden.prefersStatusBarHidden;
}
#endif


@end


@implementation TCPopupContainer
{
@private
    UIWindow *_containerWindow;
    UIControl *_backgroundView;
    UIButton *_closeBtn;
    
#ifdef __IPHONE_7_0
    UIViewTintAdjustmentMode _oldTintAdjustmentMode;
#endif
}

@synthesize maskBackgroundColor = _maskBackgroundColor;

- (void)dealloc
{
    --s_containerCount;
    [_backgroundView removeTarget:self action:@selector(handleTouched:) forControlEvents:UIControlEventTouchUpInside];
}


+ (void)initialize
{
    if (self != TCPopupContainer.class) {
        return;
    }
    
    TCPopupContainer *appearance = [self appearance];
    appearance.maskBackgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
}

static NSUInteger s_containerCount;
+ (BOOL)anyContainerVisible
{
    return s_containerCount > 0;
}


- (UIImage *)closeImageForState:(UIControlState)state
{
    return nil;
}

#pragma mark - UIAppearance setters

- (void)setMaskBackgroundColor:(UIColor *)maskBackgroundColor
{
    if (_maskBackgroundColor == maskBackgroundColor) {
        return;
    }
    _maskBackgroundColor = maskBackgroundColor;
    _backgroundView.backgroundColor = maskBackgroundColor;
}

- (UIColor *)viewBackgroundColor
{
    if (!_maskBackgroundColor) {
        return [self.class.appearance maskBackgroundColor];
    }
    return _maskBackgroundColor;
}



- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        ++s_containerCount;
        _shouldShowCloseBtn = YES;
        self.backgroundColor = [UIColor clearColor];
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return self;
}


- (UIView *)containerView
{
    if (nil == _containerView) {
        _containerView = [[UIView alloc] initWithFrame:self.bounds];
        _containerView.backgroundColor = [UIColor clearColor];
        [self addSubview:_containerView];
    }
    
    return _containerView;
}

- (UIControl *)backgroundView
{
    if (nil == _backgroundView) {
        _backgroundView = [[UIControl alloc] initWithFrame:self.bounds];
        [_backgroundView addTarget:self action:@selector(handleTouched:) forControlEvents:UIControlEventTouchUpInside];
        _backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self insertSubview:_backgroundView atIndex:0];
    }
    
    return _backgroundView;
}

- (UIButton *)closeBtn
{
    if (nil == _closeBtn) {
        _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *img = [self closeImageForState:UIControlStateNormal];
        _closeBtn.frame = CGRectMake(0, 0, img.size.width, img.size.height);
        [_closeBtn setBackgroundImage:img forState:UIControlStateNormal];
        img = [self closeImageForState:UIControlStateHighlighted];
        [_closeBtn setBackgroundImage:img forState:UIControlStateHighlighted];
        [_closeBtn addTarget:self action:@selector(closeTapped:) forControlEvents:UIControlEventTouchUpInside];
        _closeBtn.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    }
    
    return _closeBtn;
}


- (void)setupView
{
    self.backgroundView.backgroundColor = self.maskBackgroundColor;
    
    CGSize size = self.bounds.size;
    CGRect containerFrame = self.bounds;
    if (!CGSizeEqualToSize(_shownAreaSize, CGSizeZero)) {
        containerFrame.size = _shownAreaSize;
    } else if (nil != _shownCtrler) {
        containerFrame = _shownCtrler.view.frame;
    }
    
    if (!_allowCustomContainerRect) {
        CGRect frame;
        UIViewAutoresizing autoresizingMask;
        if (_presentStyle == kTCPopupStyleCenter) {
            frame.origin.x = (size.width - containerFrame.size.width) * 0.5;
            frame.origin.y = (size.height - containerFrame.size.height - containerFrame.origin.y) * 0.5;
            frame.size.width = containerFrame.size.width;
            frame.size.height = containerFrame.size.height + containerFrame.origin.y;
            autoresizingMask = UIViewAutoresizingFlexibleLeftMargin
            | UIViewAutoresizingFlexibleRightMargin
            | UIViewAutoresizingFlexibleTopMargin
            | UIViewAutoresizingFlexibleBottomMargin;
        } else {
            frame.origin.x = (size.width - containerFrame.size.width) * 0.5;
            frame.origin.y = size.height - containerFrame.size.height - containerFrame.origin.y;
            frame.size.width = containerFrame.size.width;
            frame.size.height = containerFrame.size.height + containerFrame.origin.y;
            
            if (_shouldFlexContainerWidth) {
                autoresizingMask = UIViewAutoresizingFlexibleTopMargin
                | UIViewAutoresizingFlexibleWidth;
            } else {
                autoresizingMask = UIViewAutoresizingFlexibleTopMargin
                | UIViewAutoresizingFlexibleLeftMargin
                | UIViewAutoresizingFlexibleRightMargin;
            }
        }
        
        self.containerView.frame = frame;
        _containerView.autoresizingMask = autoresizingMask;
    }

    [_shownCtrler.view removeFromSuperview];
    //    _shownCtrler.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [_containerView addSubview:_shownCtrler.view];
    
    if (_presentStyle == kTCPopupStyleCenter && _shouldShowCloseBtn) {
        
        if (nil == _closeBtn) {
            [_containerView addSubview:self.closeBtn];
        }
    } else {
        if (nil != _closeBtn) {
            [_closeBtn removeFromSuperview];
            _closeBtn = nil;
        }
    }
}

- (BOOL)isVisible
{
    return nil != _containerWindow;
}

- (void)show
{
    [self show:YES];
}

- (void)show:(BOOL)animated
{
    if (self.isVisible) {
        return;
    }
    
    TCPopupContainerController *viewController = [[TCPopupContainerController alloc] init];
    viewController.popupView = self;
    
    _containerWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _containerWindow.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _containerWindow.opaque = NO;
    _containerWindow.rootViewController = viewController;

    _containerWindow.windowLevel = UIWindowLevelStatusBar + [UIApplication sharedApplication].windows.count;
    _oldKeyWindow = [UIApplication sharedApplication].keyWindow;
    [_containerWindow makeKeyAndVisible];
#ifdef __IPHONE_7_0
    if ([_oldKeyWindow respondsToSelector:@selector(tintAdjustmentMode)]) {
        _oldTintAdjustmentMode = _oldKeyWindow.tintAdjustmentMode;
    }
#endif
    
    [self layoutIfNeeded];
    [self setupView];
    
    
#ifdef __IPHONE_7_0
    if ([_oldKeyWindow respondsToSelector:@selector(setTintAdjustmentMode:)]) {
        _oldKeyWindow.tintAdjustmentMode = UIViewTintAdjustmentModeDimmed;
    }
#endif
    
    if (animated) {
        CGFloat duration = 0.35f;
        if ((_presentStyle == kTCPopupStyleCenter) || (_presentStyle == kTCPopupStyleFade)) {
            CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
            animation.values = @[@0.01, @1.1, @0.9, @1];
            animation.keyTimes = @[@0, @0.5, @0.7, @1];
            animation.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear], [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear], [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
            animation.duration = 0.5f;
            animation.removedOnCompletion = YES;
            [_containerView.layer addAnimation:animation forKey:@"bounce"];
            
            duration = animation.duration;
        } else {
            
            CATransition *transition = [CATransition animation];
            transition.duration = 0.35f;
            transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            transition.type = kCATransitionMoveIn;
            transition.removedOnCompletion = YES;
            transition.subtype = kCATransitionFromTop;
            [_containerView.layer addAnimation:transition forKey:@"fromTop"];
            
            duration = transition.duration;
        }
        
        if (nil != _backgroundView) {
            _backgroundView.alpha = 0.0f;
            [UIView animateWithDuration:duration animations:^{
                _backgroundView.alpha = 1.0f;
            }];
        }
    }
}


- (void)dismiss
{
    [self dismiss:YES];
}

- (void)dismiss:(BOOL)animated
{
    if (!self.isVisible) {
        return;
    }
    
    void (^dismissCompletion)(void) = ^{
        [_containerWindow removeFromSuperview];
        _containerWindow.rootViewController = nil;
        _containerWindow = nil;
        
        [_oldKeyWindow makeKeyWindow];
        _oldKeyWindow = nil;
        
        if (nil != _dismissdBlock) {
            _dismissdBlock();
            _dismissdBlock = nil;
        }
    };
    
#ifdef __IPHONE_7_0
    if ([_oldKeyWindow respondsToSelector:@selector(setTintAdjustmentMode:)]) {
        _oldKeyWindow.tintAdjustmentMode = _oldTintAdjustmentMode;
    }
#endif
    
    if (animated) {
        CGFloat duration = 0.35f;
        if (_presentStyle == kTCPopupStyleCenter) {
            CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
            animation.values = @[@1, @1.2, @0.01];
            animation.keyTimes = @[@0, @0.4, @1];
            animation.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut], [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
            animation.duration = 0.35f;
            animation.delegate = self;
            animation.removedOnCompletion = YES;
            [animation setValue:dismissCompletion forKey:@"handler"];
            [_containerView.layer addAnimation:animation forKey:@"bounce"];
            
            _containerView.transform = CGAffineTransformMakeScale(0.01f, 0.01f);
            
            duration = animation.duration;
        } else if (_presentStyle == kTCPopupStyleFade) {
            CATransition *transition = [CATransition animation];
            transition.duration = 0.35f;
            transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
            transition.type = kCATransitionFade;
            transition.delegate = self;
            transition.removedOnCompletion = YES;
            [transition setValue:dismissCompletion forKey:@"handler"];
            [_containerView.layer addAnimation:transition forKey:@"fade"];
            
            _containerView.hidden = YES;
            duration = transition.duration;
        } else {
            
            CATransition *transition = [CATransition animation];
            transition.duration = 0.35f;
            transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            transition.type = kCATransitionReveal;
            transition.delegate = self;
            transition.removedOnCompletion = YES;
            transition.subtype = kCATransitionFromBottom;
            [transition setValue:dismissCompletion forKey:@"handler"];
            [_containerView.layer addAnimation:transition forKey:@"fromTop"];
            
            _containerView.hidden = YES;
            duration = transition.duration;
        }
        
        if (nil != _backgroundView) {
            [UIView animateWithDuration:duration animations:^{
                _backgroundView.alpha = 0.0f;
            }];
        }
    } else {
        dismissCompletion();
    }
}


- (void)handleTouched:(UIControl *)sender
{
    if (_disableTouchOutSide) {
        return;
    }
    [self dismiss];
}

- (void)closeTapped:(UIButton *)sender
{
    [self dismiss];
}


#pragma mark - CAAnimation delegate

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    void(^completion)(void) = [anim valueForKey:@"handler"];
    if (nil != completion) {
        completion();
    }
}

@end
