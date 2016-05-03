//
//  OSDataItem.m
//  OpenShare_2
//
//  Created by jia on 16/4/27.
//  Copyright © 2016年 Jia. All rights reserved.
//

#import "OSDataItem.h"

@implementation OSDataItem


#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone
{
    return self.tc_copy;
}

- (NSString *)msgBody
{
    if (nil == _msgBody) {
        return _title;
    }
    return _msgBody;
}

- (NSString *)emailBody
{
    if (nil == _emailBody) {
        return _title;
    }
    return _emailBody;
}

@end
