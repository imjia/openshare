//
//  OSSnsItemView.h
//  OpenShare_2
//
//  Created by jia on 16/5/3.
//  Copyright © 2016年 Jia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OpenShareConfig.h"

@class OSSnsItemViewConfig;
@class OSSnsItem;
@protocol OSSnsItemViewDelegate;
@interface OSSnsItemView : UIViewController
@property (nonatomic, strong) OSSnsItemViewConfig *config;
@property (nonatomic, weak) id<OSSnsItemViewDelegate> delegate;

- (instancetype)initWithSnsItems:(NSArray<OSSnsItem *> *)items;
- (instancetype)initWithDefaultSnsItems:(NSArray<NSNumber *> *)items;

@end

@protocol OSSnsItemViewDelegate <NSObject>

@optional
- (void)OSSnsItemView:(OSSnsItemView *)itemView didSelectSnsItem:(OSSnsItem *)sns;
- (void)OSSnsItemViewWillDismiss:(OSSnsItemView *)itemView;
@end

@interface OSSnsItemViewConfig : NSObject

@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) UIImage *placeHolder;
@property (nonatomic, strong) NSValue *imageSize;
@property (nonatomic, strong) UIColor *titleColor;

@end

@interface OSSnsItem : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) UIImage *icon;
@property (nonatomic, assign) NSInteger index;

@end
