//
//  ViewController.m
//  openshare
//
//  Created by LiuLogan on 15/5/20.
//  Copyright (c) 2015年 OpenShare http://openshare.gfzj.us/. All rights reserved.
//

#import "ViewController.h"
#import "UIControl+Blocks.h"
#import "OpenShareHeader.h"
#import "OpenShareManager.h"

@interface ViewController ()

@end

@implementation ViewController
{
    @private
    OSMessage *_message;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    OSDataItem *dataItem = [[OSDataItem alloc] init];
    dataItem.title = @"testTitletestTitletestTitletestTitletestTitletestTitletestTitletestTitletestTitletestTitletestTitletestTitletestTitletestTitletestTitletestTitletestTitletestTitletestTitletestTitletestTitle";
    dataItem.desc = @"testDes";
    dataItem.link = @"http://www.baidu.com";
    dataItem.imageUrl = @"http://i.k1982.com/design_img/201109/201109011617318631.jpg";
//    dataItem.imageData = UIImagePNGRepresentation([UIImage imageNamed:@"logo.gif"]);
    dataItem.thumbnailData = UIImagePNGRepresentation([UIImage imageNamed:@"2.png"]);
    
    [dataItem setValue:@"wx" forKey:PropertySTR(title) forPlatform:kOSPlatformWXSession];
    
    _message = [[OSMessage alloc] init];
    _message.dataItem = dataItem;
    _message.multimediaType = OSMultimediaTypeNews;
    
//    [_message configAppItem:^(OSAppItem *item) {
//        item.appId = @"1104480569";
//        item.callBackName = [NSString stringWithFormat: @"QQ%02llx", @(1104480569).longLongValue];
//    } forApp:kQQScheme];

    
    NSArray *appName = @[@"qq", @"qq空间",@"微信朋友圈", @"微信好友",@"新浪微博", @"短信",@"邮件"];
    UIButton *invokeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    invokeBtn.frame = CGRectMake(0, 100, self.view.frame.size.width - 40, 60);
    invokeBtn.center = CGPointMake(self.view.center.x, invokeBtn.center.y);
    invokeBtn.backgroundColor = [[UIColor greenColor] colorWithAlphaComponent:0.5];
    [invokeBtn setTitle:@"分享" forState:UIControlStateNormal];
    [invokeBtn addEventHandler:^(id sender) {
        [[OpenShareManager defaultManager] shareMsg:_message inController:self sns:@[@(kOSPlatformQQ), @(kOSPlatformWXTimeLine), @(kOSPlatformWXSession), @(kOSPlatformSina), @(kOSPlatformSms), @(kOSPlatformEmail)] completion:^(OSPlatform platform, OSShareState state, NSString *errorDescription) {
            NSString *stateStr = nil;
            if (kOSStateNotInstalled == state) {
                stateStr = @"未安装";
            } else if (kOSStateSuccess == state) {
                stateStr = @"成功";
            } else {
                stateStr = @"失败";
            }
            
            DLog(@"APP:%@ 分享状态: %@  失败信息:%@",appName[platform] ,stateStr, errorDescription);
        }];
        
    } forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:invokeBtn];
    
    
}

@end