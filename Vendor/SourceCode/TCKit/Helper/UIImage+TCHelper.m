//
//  UIImage+TCHelper.m
//  TCKit
//
//  Created by cdk on 15/5/13.
//  Copyright (c) 2015年 dake. All rights reserved.
//

#import "UIImage+TCHelper.h"

@implementation UIImage (TCHelper)

+ (instancetype)imageWithContentsOfName:(NSString *)name
{
    return [self imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:name ofType:nil]];
}

- (instancetype)fitToScreenScale
{
    CGFloat scale = UIScreen.mainScreen.scale;
    if (scale == self.scale) {
        return self;
    }
    
    return [self.class imageWithCGImage:self.CGImage scale:scale orientation:self.imageOrientation];
}


@end
