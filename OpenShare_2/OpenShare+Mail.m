//
//  OpenShare+Mail.m
//  OpenShare_2
//
//  Created by jia on 16/5/3.
//  Copyright © 2016年 Jia. All rights reserved.
//

#import "OpenShare+Mail.h"
#import "OpenShare+Helper.h"

@implementation OpenShare (Mail)

+ (void)shareToMail:(OSMessage *)msg inController:(UIViewController *)ctrler delegate:(id<MFMailComposeViewControllerDelegate>)delegate
{
    if (MFMailComposeViewController.canSendMail) {
        MFMailComposeViewController *mailComposeCtrler = [[MFMailComposeViewController alloc] init];
        mailComposeCtrler.mailComposeDelegate = delegate;
        mailComposeCtrler.subject = msg.dataItem.emailSubject;
        [mailComposeCtrler setMessageBody:msg.dataItem.emailBody isHTML:YES];
        
        if (nil != msg.dataItem.imageData) {
            NSString *imageType = [OpenShare contentTypeForImageData:msg.dataItem.imageData];
            NSRange range = [imageType rangeOfString:@"image/"];
            if (range.location != NSNotFound) {
                NSString *fileName = [NSString stringWithFormat:@"image.%@", [imageType substringFromIndex:range.location + range.length]];
                [mailComposeCtrler addAttachmentData:msg.dataItem.imageData mimeType:imageType fileName:fileName];
            }
        }
        
        [ctrler presentViewController:mailComposeCtrler animated:YES completion:nil];
    }
    else {
        // 打开email配置页面
        static NSString *const recipients = @"mailto:first@example.com?cc=second@example.com,third@example.com&subject=Hello from California!";
        NSString *body = @"&body=It is raining in sunny California!";
        NSString *email = [NSString stringWithFormat:@"%@%@", recipients, body];
        email = [email stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:email]];
    }
}

@end
