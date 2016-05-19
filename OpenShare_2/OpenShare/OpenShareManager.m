//
//  OpenShareManager.m
//  OpenShare_2
//
//  Created by jia on 16/5/3.
//  Copyright © 2016年 Jia. All rights reserved.
//

#import "OpenShareManager.h"
#import "OpenShareHeader.h"
#import "UIWindow+TCHelper.h"
#import "TCHTTPRequestCenter.h"
#import "OSPlatformController.h"
#import "OSResponse.h"

@interface OpenShareManager () <OSPlatformControllerDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate>
{
    @private
    OSPlatformController *_platformCtrler;
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

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)init
{
    if (self = [super init]) {
        __weak typeof(self) wSelf = self;
        [[NSNotificationCenter defaultCenter] addObserverForName:kOSShareFinishedNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
            NSObject<OSResponse> *response = note.object;
            [wSelf callShareCompletionHandle:nil == response.error ? kOSStateSuccess : kOSStateFail error:response.error];
        }];
    }
    return self;
}

- (void)shareMsg:(OSMessage *)msg platformCodes:(NSArray<NSNumber *> *)codes completion:(OSShareCompletionHandle)completion
{
    _message = msg;
    _shareCompletionHandle = completion;
    _platformCtrler = [[OSPlatformController alloc] initWithPlatformCodes:[self installedCodes:codes]];
    _platformCtrler.delegate = self;
    _platformCtrler.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    if (nil != _message.dataItem.imageUrl) {
        [self downloadImage];
    } else {
        [self showPlatformController];
    }
}

- (NSArray *)installedCodes:(NSArray<NSNumber *> *)codes
{
    NSMutableArray *installedCodes = codes.mutableCopy;
    if (![OpenShare isQQInstalled]) {
        if ([installedCodes containsObject:@(kOSPlatformQQ)]) {
            [installedCodes removeObject:@(kOSPlatformQQ)];
        }
        if ([installedCodes containsObject:@(kOSPlatformQQZone)]) {
            [installedCodes removeObject:@(kOSPlatformQQZone)];
        }
    }
    
    if (![OpenShare isWeixinInstalled]) {
        if ([installedCodes containsObject:@(kOSPlatformWXSession)]) {
            [installedCodes removeObject:@(kOSPlatformWXSession)];
        }
        if ([installedCodes containsObject:@(kOSPlatformWXTimeLine)]) {
            [installedCodes removeObject:@(kOSPlatformWXTimeLine)];
        }
    }
    
    if (![OpenShare isSinaWeiboInstalled]) {
        if ([installedCodes containsObject:@(kOSPlatformSina)]) {
            [installedCodes removeObject:@(kOSPlatformSina)];
        }
    }
    
    if (installedCodes.count < 1) {
        if (MFMessageComposeViewController.canSendText) {
            [installedCodes addObject:@(kOSPlatformSms)];
        }
        [installedCodes addObject:@(kOSPlatformEmail)];
    }
    
    return installedCodes;
}


#pragma mark - OSPlatformControllerDelegate

- (void)OSPlatformController:(OSPlatformController *)ctrler didSelectPlatformItem:(OSPlatformItem *)platform
{
    [self dismissPlatformController];
    
    _message.curPlatform = platform;

    if (nil != _uiDelegate && [_uiDelegate respondsToSelector:@selector(didSelectPlatformItem:message:)]) {
        [_uiDelegate didSelectPlatformItem:platform message:_message];
    }

    switch (platform.code) {
        case kOSPlatformQQ: {
            [OpenShare shareToQQ:_message];
            break;
        }
        case kOSPlatformQQZone: {
            [OpenShare shareToQQZone:_message];
            break;
        }
        case kOSPlatformWXSession: {
            [OpenShare shareToWeixinSession:_message];
            break;
        }
        case kOSPlatformWXTimeLine: {
            [OpenShare shareToWeixinTimeLine:_message];
            break;
        }
        case kOSPlatformSina: {
            [OpenShare shareToSinaWeibo:_message];
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

- (void)OSPlatformControllerWillDismiss:(OSPlatformController *)ctrler
{
    [self dismissPlatformController];
}

- (void)showPlatformController
{
    UIViewController *viewController = [UIApplication sharedApplication].delegate.window.topMostViewController;
    
    UITabBarController *tabCtrler = viewController.tabBarController;
    if (nil != tabCtrler) {
        viewController = tabCtrler;
    }
    
    // 修正横屏时，frame还是竖屏的情况
    CGRect rect = viewController.view.frame;
    CGAffineTransform transform = viewController.view.transform;
    if (!CGAffineTransformIsIdentity(transform)) {
        CGFloat width = rect.size.width;
        rect.size.width = rect.size.height;
        rect.size.height = width;
    }
    
    _platformCtrler.view.frame = rect;
    
    [viewController beginAppearanceTransition:NO animated:YES];
    [viewController endAppearanceTransition];
    [viewController addChildViewController:_platformCtrler];
    [_platformCtrler beginAppearanceTransition:YES animated:YES];
    [viewController.view addSubview:_platformCtrler.view];
    [_platformCtrler didMoveToParentViewController:viewController];
    [_platformCtrler endAppearanceTransition];
}

- (void)dismissPlatformController
{
    UIViewController *parentCtrler = _platformCtrler.parentViewController;
    [_platformCtrler beginAppearanceTransition:NO animated:YES];
    [_platformCtrler.view removeFromSuperview];
    [_platformCtrler endAppearanceTransition];
    [_platformCtrler willMoveToParentViewController:nil];
    [_platformCtrler removeFromParentViewController];
    
    [parentCtrler beginAppearanceTransition:YES animated:YES];
    [parentCtrler endAppearanceTransition];
    _platformCtrler = nil;
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
                
                if (nil != wSelf.uiDelegate && [wSelf.uiDelegate respondsToSelector:@selector(didDownloadImage)]) {
                    [wSelf.uiDelegate didDownloadImage];
                }
                
                NSData *data = nil;
                if (success) {
                    data = [NSData dataWithContentsOfFile:(NSString *)request.responseObject];
                }
                
                if (nil != wMessage && wMessage == wSelf.message) {
                    wMessage.dataItem.imageData = data;
                    [wSelf showPlatformController];
                }
            };
            
            if ([request start:NULL]) {
                if (nil != wSelf.uiDelegate && [wSelf.uiDelegate respondsToSelector:@selector(willDownloadImage)]) {
                    [wSelf.uiDelegate willDownloadImage];
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

    [self callShareCompletionHandle:nil == error ? kOSStateSuccess : kOSStateFail error:error];
}


#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [controller dismissViewControllerAnimated:YES completion:nil];
    [self callShareCompletionHandle:nil == error ? kOSStateSuccess : kOSStateFail error:error];
}

- (void)callShareCompletionHandle:(OSShareState)state error:(NSError *)error
{
    if (nil != _shareCompletionHandle) {
        _shareCompletionHandle(_message, state, error);
        _shareCompletionHandle = nil;
    }
}

@end
