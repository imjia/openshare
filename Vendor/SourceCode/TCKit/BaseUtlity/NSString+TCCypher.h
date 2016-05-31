//
//  NSString+TCCypher.h
//  TCKit
//
//  Created by dake on 15/3/11.
//  Copyright (c) 2015年 dake. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (TCCypher)

// for AES
- (instancetype)AES256EncryptWithKey:(NSString *)key;
- (instancetype)AES256DecryptWithKey:(NSString *)key;

// for MD5
- (instancetype)MD5_32;
- (instancetype)MD5_16;

- (instancetype)SHA_1;

@end
