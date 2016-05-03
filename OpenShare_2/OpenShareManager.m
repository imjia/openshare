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
#import "TCPopupContainer.h"

@interface OpenShareManager () <OSSnsItemViewDelegate>
{
    @private
    __weak TCPopupContainer *_container;
    OSMessage *_msg;
    UIViewController *_ctrler;
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

- (void)shareMsg:(OSMessage *)msg inController:(UIViewController *)ctrler defaultIconValid:(BOOL)defaultIconValid sns:(NSArray<NSNumber *> *)sns
{
    _msg = msg;
    _ctrler = ctrler;
    
    OSSnsItemView *view = [[OSSnsItemView alloc] initWithDefaultSnsItems:sns];
    view.delegate = self;
    
    TCPopupContainer *container = [[TCPopupContainer alloc] init];
    view.parentCtrler = container;
    container.shownCtrler = view;
    container.presentStyle = kTCPopupStyleFromTop;
    [container show:YES];
    _container = container;
}


#pragma mark - OSSnsItemViewDelegate

- (void)OSSnsItemView:(OSSnsItemView *)itemView didSelectSnsItem:(OSSnsItem *)sns
{
    [_container dismiss];
    
    switch (sns.index) {
        case kOSAppQQ: {
            [OpenShare shareToQQ:_msg completion:^(NSError *error) {
                
            }];
            break;
        }
        case kOSAppQQZone: {
            [OpenShare shareToQQZone:_msg completion:^(NSError *error) {
                
            }];
            break;
        }
        case kOSAppWXSession: {
            [OpenShare shareToWeixinSession:_msg completion:^(NSError *error) {
                
            }];
            break;
        }
        case kOSAppWXTimeLine: {
            [OpenShare shareToWeixinTimeLine:_msg completion:^(NSError *error) {
                
            }];
            break;
        }
        case kOSAppSina: {
            [OpenShare shareToSinaWeibo:_msg completion:^(NSError *error) {
                
            }];
            break;
        }
        case kOSAppEmail: {
            [OpenShare shareToMail:_msg completion:^(NSError *error) {
                
            }];
            break;
        }
        case kOSAppSms: {
            [OpenShare shareToSms:_msg inController:_ctrler completion:^(NSError *error) {
                
            }];
            break;
        }
        default:
            break;
    }
}


@end
