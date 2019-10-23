//
//  UIAlertView+WMAddtions.m
//  AVFoundation
//
//  Created by miao on 2019/10/18.
//  Copyright © 2019 miao. All rights reserved.
//

#import "UIAlertView+WMAddtions.h"

@implementation UIAlertView (WMAddtions)

+ (void)showAlertWithTitle:(NSString *)title message:(NSString *)message
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:nil cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
    [alertView show];
}

@end
