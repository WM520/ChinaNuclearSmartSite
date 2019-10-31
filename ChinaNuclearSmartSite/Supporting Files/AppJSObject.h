//
//  AppJSObject.h
//  ChinaNuclearSmartSite
//
//  Created by miao on 2019/10/24.
//  Copyright © 2019 miao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

NS_ASSUME_NONNULL_BEGIN

@protocol AppJSObjectDelegate <JSExport>

-(void)getQrCode:(NSString *)message;

@end

@interface AppJSObject : NSObject <AppJSObjectDelegate>

@property(nonatomic,weak) id<AppJSObjectDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
