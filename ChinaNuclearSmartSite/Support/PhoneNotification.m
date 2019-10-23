//
//  PhoneNotification.m
//  FSFTownFinancial
//
//  Created by yujiuyin on 14-7-23.
//  Copyright (c) 2014年 yujiuyin. All rights reserved.
//
#import "PhoneNotification.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"

#define HideTime   1.5f
#define AnotherHideTime   12.0f
#define Margin     10.0f
#define YOffset    -50.0f
#define LabelFont  14.0f

@implementation NSString (isEmpty)

-(BOOL) isEmptyOrBlank
{
    if([self length] == 0) { //string is empty or nil
        return YES;
    }
    
    if(![[self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length])
    {
        //string is all whitespace
        return YES;
    }
    
    return NO;
}

@end


@interface PhoneNotification ()

@property (nonatomic, strong) MBProgressHUD * hud;

@end


@implementation PhoneNotification

static PhoneNotification *sharedAppSettings = nil;

+ (PhoneNotification *)sharedInstance
{
    @synchronized(self){
        if(sharedAppSettings == nil){
            sharedAppSettings = [self new];
        }
    }
    return sharedAppSettings;
}


- (void)manuallyHideWithText:(NSString*)text
{
    if (text == nil || [text isEmptyOrBlank]) {
        return;
    }
    
    if (_hud){
        [_hud hide:NO];
        _hud = nil;
    }
    
    _hud = [MBProgressHUD showHUDAddedTo:theApp.window animated:YES];
    
    _hud.mode = MBProgressHUDModeText;
    _hud.labelText = text;
    _hud.margin = Margin;
    _hud.yOffset = YOffset;
    _hud.bezelView.color = [UIColor blackColor];
    _hud.label.font = [UIFont systemFontOfSize:LabelFont];
    _hud.removeFromSuperViewOnHide = YES;
}


- (void)manuallyHideWithIndicator
{
    if (_hud){
        [_hud hideAnimated:YES];
        _hud = nil;
    }
    
    _hud = [MBProgressHUD showHUDAddedTo:theApp.window animated:YES];
    
    _hud.margin = Margin;
    _hud.yOffset = YOffset;
    _hud.removeFromSuperViewOnHide = YES;
    _hud.userInteractionEnabled = NO;
}


- (void)manuallyHideWithText:(NSString*)text indicator:(BOOL)show
{
    if (text == nil || [text isEmptyOrBlank]) {
        return [self manuallyHideWithIndicator];
    }
    
    if (_hud){
        [_hud hideAnimated:YES];
        _hud = nil;
    }
    
    if (!show) {
        return [self manuallyHideWithText:text];
    }
    _hud = [MBProgressHUD showHUDAddedTo:theApp.window animated:YES];
    _hud.label.text = text;
    _hud.label.textColor = [UIColor whiteColor];
    _hud.margin = Margin;
    _hud.yOffset = YOffset;
    _hud.bezelView.color = [UIColor blackColor];
    _hud.label.font = Font(14);
    _hud.removeFromSuperViewOnHide = YES;
    _hud.userInteractionEnabled = NO;
}


- (void)autoHideWithText:(NSString*)text
{
    if (text == nil || [text isEmptyOrBlank]) {
        return;
    }
    
    if (_hud){
        [_hud hide:NO];
        _hud = nil;
    }
    
    _hud = [MBProgressHUD showHUDAddedTo:theApp.window animated:YES];
    
    _hud.mode = MBProgressHUDModeText;
    _hud.labelText = text;
    _hud.margin = Margin;
    _hud.yOffset = YOffset;
//    _hud.color = [UIColor blackColor];
    _hud.alpha = 0.4;
    _hud.labelFont = [UIFont systemFontOfSize:LabelFont];
    _hud.removeFromSuperViewOnHide = YES;
    _hud.userInteractionEnabled = NO;
    
    [_hud hideAnimated:YES afterDelay:HideTime];
}

- (void)hideNotification
{
    if (_hud) {
        [_hud hideAnimated:YES];
    }
}

- (void)autoHideWithText:(NSString *)text image:(NSString *)imageName backGroundColor:(UIColor *)backGroundColor
{
    if (text == nil || [text isEmptyOrBlank]) {
        return;
    }
    
    if (_hud){
        [_hud hideAnimated:NO];
        _hud = nil;
    }
    _hud = [MBProgressHUD showHUDAddedTo:theApp.window animated:YES];
    // Set the custom view mode to show any view.
    _hud.mode = MBProgressHUDModeCustomView;
    _hud.bezelView.backgroundColor = backGroundColor;
    // Set an image view with a checkmark.
    _hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
    // Looks a bit nicer if we make it square.
    _hud.square = YES;
    // Optional label text.
    _hud.label.text = text;
    _hud.label.textColor = [UIColor whiteColor];
    
    [_hud hideAnimated:YES afterDelay:1.f];
}

- (void)autoHideWithText:(NSString *)text image:(NSString *)imageName
{
    if (text == nil || [text isEmptyOrBlank]) {
        return;
    }
    
    if (_hud){
        [_hud hideAnimated:NO];
        _hud = nil;
    }
    _hud = [MBProgressHUD showHUDAddedTo:theApp.window animated:YES];
    // Set the custom view mode to show any view.
    _hud.mode = MBProgressHUDModeCustomView;
    // Set an image view with a checkmark.
    _hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
    // Looks a bit nicer if we make it square.
    _hud.square = YES;
    // Optional label text.
    _hud.label.text = text;
    _hud.label.textColor = [UIColor whiteColor];
    
    [_hud hideAnimated:YES afterDelay:1.f];
}


@end




