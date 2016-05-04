//
//  OpenShareManager.h
//  OpenShare_2
//
//  Created by jia on 16/5/3.
//  Copyright © 2016年 Jia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OpenShareHeader.h"

@class OSMessage;
@interface OpenShareManager : NSObject

@property (nonatomic, assign) BOOL ignoreNotInstalledApp;

+ (instancetype)defaultManager;
- (void)shareMsg:(OSMessage *)msg inController:(UIViewController *)ctrler defaultIconValid:(BOOL)defaultIconValid sns:(NSArray<NSNumber *> *)sns completion:(OSShareCompletionHandle)completion;

@end
