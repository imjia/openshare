//
//  OpenShare+Sms.m
//  OpenShare_2
//
//  Created by jia on 16/5/3.
//  Copyright © 2016年 Jia. All rights reserved.
//

#import "OpenShare+Sms.h"


@implementation OpenShare (Sms)

+ (void)shareToSms:(OSMessage *)msg inController:(UIViewController<MFMessageComposeViewControllerDelegate> *)ctrler completion:(OSShareCompletionHandle)completionHandle
{
    if (MFMessageComposeViewController.canSendText) {
        MFMessageComposeViewController * controller = [[MFMessageComposeViewController alloc] init];
//        controller.recipients = phones;
        controller.navigationBar.tintColor = [UIColor redColor];
        controller.body = msg.dataItem.msgBody;
        controller.messageComposeDelegate = ctrler;
        [ctrler presentViewController:controller animated:YES completion:nil];
    }
}

@end
