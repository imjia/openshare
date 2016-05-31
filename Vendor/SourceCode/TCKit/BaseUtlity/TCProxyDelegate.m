//
//  TCProxyDelegate.m
//  TCKit
//
//  Created by dake on 16/3/21.
//  Copyright © 2016年 dake. All rights reserved.
//

#import "TCProxyDelegate.h"


// http://blog.csdn.net/c395565746c/article/details/8507008


@implementation TCProxyDelegate


+ (instancetype)proxyWithTarget:(id)target
{
    return [[self alloc] initWithTarget:target];
}

- (instancetype)initWithTarget:(id)target
{
    self = [self init];
    if (self) {
        _target = target;
    }
    
    return self;
}

- (id)forwardingTargetForSelector:(SEL)aSelector
{
    return self.target;
}

@end
