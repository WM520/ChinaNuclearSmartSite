//
//  UserModel.m
//  ChinaNuclearSmartSite
//
//  Created by miao on 2019/10/28.
//  Copyright © 2019 miao. All rights reserved.
//

#import "UserModel.h"

@implementation UserModel

//@property (nonatomic, copy) NSString *token;
//@property (nonatomic, copy) NSString *projectId;
//@property (nonatomic, copy) NSString *phone;
//@property (nonatomic, copy) NSString *userId;
//@property (nonatomic, copy) NSDictionary *data;

//归档协议方法
- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.token forKey:@"token"];
    [aCoder encodeObject:self.projectId forKey:@"projectId"];
    [aCoder encodeObject:self.phone forKey:@"phone"];
    [aCoder encodeObject:self.userId forKey:@"userId"];
    [aCoder encodeObject:self.data forKey:@"data"];
}

//解档协议方法
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.token = [aDecoder decodeObjectForKey:@"token"];
        self.projectId = [aDecoder decodeObjectForKey:@"projectId"];
        self.phone = [aDecoder decodeObjectForKey:@"phone"];
        self.userId = [aDecoder decodeObjectForKey:@"userId"];
        self.data = [aDecoder decodeObjectForKey:@"data"];
    }
    return self;
}


@end
