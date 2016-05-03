//
//  OpenShare+Mail.m
//  OpenShare_2
//
//  Created by jia on 16/5/3.
//  Copyright © 2016年 Jia. All rights reserved.
//

#import "OpenShare+Mail.h"

@implementation OpenShare (Mail)

+ (void)shareToMail:(OSMessage *)msg inController:(UIViewController<MFMailComposeViewControllerDelegate> *)ctrler completion:(OSShareCompletionHandle)completionHandle
{
    if ([MFMailComposeViewController canSendMail]) {
        
        //init the e-mail
        MFMailComposeViewController *mailComposeVc = [[MFMailComposeViewController alloc] init];
        mailComposeVc.mailComposeDelegate = ctrler;
        mailComposeVc.subject = msg.dataItem.emailSubject;
        [mailComposeVc setMessageBody:msg.dataItem.emailBody isHTML:YES];
        if (nil != msg.dataItem.imageData) {
            [mailComposeVc addAttachmentData:msg.dataItem.imageData mimeType:@"image/jpeg" fileName:@"pickerimage.jpg"];
        }
        
        [ctrler presentViewController:mailComposeVc animated:YES completion:nil];
    }
    else {
        
        // 打开email配置页面
        static NSString *const recipients = @"mailto:first@example.com?cc=second@example.com,third@example.com&subject=Hello from California!";
        NSString *body = @"&body=It is raining in sunny California!";
        NSString *email = [NSString stringWithFormat:@"%@%@", recipients, body];
        email = [email stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:email]];
        
        //        [self dismiss];
    }

}

@end
