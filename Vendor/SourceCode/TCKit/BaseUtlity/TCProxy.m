//
//  TCProxy.m
//  TCKit
//
//  Created by dake on 16/3/18.
//  Copyright © 2016年 dake. All rights reserved.
//

#import "TCProxy.h"

@implementation TCProxy

+ (instancetype)proxyWithOrigin:(id)origin target:(id)target
{
    return [[self alloc] initWithOrigin:origin target:target];
}

- (instancetype)initWithOrigin:(id)origin target:(id)target
{
    _origin = origin;
    _target = target;
    return self;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    NSMethodSignature *sig = [_target methodSignatureForSelector:aSelector];
    if (nil == sig) {
        sig = [_origin methodSignatureForSelector:aSelector];
    }
    return sig;
}

// Invoke the invocation on whichever real object had a signature for it.
- (void)forwardInvocation:(NSInvocation *)invocation
{
    id obj = nil != [_target methodSignatureForSelector:invocation.selector] ? _target : _origin;
    [invocation invokeWithTarget:obj];
}

// Override some of NSProxy's implementations to forward them...
- (BOOL)respondsToSelector:(SEL)aSelector {
    
    if ([_target respondsToSelector:aSelector] || [_origin respondsToSelector:aSelector]) {
        return YES;
    }
    return NO;
}

@end
