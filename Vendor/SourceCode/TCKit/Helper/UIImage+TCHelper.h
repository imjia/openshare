//
//  UIImage+TCHelper.h
//  TCKit
//
//  Created by cdk on 15/5/13.
//  Copyright (c) 2015年 dake. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (TCHelper)

+ (instancetype)imageWithContentsOfName:(NSString *)name;

- (instancetype)fitToScreenScale;

@end
