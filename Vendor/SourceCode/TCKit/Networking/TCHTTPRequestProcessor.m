//
//  TCHTTPRequestProcessor.m
//  TCKit
//
//  Created by dake on 15/3/19.
//  Copyright (c) 2015年 dake. All rights reserved.
//

#import "TCHTTPRequestProcessor.h"


typedef void (*TCSuccessMethodType)(id, SEL, NSObject *obj);
typedef void (*TCFailedMethodType)(id, SEL, NSObject *obj1, NSObject *obj2);

@implementation TCHTTPRequestProcessor


- (instancetype)init
{
    self = [super init];
    if (self) {
        NSString *className = NSStringFromClass(self.class);
        _successSelector = NSSelectorFromString([className stringByAppendingString:@"Success:"]);
        _failureSelector = NSSelectorFromString([className stringByAppendingString:@"Failed:error:"]);
    }
    return self;
}

- (void)successWithDelegate:(id)delegate info:(id)info
{
    if ([delegate respondsToSelector:self.successSelector]) {
        TCSuccessMethodType methodToCall = (TCSuccessMethodType)[delegate methodForSelector:self.successSelector];
        methodToCall(delegate, self.successSelector, info);
    }
}

- (void)failWithDelegate:(id)delegate info:(id)info error:(NSError *)error
{
    if ([delegate respondsToSelector:self.failureSelector]) {
        TCFailedMethodType methodToCall = (TCFailedMethodType)[delegate methodForSelector:self.failureSelector];
        methodToCall(delegate, self.failureSelector, info, error);
    }
}


+ (void)processRequest:(id<TCHTTPRequest>)request success:(BOOL)success
{
  
}

- (void)processRequest:(id<TCHTTPRequest>)request success:(BOOL)success
{

}


@end
