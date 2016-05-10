//
//  OpenShareManager.m
//  OpenShare_2
//
//  Created by jia on 16/5/3.
//  Copyright © 2016年 Jia. All rights reserved.
//

#import "OpenShareManager.h"
#import "OpenShareHeader.h"
#import "OSSnsItemController.h"
#import "UIWindow+TCHelper.h"
#import "TCHTTPRequestCenter.h"

@interface OpenShareManager () <OSSnsItemControllerDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate>
{
    @private
    OSSnsItemController *_snsCtrler;
}

@property (nonatomic, strong) OSMessage *message;
@property (nonatomic, assign) OSShareCompletionHandle shareCompletionHandle;

@end

@implementation OpenShareManager

+ (instancetype)defaultManager
{
    static OpenShareManager *mgr = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mgr = [[self alloc] init];
    });
    
    return mgr;
}

- (void)shareMsg:(OSMessage *)msg sns:(NSArray<NSNumber *> *)sns completion:(OSShareCompletionHandle)completion
{
    _message = msg;
    _shareCompletionHandle = completion;
    _snsCtrler = [[OSSnsItemController alloc] initWithSns:sns];
    _snsCtrler.delegate = self;
    
    if (nil != _message.dataItem.imageUrl) {
        [self downloadImage];
    } else {
        [self showSnsController];
    }
}


#pragma mark - OSSnsItemControllerDelegate

- (void)OSSnsItemController:(OSSnsItemController *)ctrler didSelectSnsItem:(OSSnsItem *)sns
{
    [self dismissSnsController];
    
    if (nil != _uiDelegate && [_uiDelegate respondsToSelector:@selector(didSelectSnsPlatform:message:)]) {
        [_uiDelegate didSelectSnsPlatform:sns.platform message:_message];
    }
    
    __weak typeof(self) wSelf = self;
    void (^block)(OSMessage *message,OSPlatform platform, OSShareState state, NSError *error) = ^(OSMessage *message,OSPlatform platform, OSShareState state, NSError *error){
        if (nil != wSelf.shareCompletionHandle) {
            wSelf.shareCompletionHandle(_message, platform, state, nil);
            wSelf.shareCompletionHandle = nil;
        }
    };
    
    switch (sns.platform) {
        case kOSPlatformQQ: {
            [OpenShare shareToQQ:_message completion:^(OSMessage *message, OSPlatform platform, OSShareState state, NSError *error) {
                block(_message, kOSPlatformQQ, state, error);
            }];
            break;
        }
        case kOSPlatformQQZone: {
            [OpenShare shareToQQZone:_message completion:^(OSMessage *message, OSPlatform platform, OSShareState state, NSError *error) {
                block(_message, kOSPlatformQQZone, state, error);

            }];
            break;
        }
        case kOSPlatformWXSession: {
            [OpenShare shareToWeixinSession:_message completion:^(OSMessage *message, OSPlatform platform, OSShareState state, NSError *error) {
                block(_message, kOSPlatformWXSession, state, error);
            }];
            break;
        }
        case kOSPlatformWXTimeLine: {
            [OpenShare shareToWeixinTimeLine:_message completion:^(OSMessage *message, OSPlatform platform, OSShareState state, NSError *error) {
                block(_message, kOSPlatformWXTimeLine, state, error);
            }];
            break;
        }
        case kOSPlatformSina: {
            [OpenShare shareToSinaWeibo:_message completion:^(OSMessage *message, OSPlatform platform, OSShareState state, NSError *error) {
                block(_message, kOSPlatformSina, state, error);
            }];
            break;
        }
        case kOSPlatformEmail: {
            [OpenShare shareToMail:_message delegate:self];
            break;
        }
        case kOSPlatformSms: {
            [OpenShare shareToSms:_message delegate:self];
            break;
        }
        default:
            break;
    }
}

- (void)OSSnsItemControllerWillDismiss:(OSSnsItemController *)ctrler
{
    [self dismissSnsController];
}

- (void)showSnsController
{
    UIViewController *viewController = [UIApplication sharedApplication].delegate.window.topMostViewController;
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
        NSString *path = [[self.class defaultCacheDirectoryInDomain:@"SDYImageCache"] stringByAppendingPathComponent:_message.dataItem.imageUrl.absoluteString.MD5_16];
        TCHTTPCachePolicy *policy = [[TCHTTPCachePolicy alloc] init];
        policy.cacheTimeoutInterval = kTCHTTPRequestCacheNeverExpired;
        policy.shouldExpiredCacheValid = NO;
        
        TCHTTPStreamPolicy *streamPolicy = [[TCHTTPStreamPolicy alloc] init];
        streamPolicy.shouldResumeDownload = YES;
        streamPolicy.downloadDestinationPath = path;
        
        __weak typeof(_message) wMessage = _message;
        id<TCHTTPRequest> request = [[TCHTTPRequestCenter defaultCenter] requestForDownload:_message.dataItem.imageUrl.absoluteString
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
                
                if (wSelf.beforeDownloadImage) {
                    wSelf.beforeDownloadImage();
                    wSelf.beforeDownloadImage = nil;
                }
                
                NSData *data = nil;
                if (success) {
                    data = [NSData dataWithContentsOfFile:(NSString *)request.responseObject];
                }
                
                if (nil != wMessage && wMessage == wSelf.message) {
                    wMessage.dataItem.imageData = data;
                    [wSelf showSnsController];
                }
            };
            
            if ([request start:NULL]) {
                if (wSelf.afterDownloadImage) {
                    wSelf.afterDownloadImage();
                    wSelf.afterDownloadImage = nil;
                }
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
        error = [NSError errorWithDomain:kOSErrorDomainSms
                                    code:result
                                userInfo:nil];
    }

    if (nil != _shareCompletionHandle) {
        _shareCompletionHandle(_message, kOSPlatformSms, nil == error ? kOSStateSuccess : kOSStateFail, nil);
        _shareCompletionHandle = nil;
    }
}


#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [controller dismissViewControllerAnimated:YES completion:nil];
    
    if (nil != _shareCompletionHandle) {
        _shareCompletionHandle(_message, kOSPlatformEmail, nil == error ? kOSStateSuccess : kOSStateFail, error);
        _shareCompletionHandle = nil;
    }
}

@end
