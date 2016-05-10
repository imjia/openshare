//
//  OpenShare+QQ.h
//  OpenShare_2
//
//  Created by jia on 16/3/21.
//  Copyright © 2016年 Jia. All rights reserved.
//

#import "OpenShare.h"

@interface OpenShare (QQ)

+ (void)registQQWithAppId:(NSString *)appId;
+ (void)shareToQQ:(OSMessage *)msg completion:(OSShareCompletionHandle)completionHandle;
+ (void)shareToQQZone:(OSMessage *)msg completion:(OSShareCompletionHandle)completionHandle;
+ (BOOL)QQ_handleOpenURL:(NSURL *)url;

@end
