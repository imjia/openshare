//
//  OSSnsItemController.m
//  OpenShare_2
//
//  Created by jia on 16/5/3.
//  Copyright © 2016年 Jia. All rights reserved.
//

#import "OSSnsItemController.h"

static NSString *const kCellIdentifier = @"UICollectionViewCell";
static NSInteger const kContentBtnTag = 1024;

@interface OSSnsItemController () <UICollectionViewDataSource, UICollectionViewDelegate>

@end

@implementation OSSnsItemController {
    @private
    UICollectionView *_collectionView;
    NSArray *_sns;
    NSDictionary *_snsConfig;
    UIView *_grayTouchView;
}

- (NSBundle *)openShareBundle
{
    static dispatch_once_t onceToken;
    static NSBundle *bundle = nil;
    dispatch_once(&onceToken, ^{
        NSURL *url = [[NSBundle mainBundle] URLForResource:@"OpenShare" withExtension:@"bundle"];
        if (nil != url) {
            bundle = [NSBundle bundleWithURL:url];
        }
    });
    return bundle;
}

- (UIImage *)snsImageNamed:(NSString *)name
{
    NSString *path = [[NSString alloc] initWithFormat:@"OpenShare.bundle/%@", name];
    return [UIImage imageNamed:path];
}

- (NSDictionary *)snsConfig
{
    if (nil == _snsConfig) {
        
        _snsConfig = @{@(kOSPlatformQQ): @{@"name": NSLocalizedStringFromTableInBundle(@"os.platform.qq", nil, self.openShareBundle, nil),
                                           @"image": [self snsImageNamed:@"os_qq_icon.png"]},
                       @(kOSPlatformQQZone): @{@"name": NSLocalizedStringFromTableInBundle(@"os.platform.qzone", nil, self.openShareBundle, nil),
                                               @"image": [self snsImageNamed:@"os_qzone_icon.png"]},
                       @(kOSPlatformWXSession): @{@"name": NSLocalizedStringFromTableInBundle(@"os.platform.wxsession", nil, self.openShareBundle, nil),
                                                  @"image": [self snsImageNamed:@"os_wechat_icon.png"]},
                       @(kOSPlatformWXTimeLine): @{@"name":NSLocalizedStringFromTableInBundle(@"os.platform.wxtimeline", nil, self.openShareBundle, nil),
                                                   @"image": [self snsImageNamed:@"os_wechat_timeline_icon.png"]},
                       @(kOSPlatformSina): @{@"name": NSLocalizedStringFromTableInBundle(@"os.platform.sina", nil, self.openShareBundle, nil),
                                             @"image": [self snsImageNamed:@"os_sina_icon.png"]},
                       @(kOSPlatformEmail): @{@"name": NSLocalizedStringFromTableInBundle(@"os.platform.email", nil, self.openShareBundle, nil),
                                              @"image": [self snsImageNamed:@"os_email_icon.png"]},
                       @(kOSPlatformSms): @{@"name": NSLocalizedStringFromTableInBundle(@"os.platform.sms", nil, self.openShareBundle, nil),
                                            @"image": [self snsImageNamed:@"os_sms_icon.png"]}};
    }
    return _snsConfig;
}

- (instancetype)initWithSns:(NSArray<NSNumber *> *)sns
{
    if (self = [super init]) {
        NSMutableArray *snsItems = [NSMutableArray array];
        for (NSNumber *num in sns) {
            OSSnsItem *snsItem = [[OSSnsItem alloc] init];
            
            snsItem.displayName = NSLocalizedStringFromTableInBundle(@"os.platform.wxtimeline", nil, self.openShareBundle, nil);
            snsItem.displayName = self.snsConfig[num][@"name"];
            snsItem.displayIcon = self.snsConfig[num][@"image"];
            
            [snsItems addObject:snsItem];
        }
        _sns = snsItems;
    }

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _grayTouchView = [[UIView alloc] initWithFrame:self.view.frame];
    _grayTouchView.backgroundColor = [UIColor grayColor];
    _grayTouchView.alpha = 0;
    
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDismiss)];
    [_grayTouchView addGestureRecognizer:tapGes];
    [self.view addSubview:_grayTouchView];
    
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
    rect.origin.y = self.view.bounds.size.height;
    
    _collectionView = [[UICollectionView alloc] initWithFrame:rect collectionViewLayout:layout];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kCellIdentifier];
    _collectionView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:_collectionView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self show];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _sns.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellIdentifier forIndexPath:indexPath];
    
    UIButton *contentBtn = [cell.contentView viewWithTag:kContentBtnTag];
    if (nil == contentBtn) {
        contentBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        contentBtn.frame = CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height);
        contentBtn.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        contentBtn.tag = 1024;
        contentBtn.userInteractionEnabled = NO;
        contentBtn.layoutStyle = kTCButtonLayoutStyleImageTopTitleBottom;
        [cell.contentView addSubview:contentBtn];
    }
    
    OSSnsItem *sns = _sns[indexPath.item];
    [contentBtn setTitle:sns.displayName forState:UIControlStateNormal];
    [contentBtn setImage:sns.displayIcon forState:UIControlStateNormal];

    return cell;
}


#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self dismiss:^{
        if (nil != _delegate && [_delegate respondsToSelector:@selector(OSSnsItemController:didSelectSnsItem:)]) {
            OSSnsItem *sns = _sns[indexPath.item];
            [_delegate OSSnsItemController:self didSelectSnsItem:sns];
        }
    }];
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tapDismiss
{
    [self dismiss:^{
        if (nil != _delegate && [_delegate respondsToSelector:@selector(OSSnsItemControllerWillDismiss:)]) {
            [_delegate OSSnsItemControllerWillDismiss:self];
        }
    }];
}

- (void)show
{
    CGPoint center = _collectionView.center;
    center.y = self.view.bounds.size.height - _collectionView.frame.size.height / 2;
    
    [UIView animateWithDuration:0.35 animations:^{
        _collectionView.center = center;
        _grayTouchView.alpha = 1;
    } completion:^(BOOL finished) {
    }];
}

- (void)dismiss:(void(^)())completion
{
    CGPoint center = _collectionView.center;
    center.y = self.view.bounds.size.height + _collectionView.frame.size.height;
    
    [UIView animateWithDuration:0.35f animations:^{
        _collectionView.center = center;
        _grayTouchView.alpha = 0;
    } completion:^(BOOL finished) {
        if (nil != completion) {
            completion();
        }
    }];
}

@end

@implementation OSSnsItem

@end
