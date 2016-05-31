//
//  NSObject+TCHelper.h
//  TCKit
//
//  Created by dake on 14-5-4.
//  Copyright (c) 2014年 dake. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (TCHelper)

@property (nonatomic, copy) NSString *humanDescription;

// file system
+ (NSString *)defaultPersistentDirectoryInDomain:(NSString *)domain;
+ (NSString *)defaultCacheDirectoryInDomain:(NSString *)domain;
+ (NSString *)defaultTmpDirectoryInDomain:(NSString *)domain;

@end
