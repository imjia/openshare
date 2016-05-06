//
//  OpenShare+Weixin.h
//  OpenShare_2
//
//  Created by jia on 16/3/22.
//  Copyright © 2016年 Jia. All rights reserved.
//

#import "OpenShare.h"

extern NSString *const kWXScheme;

@interface OpenShare (Weixin)

+ (void)registWeixinWithAppId:(NSString *)appId;
+ (void)shareToWeixinSession:(OSMessage *)msg completion:(OSShareCompletionHandle)completionHandle;
+ (void)shareToWeixinTimeLine:(OSMessage *)msg completion:(OSShareCompletionHandle)completionHandle;
+ (BOOL)Weixin_handleOpenURL:(NSURL *)url;

@end
