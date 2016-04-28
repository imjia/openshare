//
//  ViewController.m
//  openshare
//
//  Created by LiuLogan on 15/5/20.
//  Copyright (c) 2015年 OpenShare http://openshare.gfzj.us/. All rights reserved.
//

#import "ViewController.h"
#import "UIControl+Blocks.h"
#import "OpenShare+QQ.h"
#import "OpenShare+Weixin.h"
#import "OpenShare+SinaWeibo.h"
#import "OpenShare.h"
#import "OSDataItem.h"

@interface ViewController ()

@end

@implementation ViewController
{
    NSDictionary *icons;
    UIScrollView *panel;
    UIImage *testImage,*testThumbImage;
    NSData *testGifImage,*testFile;

    OSMessage *_message;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //初始化测试数据
    testImage = [UIImage imageNamed:@"Default"];//[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Default@2x" ofType:@"png"]];
    testThumbImage= [UIImage imageNamed:@"logo"];//[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"logo" ofType:@"png"]];
    testGifImage= [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"logo" ofType:@"gif"]];
    testFile= [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"test" ofType:@"pdf"]];
    
    UIColor *blue=UIColorFromRGB(0x4799dd);
    //    UIColor *red=UIColorFromRGB(0xe3372b);
    
    //按钮图标。 curl http://at.alicdn.com/t/font_1433466220_572933.css|pcregrep --om-separator='\":@\"\\U0000' -o1 -o2 '.icon-(.*?):before { content: "\\(.*?)"' |while read line;do echo "@\"${line}\",";done|sed 's/-/_/g'
    
    icons = @{@"weibo":@"\U0000e600",
              @"weixin":@"\U0000e601",
              @"qq":@"\U0000e602",
              @"alipay":@"\U0000e605",
              };
    
    self.navigationItem.title=@"OpenShare 测试";
    self.view.backgroundColor=[UIColor whiteColor];
    
    CGFloat buttonWidth = 60.0f;
    CGFloat space = (self.view.frame.size.width - buttonWidth * icons.count)/(icons.count + 1);
    
    for (NSString *icon in @[@"weibo",@"qq",@"weixin",@"alipay"]) {
        static NSInteger i = 0;
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.layer.cornerRadius=buttonWidth/2;
        btn.clipsToBounds=YES;
        btn.frame = CGRectMake(i * buttonWidth + (i+1) * space, MARGIN_TOP+10, buttonWidth, buttonWidth);
        btn.layer.borderColor=blue.CGColor;
        btn.layer.borderWidth=1;
        [btn setBackgroundImage:[self imageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
        [btn setBackgroundImage:[self imageWithColor:blue] forState:UIControlStateSelected];
        [btn setTitleColor:blue forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        btn.titleLabel.font=[UIFont fontWithName:@"openshare" size:buttonWidth/2];
        [btn setTitle:icons[icon] forState:UIControlStateNormal];
        [self.view addSubview:btn];
        i++;
        [btn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
        btn.tag=i;
    }
    //big panel uiscrollview
    float fromY=calcYFrom([self.view viewWithTag:1])+10;
    panel=[[UIScrollView alloc] initWithFrame:CGRectMake(0,fromY , SCREEN_WIDTH, SCREEN_HEIGHT-fromY)];
    [self.view addSubview:panel];
//    panel.hidden=YES;
    panel.contentSize=CGSizeMake(SCREEN_WIDTH*(icons.count+1), SCREEN_HEIGHT-fromY);
    panel.pagingEnabled=YES;
    panel.scrollEnabled=NO;
    //第一屏。一个logo
    [panel addSubview:({
        UIImageView *imgView=[[UIImageView alloc] init];
        UIImage *img=[UIImage imageNamed:@"Default"];
        imgView.image=img;
        imgView.frame=CGRectMake(panel.frame.size.width/2-img.size.width/2, panel.frame.size.height/2-img.size.height/2, img.size.width, img.size.height);
        imgView;
    })];
    
    //测试分享的view
    NSInteger fromX= 0;
    CGRect frame=CGRectMake(0, 10, SCREEN_WIDTH-fromX*2, panel.frame.size.height);
    NSArray *views=@[[UIView new],[self sinaWeiboView:frame],[self qqView:frame],[self weixinView:frame],[self alipayView:frame]];
    for (int i=1; i<=icons.count; i++) {
        UIView *view=views[i];
        view.tag=100+i;
        view.frame=CGRectMake(i*SCREEN_WIDTH, view.frame.origin.y, SCREEN_WIDTH,panel.frame.size.height);
        [panel addSubview:view];
    }
    
    OSDataItem *dataItem = [[OSDataItem alloc] init];
    dataItem.title = @"testTitletestTitletestTitletestTitletestTitletestTitletestTitletestTitletestTitletestTitletestTitletestTitletestTitletestTitletestTitletestTitletestTitletestTitletestTitletestTitletestTitle";
    dataItem.desc = @"testDes";
    dataItem.link = @"http://www.baidu.com";
    dataItem.imageData = UIImageJPEGRepresentation([UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_pet000@2x" ofType:@"jpg"]], 0.8);
    _message = [[OSMessage alloc] init];
    _message.dataItem = dataItem;
    [_message configDataItem:^(OSDataItem *item) {
        item.title = @"wx";
    } forApp:kWXScheme];
    
}

- (UIButton *)button:(NSString *)title WithCenter:(CGPoint)center
{
    UIButton *btn=[UIButton buttonWithType:UIButtonTypeSystem];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn sizeToFit];
    btn.center=center;
    return btn;
}

#pragma mark 支付宝测试

-(UIView *)alipayView:(CGRect)frame
{
    UIView *view=[[UIView alloc]initWithFrame:frame];
    UIButton *alipay=[self button:@"支付宝支付" WithCenter:CGPointMake(frame.size.width/2, 40)];
    [view addSubview:alipay];
    [alipay addEventHandler:^(UIButton* sender) {
        
    } forControlEvents:UIControlEventTouchUpInside];
    
    
    return view;
}

#pragma mark 新浪微博测试
-(UIView *)sinaWeiboView:(CGRect)frame
{
    UIView *ret=[[UIView alloc] initWithFrame:frame];
    UIButton *auth=[self button:@"登录" WithCenter:CGPointMake(frame.size.width/2, 40)];
    [ret addSubview:auth];
    [auth addEventHandler:^(id sender) {
       
    } forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *textShare=[self button:@"分享纯文本" WithCenter:CGPointMake(auth.center.x, calcYFrom(auth)+40)];
    [ret addSubview:textShare];
    textShare.tag=1001;
    [textShare addTarget:self action:@selector(weiboViewHandler:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *imgShare=[self button:@"分享图片" WithCenter:CGPointMake(auth.center.x, calcYFrom(textShare)+40)];
    [ret addSubview:imgShare];
    imgShare.tag=1002;
    [imgShare addTarget:self action:@selector(weiboViewHandler:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *newsShare=[self button:@"分享新闻" WithCenter:CGPointMake(auth.center.x, calcYFrom(imgShare)+40)];
    [ret addSubview:newsShare];
    newsShare.tag=1003;
    [newsShare addTarget:self action:@selector(weiboViewHandler:) forControlEvents:UIControlEventTouchUpInside];
    
    return ret;
}
- (void)weiboViewHandler:(UIButton *)btn
{
    switch (btn.tag) {
        case 1001: {
             _message.multimediaType = OSMultimediaTypeText;
            break;
        }
        case 1002: {
             _message.multimediaType = OSMultimediaTypeImage;
            break;
        }
        case 1003: {
             _message.multimediaType = OSMultimediaTypeNews;
            break;
        }
        default:
            break;
    }
    
    [OpenShare shareToSinaWeibo:_message completion:^(NSError *error) {
        DLog(@"新浪微博分享成功");
    }];
}

#pragma mark QQ分享／登录API使用
- (UIView *)qqView:(CGRect)frame
{
    UIView *ret=[[UIView alloc] initWithFrame:frame];
    UISegmentedControl *seg=[[UISegmentedControl alloc] initWithItems:@[@"登录",@"QQ好友",@"QQ空间",@"收藏",@"数据线"]];
    seg.tag=2002;
    seg.center=CGPointMake(frame.size.width/2, 20);
    seg.selectedSegmentIndex=0;
    [ret addSubview:seg];
    
    UIView *loginView=[[UIView alloc] initWithFrame:CGRectMake(0, 40, frame.size.width, frame.size.height-40)];
    loginView.backgroundColor=[UIColor whiteColor];
    UIButton *auth=[self button:@"QQ登录" WithCenter:CGPointMake(frame.size.width/2, 40)];
    [loginView addSubview:auth];
    [auth addEventHandler:^(id sender) {
      
    } forControlEvents:UIControlEventTouchUpInside];
    UIButton *chat=[self button:@"和我聊天" WithCenter:CGPointMake(frame.size.width/2, calcYFrom(auth)+40)];
    [loginView addSubview:chat];
    [chat addEventHandler:^(id sender) {
        
    } forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *chatGroup=[self button:@"指定群聊天(必须是群成员)" WithCenter:CGPointMake(frame.size.width/2, calcYFrom(chat)+40)];
    [loginView addSubview:chatGroup];
    [chatGroup addEventHandler:^(id sender) {
       
    } forControlEvents:UIControlEventTouchUpInside];
    
    UIView *shareView=[[UIView alloc] initWithFrame:loginView.frame];
    shareView.backgroundColor=[UIColor whiteColor];
   
    NSArray *titles=@[@"分享文本消息",@"分享图片消息",@"分享新闻消息",@"分享音频消息",@"分享视频消息"];
    for (int i=0; i<titles.count; i++) {
        UIButton *btn=[self button:titles[i] WithCenter:CGPointMake(frame.size.width/2, 20+40*i)];
        [shareView addSubview:btn];
        [btn addTarget:self action:@selector(qqViewHandler:) forControlEvents:UIControlEventTouchUpInside];
        btn.tag=i+1;
    }
    [ret addSubview:shareView];
    [ret addSubview:loginView];
    
    [seg addEventHandler:^(id sender) {
        UISegmentedControl *seg=sender;
        if (seg.selectedSegmentIndex==0) {
            [ret bringSubviewToFront:loginView];
        }else{
            [ret bringSubviewToFront:shareView];
        }
    } forControlEvents:UIControlEventValueChanged];
    
    return ret;
}
- (void)qqViewHandler:(UIButton *)btn
{

    switch (btn.tag) {
        case 1: {
            _message.multimediaType = OSMultimediaTypeText;
            break;
        }
        case 2: {
            _message.multimediaType = OSMultimediaTypeImage;
            break;
        }
        case 3: {
            _message.multimediaType = OSMultimediaTypeNews;
            break;
        }
        case 4: {
            _message.multimediaType = OSMultimediaTypeAudio;
            break;
        }
        case 5: {
            _message.multimediaType = OSMultimediaTypeVideo;
            break;
        }
        default:
            break;
    }
    [OpenShare shareToQQ:_message completion:^(NSError *error) {
                DLog(@"qq分享成功");
    }];
}

#pragma mark 微信分享相关
- (UIView *)weixinView:(CGRect)frame
{
    UIView *ret=[[UIView alloc] initWithFrame:frame];
    UISegmentedControl *seg=[[UISegmentedControl alloc] initWithItems:@[@"登录",@"会话",@"朋友圈",@"收藏"]];
    seg.selectedSegmentIndex=0;
    seg.tag=3003;
    seg.center=CGPointMake(frame.size.width/2, 20);
    [ret addSubview:seg];
    
    NSArray *titles=@[@"发送Text消息",@"发送Photo消息",@"发送Link消息",@"发送Music消息",@"发送Video消息",@"发送App消息",@"发送非gif表情",@"发送gif表情",@"发送文件消息"];
    NSArray *fromX=@[@(frame.size.width/4),@(frame.size.width*3/4)];
    int fromY=calcYFrom(seg)+ 40;
    for (int i=0; i<titles.count;i++ ) {
        UIButton *btn=[self button:[titles[i] stringByAppendingFormat:@"%d",i+1] WithCenter:CGPointMake([fromX[i%2] intValue], fromY)];
        [ret addSubview:btn];
        [btn addTarget:self action:@selector(weixinViewHandler:) forControlEvents:UIControlEventTouchUpInside];
        btn.tag=30001+i;
        if (i%2) {
            fromY+=40;
        }
    }
    
    UIView *loginView=[[UIView alloc]initWithFrame:CGRectMake(0, calcYFrom(seg)+30, frame.size.width, frame.size.height)];
    loginView.backgroundColor=[UIColor whiteColor];
    UIButton *loginBtn=[self button:@"登录(appid需要通过认证,300/年)" WithCenter:CGPointMake(loginView.frame.size.width/2,0)];
    loginBtn.tag=30000;
    [loginView addSubview:loginBtn];
    [loginBtn addTarget:self action:@selector(weixinViewHandler:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *payBtn=[self button:@"微信支付（需要在pay.php中设置支付参数）" WithCenter:CGPointMake(loginView.frame.size.width/2,40)];
    payBtn.tag=40001;
    [loginView addSubview:payBtn];
    [payBtn addTarget:self action:@selector(weixinViewHandler:) forControlEvents:UIControlEventTouchUpInside];
    
    
    [ret addSubview:loginView];
    [seg addEventHandler:^(UISegmentedControl *seg) {
        loginView.hidden=seg.selectedSegmentIndex!=0;
    } forControlEvents:UIControlEventValueChanged];
    return ret;
}

- (void)weixinViewHandler:(UIButton *)btn
{
    switch (btn.tag) {
        case 30001: {
            _message.multimediaType = OSMultimediaTypeText;
            break;
        }
        case 30002: {
            _message.multimediaType = OSMultimediaTypeImage;
            break;
        }
        case 30003: {
            _message.multimediaType = OSMultimediaTypeNews;
            break;
        }
        case 30004: {
            _message.multimediaType = OSMultimediaTypeAudio;
            break;
        }
        case 30005: {
            _message.multimediaType = OSMultimediaTypeVideo;
            break;
        }
        case 30006: {
            _message.multimediaType = OSMultimediaTypeApp;
            break;
        }
        case 30007: {
            _message.multimediaType = OSMultimediaTypeFile;
            break;
        }
        case 30008: {
            _message.multimediaType = OSMultimediaTypeImage;
            [_message configDataItem:^(OSDataItem *item) {
                item.wxFileData = testGifImage;
            } forApp:kWXScheme];
            
            break;
        }
        default:
            break;
    }
    switch ([(UISegmentedControl*)[panel viewWithTag:3003] selectedSegmentIndex]) {
        case 1:{
            [OpenShare shareToWeixinSession:_message completion:^(NSError *error) {
                DLog(@"微信分享成功");
            }];
            break;
        }
        case 2:{
            [OpenShare shareToWeixinTimeLine:_message completion:^(NSError *error) {
                DLog(@"微信朋友圈分享成功");
            }];
            break;
        }
        default:
            break;
    }

}

- (void)btnClicked:(UIButton *)btn
{
    btn.selected=!btn.selected;
    for (int i=1; i<=icons.count; i++) {
        if (i!=btn.tag) {
            [(UIButton*)[self.view viewWithTag:i] setSelected:NO];
        }
    }
    [panel setContentOffset:CGPointMake(btn.selected? btn.tag*SCREEN_WIDTH:0, 0) animated:YES];
}

#pragma mark 测试代码UI相关

- (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end