//
//  OSSnsItemView.m
//  OpenShare_2
//
//  Created by jia on 16/5/3.
//  Copyright © 2016年 Jia. All rights reserved.
//

#import "OSSnsItemView.h"
#import "Masonry.h"
#import "TCPopupContainer.h"

@interface OSSnsItemView () <UICollectionViewDataSource, UICollectionViewDelegate>

@end

@implementation OSSnsItemView {
    @private
    UICollectionView *_collectionView;
    NSArray *_sns;
    NSDictionary *_snsConfig;
}

- (NSDictionary *)snsConfig
{
    if (nil == _snsConfig) {
        _snsConfig = @{@(kOSAppQQ) : @{@"name": @"QQ"},
                       @(kOSAppQQZone) : @{@"name": @"QQ空间"},
                       @(kOSAppWXSession) : @{@"name": @"微信好友"},
                       @(kOSAppWXTimeLine) : @{@"name": @"微信朋友圈"},
                       @(kOSAppSina) : @{@"name": @"新浪"},
                       @(kOSAppEmail) : @{@"name": @"邮件"},
                       @(kOSAppSms) : @{@"name": @"短信"}};
    }
    return _snsConfig;
}

- (instancetype)initWithDefaultSnsItems:(NSArray<NSNumber *> *)items
{
    NSMutableArray *snsItems = [NSMutableArray array];
    for (NSNumber *num in items) {
        OSSnsItem *snsItem = [[OSSnsItem alloc] init];
        snsItem.name = self.snsConfig[num][@"name"];
        snsItem.index = num.integerValue;
        [snsItems addObject:snsItem];
    }

    return [self initWithSnsItems:snsItems];
}

- (instancetype)initWithSnsItems:(NSArray<OSSnsItem *> *)items
{
    if (self = [super init]) {
        _sns = items;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 一行4个
    static const NSInteger kItemsOfRow = 4;

    static CGFloat kSpacing = 2.0f;
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.minimumLineSpacing = kSpacing;
    layout.minimumInteritemSpacing = kSpacing;
    
    NSInteger realWidth = UIScreen.mainScreen.bounds.size.width - kSpacing * (kItemsOfRow + 1);
    NSInteger width = realWidth / kItemsOfRow;
    layout.sectionInset = UIEdgeInsetsMake(kSpacing, kSpacing, kSpacing, kSpacing);
    layout.itemSize = (CGSize){.width = width, .height = width};

    NSInteger row = ceil(_sns.count / (CGFloat)kItemsOfRow);
    CGFloat fitHeight = row * width + (row + 1) * kSpacing;
    
    CGRect rect = self.view.bounds;
    rect.size.height = fitHeight;
    self.view.frame = rect;
    self.view.backgroundColor = [UIColor redColor];
    
    _collectionView = [[UICollectionView alloc] initWithFrame:self.view.frame collectionViewLayout:layout];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"UICollectionViewCell"];
    _collectionView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:_collectionView];
    _collectionView.backgroundColor = [UIColor greenColor];
    
    // 默认值
    _config = [OSSnsItemViewConfig tc_mappingWithDictionary:@{@"titleColor": [UIColor whiteColor],
                                                              @"font": [UIFont systemFontOfSize:12.0f]}];
}


#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _sns.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * CellIdentifier = @"UICollectionViewCell";
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.backgroundColor = [UIColor colorWithRed:((10 * indexPath.row) / 255.0) green:((20 * indexPath.row)/255.0) blue:((30 * indexPath.row)/255.0) alpha:1.0f];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, cell.bounds.size.width, cell.bounds.size.height)];
    label.textColor = [UIColor redColor];
    label.text = [_sns[indexPath.item] name];
    label.numberOfLines = 2;
    
    for (id subView in cell.contentView.subviews) {
        [subView removeFromSuperview];
    }
    [cell.contentView addSubview:label];
    return cell;
}


#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (nil != _delegate && [_delegate respondsToSelector:@selector(OSSnsItemView:didSelectSnsItem:)]) {
        OSSnsItem *sns = _sns[indexPath.item];
        [_delegate OSSnsItemView:self didSelectSnsItem:sns];
    }
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

@end

@implementation OSSnsItemViewConfig

@end

@implementation OSSnsItem

@end
