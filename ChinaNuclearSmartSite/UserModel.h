//
//  UserModel.h
//  ChinaNuclearSmartSite
//
//  Created by miao on 2019/10/28.
//  Copyright © 2019 miao. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface UserModel : NSObject<NSCoding>

@property (nonatomic, copy) NSString *token;
@property (nonatomic, copy) NSString *projectId;
@property (nonatomic, copy) NSString *phone;
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSDictionary *data;

@end

NS_ASSUME_NONNULL_END
