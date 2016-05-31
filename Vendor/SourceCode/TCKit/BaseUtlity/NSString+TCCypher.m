//
//  NSString+TCCypher.m
//  TCKit
//
//  Created by dake on 15/3/11.
//  Copyright (c) 2015年 dake. All rights reserved.
//

#import "NSString+TCCypher.h"
#import <CommonCrypto/CommonDigest.h>
#import "NSData+TCCypher.h"


#if ! __has_feature(objc_arc)
#error this file is ARC only. Either turn on ARC for the project or use -fobjc-arc flag
#endif

@implementation NSString (TCCypher)


#pragma mark - AES

- (instancetype)AES256EncryptWithKey:(NSString *)key
{
    NSData *data = [[self dataUsingEncoding:NSUTF8StringEncoding] AES256EncryptWithKey:key];
    return [data base64EncodedStringWithOptions:kNilOptions];
}

- (instancetype)AES256DecryptWithKey:(NSString *)key
{
    NSData *data = [[[NSData alloc] initWithBase64EncodedString:self options:kNilOptions] AES256DecryptWithKey:key];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

- (instancetype)MD5_32
{
    if (self.length < 1) {
        return nil;
    }
    
    const char *value = self.UTF8String;
    unsigned char outputBuffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(value, (CC_LONG)strlen(value), outputBuffer);
    
    NSMutableString *outputString = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (NSInteger count = 0; count < CC_MD5_DIGEST_LENGTH; ++count) {
        [outputString appendFormat:@"%02x",outputBuffer[count]];
    }
    
    return outputString;
}

- (instancetype)MD5_16
{
    NSString *str = self.MD5_32;
    return nil != str ? [str substringWithRange:NSMakeRange(8, 16)] : str;
}

- (instancetype)SHA_1
{
    if (self.length < 1) {
        return nil;
    }
    
    const char *value = self.UTF8String;
    
    size_t len = strlen(value);
    Byte byteArray[len];
    for (NSInteger i = 0; i < len; ++i) {
        unsigned eachChar = *(value + i);
        byteArray[i] = eachChar & 0xFF;
    }
    
    unsigned char outputBuffer[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(byteArray, (CC_LONG)len, outputBuffer);
    
    NSMutableString *outputString = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    for (NSInteger count = 0; count < CC_SHA1_DIGEST_LENGTH; ++count) {
        [outputString appendFormat:@"%02x",outputBuffer[count]];
    }
    
    return outputString;
}


@end
