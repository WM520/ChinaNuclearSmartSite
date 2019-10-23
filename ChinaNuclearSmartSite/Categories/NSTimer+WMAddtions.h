//
//  NSTimer+WMAddtions.h
//  AVFoundation
//
//  Created by miao on 2019/10/18.
//  Copyright © 2019 miao. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^TimerFireBlock)(void);

@interface NSTimer (WMAddtions)

+ (instancetype)scheduledTimerWithTimeInterval:(NSTimeInterval)inTimeInterval firing:(TimerFireBlock)fireBlock;
+ (instancetype)scheduledTimerWithTimeInterval:(NSTimeInterval)inTimeInterval repeating:(BOOL)repeat firing:(TimerFireBlock)fireBlock;

@end

NS_ASSUME_NONNULL_END
