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
    dataItem.title = @"testTitle";
    dataItem.content = @"testDes";
    dataItem.link = @"http://sina.cn?a=1";
//    dataItem.imageUrl = [NSURL URLWithString:@"http://i.k1982.com/design_img/201109/201109011617318631.jpg"];
    
    NSString *file = [[NSBundle mainBundle] pathForResource:@"logo" ofType:@"gif"];
    dataItem.imageData = [[NSData alloc] initWithContentsOfFile:file];
    dataItem.thumbnailData = UIImagePNGRepresentation([UIImage imageNamed:@"2.png"]);
    dataItem.emailSubject = @"emailSub";
    dataItem.emailBody = @"emailBody";
//    dataItem.toRecipients = @[@"123@126.com"];
    dataItem.mediaDataUrl = @"http://7qn9mz.com1.z0.glb.clouddn.com/0002.mp3";
    
    [dataItem setValue:@"wx" forKey:PropertySTR(title) forPlatform:kOSPlatformWXSession];
    
    _message = [[OSMessage alloc] init];
    _message.dataItem = dataItem;
    _message.multimediaType = OSMultimediaTypeImage;
    
//    [_message configAppItem:^(OSAppItem *item) {
//        item.appId = @"1104480569";
//        item.callBackName = [NSString stringWithFormat: @"QQ%02llx", @(1104480569).longLongValue];
//    } forApp:kQQScheme];

    UIButton *invokeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    invokeBtn.frame = CGRectMake(0, 100, self.view.frame.size.width - 40, 60);
    invokeBtn.center = CGPointMake(self.view.center.x, invokeBtn.center.y);
    invokeBtn.backgroundColor = [[UIColor greenColor] colorWithAlphaComponent:0.5];
    [invokeBtn setTitle:@"分享" forState:UIControlStateNormal];
    [invokeBtn addEventHandler:^(id sender) {
        [[OpenShareManager defaultManager] shareMsg:_message platformCodes:@[@(kOSPlatformQQ), @(kOSPlatformWXTimeLine), @(kOSPlatformWXSession), @(kOSPlatformSina), @(kOSPlatformSms), @(kOSPlatformEmail)] completion:nil];
    } forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:invokeBtn];
NSString *t = @"a";
    [t stringByAppendingString:@"b"];
}

@end