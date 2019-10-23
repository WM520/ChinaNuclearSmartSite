//
//  NSTimer+WMAddtions.m
//  AVFoundation
//
//  Created by miao on 2019/10/18.
//  Copyright © 2019 miao. All rights reserved.
//

#import "NSTimer+WMAddtions.h"

@implementation NSTimer (WMAddtions)

+ (void)executeTimerBlock:(NSTimer *)timer
{
    TimerFireBlock block = [timer userInfo];
    block();
}

+ (instancetype)scheduledTimerWithTimeInterval:(NSTimeInterval)inTimeInterval firing:(TimerFireBlock)fireBlock
{
    return [self scheduledTimerWithTimeInterval:inTimeInterval firing:fireBlock];
}

+ (instancetype)scheduledTimerWithTimeInterval:(NSTimeInterval)inTimeInterval repeating:(BOOL)repeat firing:(TimerFireBlock)fireBlock
{
    id block = [fireBlock copy];
    return [self scheduledTimerWithTimeInterval:inTimeInterval target:self selector:@selector(executeTimerBlock:) userInfo:block repeats:repeat];
}

@end
