//
//  OSQQParameter.m
//  OpenShare_2
//
//  Created by jia on 16/4/27.
//  Copyright © 2016年 Jia. All rights reserved.
//

#import "OSQQParameter.h"

@implementation OSQQParameter

+ (TCMappingOption *)tc_mappingOption
{
    static TCMappingOption *opt = nil;
    
    if (nil == opt) {
        opt = [[TCMappingOption alloc] init];
        opt.nameDictionaryMapping = @{PropertySTR(desc): @"description"};
    }
    
    return opt;
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone
{
    return self.tc_copy;
}

@end

@implementation OSQQResponse

+ (TCMappingOption *)tc_mappingOption
{
    static TCMappingOption *opt = nil;
    
    if (nil == opt) {
        opt = [[TCMappingOption alloc] init];
        opt.nameDictionaryMapping = @{PropertySTR(errorCode): @"error"};
    }
    
    return opt;
}

- (NSError *)error
{
    NSError *error = nil;
    if (0 != self.errorCode) {
        NSDictionary *userInfo = [NSDictionary dictionary];
        if (nil != _error_description) {
            userInfo = @{NSLocalizedFailureReasonErrorKey: @"分享失败",
                         NSLocalizedDescriptionKey: _error_description};
        }
        
        error = [NSError errorWithDomain:@"response_from_qq"
                                             code:_errorCode
                                         userInfo:userInfo];
    }
    return error;
}

@end
