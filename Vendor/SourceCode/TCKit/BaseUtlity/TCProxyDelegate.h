//
//  TCProxyDelegate.h
//  TCKit
//
//  Created by dake on 16/3/21.
//  Copyright © 2016年 dake. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TCProxyDelegate : NSObject

@property (nonatomic, weak) id target;

+ (instancetype)proxyWithTarget:(id)target;
- (instancetype)initWithTarget:(id)target;

@end
