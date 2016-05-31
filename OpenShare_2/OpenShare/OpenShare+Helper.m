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
    NSMutableDictionary *queryStringDictionary = [NSMutableDictionary dictionary];
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
    NSMutableString *urlStr = [NSMutableString string];
    for (NSString *key in parameters.allKeys) {
        [urlStr appendFormat:@"%@=%@&", key, parameters[key]];
    }
    
    return [urlStr substringToIndex:urlStr.length - 1];
}

+ (NSString *)base64AndURLEncodedString:(NSString *)inputString
{
    return [[[inputString dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:kNilOptions] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
}

+ (NSString *)base64EncodedString:(NSString *)inputString
{
    return [[inputString dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:kNilOptions];
}

+ (NSString *)base64DecodedString:(NSString *)inputString
{
    return [[NSString alloc ] initWithData:[[NSData alloc] initWithBase64EncodedString:inputString options:NSDataBase64DecodingIgnoreUnknownCharacters] encoding:NSUTF8StringEncoding];
}

+ (NSString *)urlEncodedString:(NSString *)inputString
{
    return [[inputString stringByReplacingOccurrencesOfString:@"+" withString:@" "]stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

+ (NSString *)contentTypeForImageData:(NSData *)data
{
    uint8_t c = 0;
    [data getBytes:&c length:1];
    switch (c) {
        case 0xFF:
            return @"image/jpeg";
        case 0x89:
            return @"image/png";
        case 0x47:
            return @"image/gif";
        case 0x49:
        case 0x4D:
            return @"image/tiff";
        case 0x52:
            // R as RIFF for WEBP
            if (data.length < 12) {
                return nil;
            }
            
            NSString *testString = [[NSString alloc] initWithData:[data subdataWithRange:NSMakeRange(0, 12)] encoding:NSASCIIStringEncoding];
            if ([testString hasPrefix:@"RIFF"] && [testString hasSuffix:@"WEBP"]) {
                return @"image/webp";
            }
            
            return nil;
    }
    return nil;
}


@end
