//
//  OpenShare+Mail.m
//  OpenShare_2
//
//  Created by jia on 16/5/3.
//  Copyright © 2016年 Jia. All rights reserved.
//

#import "OpenShare+Mail.h"
#import "OpenShare+Helper.h"
#import "UIWindow+TCHelper.h"

@implementation OpenShare (Mail)

+ (void)shareToMail:(OSMessage *)msg delegate:(id<MFMailComposeViewControllerDelegate>)delegate
{
    if (MFMailComposeViewController.canSendMail) {
        MFMailComposeViewController *mailComposeCtrler = [[MFMailComposeViewController alloc] init];
        mailComposeCtrler.mailComposeDelegate = delegate;
        [mailComposeCtrler setToRecipients:msg.dataItem.toRecipients];
        [mailComposeCtrler setCcRecipients:msg.dataItem.ccRecipients];
        mailComposeCtrler.subject = msg.dataItem.emailSubject;
        [mailComposeCtrler setMessageBody:msg.dataItem.emailBody isHTML:YES];
        
        if (OSMultimediaTypeImage == msg.multimediaType && nil != msg.dataItem.imageData) {
            NSString *imageType = [OpenShare contentTypeForImageData:msg.dataItem.imageData];
            NSRange range = [imageType rangeOfString:@"image/"];
            if (range.location != NSNotFound) {
                NSString *fileName = [NSString stringWithFormat:@"image.%@", [imageType substringFromIndex:range.location + range.length]];
                [mailComposeCtrler addAttachmentData:msg.dataItem.imageData mimeType:imageType fileName:fileName];
            }
        }
        
        [[UIApplication sharedApplication].delegate.window.topMostViewController presentViewController:mailComposeCtrler animated:YES completion:nil];
    } else {
        // 打开email配置页面 FIXME: 空信息 canopen 
//        static NSString *const recipients = @"mailto:first@example.com?cc=second@example.com,third@example.com&subject=Hello from California!";
        NSString *email = @"mailto:";
        if (msg.dataItem.toRecipients.count > 0) {
            [email stringByAppendingFormat:@"%@", [msg.dataItem.toRecipients componentsJoinedByString:@","]];
        } else {
//            [email stringByAppendingString:@"first@example.com"];
        }
        
        if (msg.dataItem.ccRecipients.count > 0) {
            [email stringByAppendingFormat:@"?cc=%@", [msg.dataItem.ccRecipients componentsJoinedByString:@","]];
        } else {
//            [email stringByAppendingString:@"?cc=second@example.com"];
        }

        [email stringByAppendingString:[NSString stringWithFormat:@"&subject=%@", msg.dataItem.emailSubject]];
        [email stringByAppendingString:[NSString stringWithFormat:@"&body=%@", msg.dataItem.emailBody]];
        email = [email stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:email]];
    }
}

@end
