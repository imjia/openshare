//
//  OSWXParameter.m
//  OpenShare_2
//
//  Created by jia on 16/4/27.
//  Copyright © 2016年 Jia. All rights reserved.
//

#import "OSWXParameter.h"
#import "OpenShareConfig.h"

@implementation OSWXParameter

+ (TCMappingOption *)tc_mappingOption
{
    static TCMappingOption *opt = nil;
    
    if (nil == opt) {
        opt = [[TCMappingOption alloc] init];
        opt.nameDictionaryMapping = @{PropertySTR(desc): @"description"};
    }
    
    return opt;
}

@end

@implementation OSWXResponse

- (NSError *)error
{
    NSError *error = nil;
    if (0 != _result) {
        NSDictionary *userInfo = @{NSLocalizedFailureReasonErrorKey: @"分享失败",
                                   NSLocalizedDescriptionKey: [NSString stringWithFormat:@"%zd", _result]};
        error = [NSError errorWithDomain:kErrorDomainWeixin
                                    code:_result
                                userInfo:userInfo];
    }
    return error;
}

@end
