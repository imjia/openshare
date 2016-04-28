//
//  OSDataItem.h
//  OpenShare_2
//
//  Created by jia on 16/4/27.
//  Copyright © 2016年 Jia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OSDataItem : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *desc;
@property (nonatomic, copy) NSString *link;
@property (nonatomic, strong) id thumbnail;
@property (nonatomic, strong) NSData *imageData;
@property (nonatomic, strong) NSData *thumbnailData;

// for weixin
@property (nonatomic, copy) NSString *extInfo;
@property (nonatomic, copy) NSString *mediaDataUrl;
@property (nonatomic, copy) NSString *fileExt;
@property (nonatomic, strong) NSData *file;   /// 微信分享gif/文件


// for weixin
@property (nonatomic, strong) NSData *wxFileData;
@property (nonatomic, copy) NSString *wxExtInfo;
@property (nonatomic, copy) NSString *wxFileExt;

@end
