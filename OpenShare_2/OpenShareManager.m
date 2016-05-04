//
//  OpenShareManager.m
//  OpenShare_2
//
//  Created by jia on 16/5/3.
//  Copyright © 2016年 Jia. All rights reserved.
//

#import "OpenShareManager.h"
#import "OpenShareHeader.h"
#import "OSSnsItemView.h"
#import "UIWindow+TCHelper.h"

@interface OpenShareManager () <OSSnsItemViewDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate>
{
    @private
    OSMessage *_msg;
    OSSnsItemView *_snsCtrler;
    UIViewController *_ctrler;
    OSShareCompletionHandle _shareCompletionHandle;
}
@end

@implementation OpenShareManager

+ (instancetype)defaultManager
{
    static OpenShareManager *mgr = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mgr = [[OpenShareManager alloc] init];
    });
    
    return mgr;
}

- (void)shareMsg:(OSMessage *)msg inController:(UIViewController *)ctrler defaultIconValid:(BOOL)defaultIconValid sns:(NSArray<NSNumber *> *)sns completion:(OSShareCompletionHandle)completion
{
    _msg = msg;
    _ctrler = ctrler;
    _shareCompletionHandle = completion;
    
    _snsCtrler = [[OSSnsItemView alloc] initWithDefaultSnsItems:sns];
    _snsCtrler.delegate = self;
    [self showSnsController];
}


#pragma mark - OSSnsItemViewDelegate

- (void)OSSnsItemView:(OSSnsItemView *)itemView didSelectSnsItem:(OSSnsItem *)sns
{
    [self dismissSnsController];
    
    void (^block)(NSError *error) = ^(NSError *error){
        if (nil != _shareCompletionHandle) {
            _shareCompletionHandle(error);
            _shareCompletionHandle = nil;
        }
    };
    
    switch (sns.index) {
        case kOSAppQQ: {
            [OpenShare shareToQQ:_msg completion:^(NSError *error) {
                block(error);
            }];
            break;
        }
        case kOSAppQQZone: {
            [OpenShare shareToQQZone:_msg completion:^(NSError *error) {
                block(error);
            }];
            break;
        }
        case kOSAppWXSession: {
            [OpenShare shareToWeixinSession:_msg completion:^(NSError *error) {
                block(error);
            }];
            break;
        }
        case kOSAppWXTimeLine: {
            [OpenShare shareToWeixinTimeLine:_msg completion:^(NSError *error) {
                block(error);
            }];
            break;
        }
        case kOSAppSina: {
            [OpenShare shareToSinaWeibo:_msg completion:^(NSError *error) {
                block(error);
            }];
            break;
        }
        case kOSAppEmail: {
            [OpenShare shareToMail:_msg inController:_ctrler delegate:self];
            break;
        }
        case kOSAppSms: {
            [OpenShare shareToSms:_msg inController:_ctrler delegate:self];
            break;
        }
        default:
            break;
    }
}


- (void)showSnsController
{
    UIViewController *viewController = [UIApplication sharedApplication].keyWindow.topMostViewController;
    [viewController beginAppearanceTransition:NO animated:YES];
    [viewController endAppearanceTransition];
    [viewController addChildViewController:_snsCtrler];
    [_snsCtrler beginAppearanceTransition:YES animated:YES];
    [viewController.view addSubview:_snsCtrler.view];
    [_snsCtrler didMoveToParentViewController:viewController];
    [_snsCtrler endAppearanceTransition];
    
    
    CGPoint point = CGPointMake(_snsCtrler.view.center.x, viewController.view.frame.size.height + _snsCtrler.view.frame.size.height/2);
    _snsCtrler.view.center = point;
    
    CGPoint center = _snsCtrler.view.center;
    center.y -= _snsCtrler.view.frame.size.height;
    [UIView animateWithDuration:0.35f animations:^{
        _snsCtrler.view.center = center;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)dismissSnsController
{
    CGPoint center = _snsCtrler.view.center;
    center.y += _snsCtrler.view.frame.size.height;
    [UIView animateWithDuration:0.35f animations:^{
        _snsCtrler.view.center = center;
    } completion:^(BOOL finished) {
        UIViewController *parentCtrler = _snsCtrler.parentViewController;
        [_snsCtrler beginAppearanceTransition:NO animated:YES];
        [_snsCtrler.view removeFromSuperview];
        [_snsCtrler endAppearanceTransition];
        [_snsCtrler willMoveToParentViewController:nil];
        [_snsCtrler removeFromParentViewController];
        
        [parentCtrler beginAppearanceTransition:YES animated:YES];
        [parentCtrler endAppearanceTransition];
        _snsCtrler = nil;
    }];
}


#pragma mark - MFMessageComposeViewControllerDelegate

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
 
    [controller dismissViewControllerAnimated:YES completion:nil];
    
    NSError *error = nil;
    if (MessageComposeResultSent != result) {
        error = [NSError errorWithDomain:@"response_from_sms"
                                    code:result
                                userInfo:nil];
    }

    if (nil != _shareCompletionHandle) {
        _shareCompletionHandle(error);
        _shareCompletionHandle = nil;
    }
}


#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [controller dismissViewControllerAnimated:YES completion:nil];
    
    if (nil != _shareCompletionHandle) {
        _shareCompletionHandle(error);
        _shareCompletionHandle = nil;
    }
}


@end
