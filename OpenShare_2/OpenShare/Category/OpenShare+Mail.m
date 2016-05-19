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
        NSMutableString *email = [[NSMutableString alloc] initWithString:@"mailto:"];
        if (msg.dataItem.toRecipients.count > 0) {
            [email appendFormat:@"%@?", [msg.dataItem.toRecipients componentsJoinedByString:@","]];
        } else {
            [email appendString:@"?"];
        }
        
        if (msg.dataItem.ccRecipients.count > 0) {
            [email appendFormat:@"cc=%@", [msg.dataItem.ccRecipients componentsJoinedByString:@","]];
        }
        
        if (nil != msg.dataItem.emailSubject) {
            [email appendString:[NSString stringWithFormat:@"&subject=%@", msg.dataItem.emailSubject]];
        }
        if (nil != msg.dataItem.emailBody) {
            [email appendString:[NSString stringWithFormat:@"&body=%@", msg.dataItem.emailBody]];
        }
        
        NSString *url = [email stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    }
}

@end
