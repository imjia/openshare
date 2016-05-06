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
#import "TCHTTPRequestCenter.h"

@interface OpenShareManager () <OSSnsItemViewDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate>
{
    @private
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
    _message = msg;
    _ctrler = ctrler;
    _shareCompletionHandle = completion;
    _snsCtrler = [[OSSnsItemView alloc] initWithSns:sns];
    _snsCtrler.delegate = self;
    
    if (nil != _message.dataItem.imageUrl) {
        [self downloadImage];
    } else {
        [self showSnsController];
    }
}


#pragma mark - OSSnsItemViewDelegate

- (void)OSSnsItemView:(OSSnsItemView *)itemView didSelectSnsItem:(OSSnsItem *)sns
{
    [self dismissSnsController];
    
    if (nil != _uiDelegate && [_uiDelegate respondsToSelector:@selector(didSelectSnsPlatform:)]) {
        [_uiDelegate didSelectSnsPlatform:sns.platform];
    }
    
    void (^block)(OSPlatform platform, OSShareState state, NSString *errorDescription) = ^(OSPlatform platform,OSShareState state, NSString *errorDescription){
        if (nil != _shareCompletionHandle) {
            _shareCompletionHandle(platform, state, errorDescription);
            _shareCompletionHandle = nil;
        }
    };
    
    switch (sns.platform) {
        case kOSPlatformQQ: {
            [OpenShare shareToQQ:_message completion:^(OSPlatform platform, OSShareState state, NSString *errorDescription) {
                block(kOSPlatformQQ, state, errorDescription);
            }];
            break;
        }
        case kOSPlatformQQZone: {
            [OpenShare shareToQQZone:_message completion:^(OSPlatform platform, OSShareState state, NSString *errorDescription) {
                block(kOSPlatformQQZone, state, errorDescription);
            }];
            break;
        }
        case kOSPlatformWXSession: {
            [OpenShare shareToWeixinSession:_message completion:^(OSPlatform platform, OSShareState state, NSString *errorDescription) {
                block(kOSPlatformWXSession, state, errorDescription);
            }];
            break;
        }
        case kOSPlatformWXTimeLine: {
            [OpenShare shareToWeixinTimeLine:_message completion:^(OSPlatform platform, OSShareState state, NSString *errorDescription) {
                block(kOSPlatformWXTimeLine, state, errorDescription);
            }];
            break;
        }
        case kOSPlatformSina: {
            [OpenShare shareToSinaWeibo:_message completion:^(OSPlatform platform, OSShareState state, NSString *errorDescription) {
                block(kOSPlatformSina, state, errorDescription);
            }];
            break;
        }
        case kOSPlatformEmail: {
            [OpenShare shareToMail:_message inController:_ctrler delegate:self];
            break;
        }
        case kOSPlatformSms: {
            [OpenShare shareToSms:_message inController:_ctrler delegate:self];
            break;
        }
        default:
            break;
    }
}

- (void)OSSnsItemViewWillDismiss:(OSSnsItemView *)itemView
{
    [self dismissSnsController];
}

- (void)showSnsController
{
    UIViewController *viewController = [UIApplication sharedApplication].keyWindow.topMostViewController;
    UITabBarController *tabCtrler = viewController.tabBarController;
    if (nil != tabCtrler) {
        viewController = tabCtrler;
    }
    
    [viewController beginAppearanceTransition:NO animated:YES];
    [viewController endAppearanceTransition];
    [viewController addChildViewController:_snsCtrler];
    [_snsCtrler beginAppearanceTransition:YES animated:YES];
    [viewController.view addSubview:_snsCtrler.view];
    [_snsCtrler didMoveToParentViewController:viewController];
    [_snsCtrler endAppearanceTransition];
}

- (void)dismissSnsController
{
    UIViewController *parentCtrler = _snsCtrler.parentViewController;
    [_snsCtrler beginAppearanceTransition:NO animated:YES];
    [_snsCtrler.view removeFromSuperview];
    [_snsCtrler endAppearanceTransition];
    [_snsCtrler willMoveToParentViewController:nil];
    [_snsCtrler removeFromParentViewController];
    
    [parentCtrler beginAppearanceTransition:YES animated:YES];
    [parentCtrler endAppearanceTransition];
    _snsCtrler = nil;
}

- (void)downloadImage
{
    if (nil != _message.dataItem.imageUrl) {
        
        NSString *path = [[self.class defaultCacheDirectoryInDomain:@"SDYImageCache"] stringByAppendingPathComponent:_message.dataItem.imageUrl.MD5_16];
        TCHTTPCachePolicy *policy = [[TCHTTPCachePolicy alloc] init];
        policy.cacheTimeoutInterval = kTCHTTPRequestCacheNeverExpired;
        policy.shouldExpiredCacheValid = NO;
        
        TCHTTPStreamPolicy *streamPolicy = [[TCHTTPStreamPolicy alloc] init];
        streamPolicy.shouldResumeDownload = YES;
        streamPolicy.downloadDestinationPath = path;
        id<TCHTTPRequest> request = [[TCHTTPRequestCenter defaultCenter] requestForDownload:_message.dataItem.imageUrl
                                                                               streamPolicy:streamPolicy
                                                                                cachePolicy:policy];
        if (nil != request) {
            request.timeoutInterval = 20.0f;
            request.observer = self;
            
            __weak typeof(self) wSelf = self;
            request.resultBlock = ^(id<TCHTTPRequest> request, BOOL success) {
                
                if (nil == wSelf) {
                    return;
                }
                
                NSData *data = nil;
                if (success) {
                    data = [NSData dataWithContentsOfFile:(NSString *)request.responseObject];
                }

                wSelf.message.dataItem.imageData = data;
                [wSelf showSnsController];
            };
            
            if ([request start:NULL]) {
//                [SVProgressHUD show];
            }
        }
    }
}


#pragma mark - MFMessageComposeViewControllerDelegate

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
 
    [controller dismissViewControllerAnimated:YES completion:nil];
    
    NSError *error = nil;
    if (MessageComposeResultSent != result) {
        error = [NSError errorWithDomain:kErrorDomainSms
                                    code:result
                                userInfo:nil];
    }

    if (nil != _shareCompletionHandle) {
        _shareCompletionHandle(kOSPlatformSms, nil == error ? kOSStateSuccess : kOSStateFail, nil);
        _shareCompletionHandle = nil;
    }
}


#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [controller dismissViewControllerAnimated:YES completion:nil];
    
    if (nil != _shareCompletionHandle) {
        _shareCompletionHandle(kOSPlatformEmail, nil == error ? kOSStateSuccess : kOSStateFail, error.localizedDescription);
        _shareCompletionHandle = nil;
    }
}


@end
