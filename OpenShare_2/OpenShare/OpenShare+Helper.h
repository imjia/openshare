//
//  OpenShare+Helper.h
//  OpenShare_2
//
//  Created by jia on 16/3/22.
//  Copyright © 2016年 Jia. All rights reserved.
//

#import "OpenShare.h"

@interface OpenShare (Helper)

+ (NSMutableDictionary *)parametersOfURL:(NSURL *)url;
+ (NSString *)urlStr:(NSDictionary *)parameters;
+ (NSString *)base64EncodedString:(NSString *)inputString;
+ (NSString *)base64DecodedString:(NSString *)inputString;
+ (NSString *)urlEncodedString:(NSString *)inputString;
+ (NSString *)base64AndURLEncodedString:(NSString *)inputString;
+ (NSString *)contentTypeForImageData:(NSData *)data;

@end
