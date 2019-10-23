//
//  PhoneNotification.h
//  FSFTownFinancial
//
//  Created by yujiuyin on 14-7-23.
//  Copyright (c) 2014年 yujiuyin. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface NSString (isEmpty)

-(BOOL) isEmptyOrBlank;

@end


@interface PhoneNotification : NSObject

+ (PhoneNotification *)sharedInstance;
/** 带显示字的指示器 */
- (void)manuallyHideWithText:(NSString*)text indicator:(BOOL)show;
- (void)manuallyHideWithIndicator;

/** 自动隐藏 */
- (void)autoHideWithText:(NSString*)text;

//隐藏
- (void)hideNotification;

// customView
- (void)autoHideWithText:(NSString *)text image:(NSString *)imageName backGroundColor:(UIColor *)backGroundColor;
- (void)autoHideWithText:(NSString *)text image:(NSString *)imageName;
@end



