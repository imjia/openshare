//
//  OpenShare+Sms.m
//  OpenShare_2
//
//  Created by jia on 16/5/3.
//  Copyright © 2016年 Jia. All rights reserved.
//

#import "OpenShare+Sms.h"
#import "OpenShare+Helper.h"

@implementation OpenShare (Sms)

+ (void)shareToSms:(OSMessage *)msg inController:(UIViewController *)ctrler delegate:(id<MFMessageComposeViewControllerDelegate>)delegate
{
    if (MFMessageComposeViewController.canSendText) {
        MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
        controller.recipients = msg.dataItem.recipients;
        controller.body = msg.dataItem.msgBody;
        controller.messageComposeDelegate = delegate;
        if (nil != msg.dataItem.imageData) {
            NSString *imageType = [OpenShare contentTypeForImageData:msg.dataItem.imageData];
            NSRange range = [imageType rangeOfString:@"image/"];
            if (range.location != NSNotFound) {
                NSString *fileName = [NSString stringWithFormat:@"image.%@", [imageType substringFromIndex:range.location + range.length]];
                [controller addAttachmentData:msg.dataItem.imageData
                               typeIdentifier:@"OSSMSImage"
                                     filename:fileName];
            }
        }

        [ctrler presentViewController:controller animated:YES completion:nil];
    }
}

@end
