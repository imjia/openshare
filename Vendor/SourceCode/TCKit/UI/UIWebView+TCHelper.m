//
//  UIWebView+TCHelper.m
//  SudiyiClient
//
//  Created by cdk on 16/1/7.
//  Copyright © 2016年 Sudiyi. All rights reserved.
//

#import "UIWebView+TCHelper.h"

@implementation UIWebView (TCHelper)

+ (NSString *)tc_systemUserAgent
{
    static NSString *s_userAgent = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dispatch_block_t block = ^{
            s_userAgent = [[[UIWebView alloc] init] stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
        };
        if (NSThread.isMainThread) {
            block();
        } else {
            dispatch_sync(dispatch_get_main_queue(), block);
        }
    });
    
    return s_userAgent;
}

@end
