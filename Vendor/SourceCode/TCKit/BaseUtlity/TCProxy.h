//
//  TCProxy.h
//  TCKit
//
//  Created by dake on 16/3/18.
//  Copyright © 2016年 dake. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TCProxy : NSProxy

@property (nonatomic, weak) id origin;
@property (nonatomic, weak) id target;

+ (instancetype)proxyWithOrigin:(id)origin target:(id)target;
- (instancetype)initWithOrigin:(id)origin target:(id)target;

@end
