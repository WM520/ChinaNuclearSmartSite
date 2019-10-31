//
//  AppJSObject.m
//  ChinaNuclearSmartSite
//
//  Created by miao on 2019/10/24.
//  Copyright © 2019 miao. All rights reserved.
//

#import "AppJSObject.h"

@implementation AppJSObject

-(void)getQrCode:(NSString *)message{
    [self.delegate getQrCode:message];
}

@end
