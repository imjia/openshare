//
//  OpenShare+SinaWeibo.h
//  OpenShare_2
//
//  Created by jia on 16/3/23.
//  Copyright © 2016年 Jia. All rights reserved.
//

#import "OpenShare.h"

extern NSString *const kSinaWbScheme;

@interface OpenShare (SinaWeibo)

+ (void)registSinaWeiboWithAppKey:(NSString *)appKey;
+ (void)shareToSinaWeibo:(OSMessage *)msg completion:(OSShareCompletionHandle)completionHandle;
+ (BOOL)SinaWeibo_handleOpenURL:(NSURL *)url;

@end
