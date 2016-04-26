//
//  OpenShare+Helper.m
//  OpenShare_2
//
//  Created by jia on 16/3/22.
//  Copyright © 2016年 Jia. All rights reserved.
//

#import "OpenShare+Helper.h"

@implementation OpenShare (Helper)

+ (NSMutableDictionary *)parametersOfURL:(NSURL *)url
{
    NSMutableDictionary *queryStringDictionary = [[NSMutableDictionary alloc] init];
    NSArray *urlComponents = [url.query componentsSeparatedByString:@"&"];
    for (NSString *keyValuePair in urlComponents) {
        NSRange range = [keyValuePair rangeOfString:@"="];
        [queryStringDictionary setObject:range.length > 0 ? [keyValuePair substringFromIndex:range.location + 1] : @""
                                  forKey:(range.length ? [keyValuePair substringToIndex:range.location] : keyValuePair)];
    }
    return queryStringDictionary;
}

+ (NSString *)urlStr:(NSDictionary *)parameters
{
    NSMutableString *urlStr = [[NSMutableString alloc] init];
    for (NSString *key in parameters.allKeys) {
        [urlStr appendFormat:@"%@=%@&", key, parameters[key]];
    }
    
    return [urlStr substringToIndex:urlStr.length - 1];
}

+ (NSString *)base64AndURLEncodedString:(NSString *)inputString
{
    return [[[inputString dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
}

+ (NSString *)base64EncodedString:(NSString *)inputString
{
    return [[inputString dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0];
}

+ (NSString *)base64DecodedString:(NSString *)inputString
{
    return [[NSString alloc ] initWithData:[[NSData alloc] initWithBase64EncodedString:inputString options:0] encoding:NSUTF8StringEncoding];
}

+ (NSString *)urlEncodedString:(NSString *)inputString
{
    return [[inputString stringByReplacingOccurrencesOfString:@"+" withString:@" "]stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

@end
