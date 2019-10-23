//
//  AVAsset+WMAdditons.m
//  AVFoundation
//
//  Created by miao on 2019/10/18.
//  Copyright © 2019 miao. All rights reserved.
//

#import "AVAsset+WMAdditons.h"



@implementation AVAsset (WMAdditons)

- (NSString *)title {

    AVKeyValueStatus status =
        [self statusOfValueForKey:@"commonMetadata" error:nil];
    if (status == AVKeyValueStatusLoaded) {
        NSArray *items =
            [AVMetadataItem metadataItemsFromArray:self.commonMetadata
                                           withKey:AVMetadataCommonKeyTitle
                                          keySpace:AVMetadataKeySpaceCommon];
        if (items.count > 0) {
            AVMetadataItem *titleItem = [items firstObject];
            return (NSString *)titleItem.value;
        }
    }
    
    return nil;
}

@end
