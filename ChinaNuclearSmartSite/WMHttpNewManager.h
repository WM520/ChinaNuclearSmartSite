//
//  WMHttpNewManager.h
//  ChinaNuclearSmartSite
//
//  Created by miao on 2020/9/11.
//  Copyright © 2020 miao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>

NS_ASSUME_NONNULL_BEGIN


typedef void (^requestSuccessBlock)(NSDictionary *dic);
//请求失败回调block
typedef void (^requestFailureBlock)(NSError *error);
// 请求的类型
typedef enum {
    GET,
    POST,
    PUT,
    DELETE,
    HEAD,
    UPLOAD
} HTTPMethod;

@interface WMHttpNewManager : AFHTTPSessionManager


// 网络请求类
+ (WMHttpNewManager *)sharedManager;

- (void)requestWithMethod:(HTTPMethod)method
                 WithPath:(NSString *)path
               WithParams:(id)params
         WithSuccessBlock:(requestSuccessBlock)success
          WithFailurBlock:(requestFailureBlock)failure;


@end




NS_ASSUME_NONNULL_END
