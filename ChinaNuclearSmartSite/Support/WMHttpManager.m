//
//  WMHttpManager.m
//  PowerBank
//
//  Created by baiju on 2017/8/15.
//  Copyright © 2017年 wangmiao. All rights reserved.
//

#import "WMHttpManager.h"
#import "PhoneNotification.h"
#import "TFFileUploadManager.h"

@implementation WMHttpManager

// 单例实现
+(WMHttpManager *)sharedManager
{
    static WMHttpManager * manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] initWithBaseURL:[NSURL URLWithString:DEVELOPMENT_URL_BASE]];
    });
    return manager;
}
// 重写父类的方法
-(instancetype)initWithBaseURL:(NSURL *)url
{
    self = [super initWithBaseURL:url];
    if (self) {
//        AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
//        self.securityPolicy = securityPolicy;
        // 请求超时设定
        self.responseSerializer = [AFJSONResponseSerializer serializer];
        self.requestSerializer=[AFJSONRequestSerializer serializer];
        self.requestSerializer.timeoutInterval = 10;
        self.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
        [self.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [self.requestSerializer setValue:url.absoluteString forHTTPHeaderField:@"Referer"];
        self.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", @"text/plain", nil];
        self.securityPolicy.allowInvalidCertificates = YES;
    }
    return self;
}

- (void)requestWithMethod:(HTTPMethod)method
                 WithPath:(NSString *)path
               WithParams:(id)params
         WithSuccessBlock:(requestSuccessBlock)success
          WithFailurBlock:(requestFailureBlock)failure
{
    
    switch (method) {
        case GET:{
            [self GET:path parameters:params progress:nil success:^(NSURLSessionTask *task, NSDictionary * responseObject) {
                NSLog(@"%@", path);
                NSLog(@"JSON: %@", responseObject);
                success(responseObject);
            } failure:^(NSURLSessionTask *operation, NSError *error) {
                NSLog(@"Error: %@", error);
                failure(error);
            }];
            break;
        }
        case POST:{
            NSLog(@"%@", params);
            [self POST:path parameters:params progress:nil success:^(NSURLSessionTask *task, NSDictionary * responseObject) {
                NSLog(@"JSON: %@", responseObject);
                success(responseObject);
            } failure:^(NSURLSessionTask *operation, NSError *error) {
                NSLog(@"Error: %@", error);
                failure(error);
            }];
            break;
        }
        case DELETE: {
            self.requestSerializer.HTTPMethodsEncodingParametersInURI = [NSSet setWithObjects:@"GET", @"HEAD", nil];
            [self DELETE:path parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                NSLog(@"JSON: %@", responseObject);
                success(responseObject);
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                NSLog(@"JSON: %@", error);
                failure(error);
            }];
            break;
        }
        case PUT: {
            [self PUT:path parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                NSLog(@"JSON: %@", responseObject);
                success(responseObject);
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                NSLog(@"JSON: %@", error);
                failure(error);
            }];
            break;
        }
        case UPLOAD: {
            UIImage * image = [params objectForKey:@"file"];
            NSData *imageData = UIImageJPEGRepresentation(image, 1);
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = @"yyyyMMddHHmmss";
            NSString *str = [formatter stringFromDate:[NSDate date]];
            NSString *fileName = [NSString stringWithFormat:@"%@.jpg", str];
            NSDictionary * imageDataDic = @{@"file": imageData};
            [self POST:path parameters:imageDataDic constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
                [formData appendPartWithFileData:imageData name:@"file" fileName:fileName mimeType:@"image/jpg"];
            } progress:^(NSProgress * _Nonnull uploadProgress) {
                NSLog(@"%@", uploadProgress);
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                success(responseObject);
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                failure(error);
            }];
            break;
        }
        default:
            break;
    }
}
@end

@implementation HttpURLManager

/*************************************************1、登录**********************************************************************/


/*************************************************2.个人信息*******************************************************************/
// 获取用户信息
+ (NSString *)infomationUrl
{
    return [NSString stringWithFormat:@"%@?token=%@", PERSONAL_INFORMATION_URL, Login_Token];
}
//获取用户信用记录
+ (NSString *)creditUrl
{
    return [NSString stringWithFormat:@"%@?token=%@", PERSONAL_CREDIT_URL, Login_Token];
}
// 身份认证
+ (NSString *)identifyUrl
{
    return [NSString stringWithFormat:@"%@?token=%@", PERSONAL_IDENTIFY_URL, Login_Token];
}
//绑定银行卡
+ (NSString *)addBankCardUrl
{
    return [NSString stringWithFormat:@"%@?token=%@", ADD_BANKCARD_URL, Login_Token];
}
// 删除银行卡
+ (NSString *)deleteBankCardUrl
{
    return [NSString stringWithFormat:@"%@?token=%@", DELETE_BANKCARD_URL,Login_Token];
}
//获取用户充电记录
+ (NSString *)chargerUrl
{
    return [NSString stringWithFormat:@"%@?token=%@", PERSONAL_CHARGER_URL, Login_Token];
}
// 用户提现
+ (NSString *)userCashUrl
{
    return [NSString stringWithFormat:@"%@?token=%@", USER_CASH_URL,Login_Token];
}

// 获取用户交易记录
+ (NSString *) userTransactUrl
{
    return [NSString stringWithFormat:@"%@?token=%@",USER_TRANSACT_URL, Login_Token];
}

+ (NSString *)messageUrl
{
    return [NSString stringWithFormat:@"%@?token=%@", USER_MESSAGE_URL, Login_Token];
}

//修改用户头像
+ (NSString *)modifacationHeadImageUrl
{
    return [NSString stringWithFormat:@"%@?token=%@", MODIFACATION_HEADIMAGE_URL, Login_Token];
}

/***********************************************3.需求*********************************************************************/
//获取用户需求
+ (NSString *)requireUrl
{
    return [NSString stringWithFormat:@"%@?token=%@", REQUIRE_URL, Login_Token];
}
//获取周围需求列表
+ (NSString *)pioUrl
{
    return [NSString stringWithFormat:@"%@?token=%@", PIO_URL, Login_Token];
}
/**********************************************4.共享**********************************************************************/
//用户共享
+ (NSString *) userShareUrl
{
    return [NSString stringWithFormat:@"%@?token=%@", SHARE_URL, Login_Token];
}
//获取周围共享列表
+ (NSString *)pioShareUrl
{
    return [NSString stringWithFormat:@"%@?token=%@", PIO_SHARE_URL, Login_Token];
}

/********************************************5订单*************************************************************************/
//接单
+ (NSString *)receiptUrl
{
    return [NSString stringWithFormat:@"%@?token=%@", RECEIPT_LIST_URL, Login_Token];
}
//获取用户订单需求（取消)
+ (NSString *)acquiringOrderUrl
{
    return [NSString stringWithFormat:@"%@?token=%@", ACQUIRING_ORDER_URL, Login_Token];
}
//获取用户共享订单(取消)
+ (NSString *)arquiringShareUrl
{
    return [NSString stringWithFormat:@"%@?token=%@", SHAER_ORDER_URL, Login_Token];
}
//获取用户订单列表
+ (NSString *)acquiringOrderListUrl
{
    return [NSString stringWithFormat:@"%@?token=%@", ACQUIRING_ORDER_LIST_URL, Login_Token];
}

// 订单确认送达
+ (NSString *)shareSendedUrl
{
    return [NSString stringWithFormat:@"%@?token=%@", ORDER_SENDED_URL, Login_Token];
}

+ (NSString *)acquiringOrderUnsendedListUrl
{
    return [NSString stringWithFormat:@"%@?token=%@", ACQUIRING_ORDER_UNSENDED_URL,Login_Token];
}

+ (NSString *)shareUnsendedUrl
{
    return [NSString stringWithFormat:@"%@?token=%@", ORDER_UNSENDED_URL, Login_Token];
}

/*******************************************6.柜机**************************************************************************/
//获取柜机列表
+ (NSString *)acquiringCabinetListUrl
{
    return [NSString stringWithFormat:@"%@?token=%@", CABINET_LIST_URL, Login_Token];
}

/*******************************************7.设备**************************************************************************/
// 开启充电宝
+ (NSString *)openToPower
{
    return [NSString stringWithFormat:@"%@?token=%@", OPEN_POWER_URL, Login_Token];
}
// 提交设备状态
+ (NSString *)commitPowerStatus
{
    return [NSString stringWithFormat:@"%@?token=%@", CHARGING_STATUS_URL, Login_Token];
}
// 报修
+ (NSString *)warrantyUrl
{
    return [NSString stringWithFormat:@"%@?token=%@",FEEDBACK_REPAIR_URL, Login_Token];
}
/*******************************************8.反馈意见**************************************************************************/
+ (NSString *)uploadFeedBackImageUrl
{
    return [NSString stringWithFormat:@"%@?token=%@", FEEDBARK_UPLOAD_URL, Login_Token];
}
+ (NSString *)uploadFeedBack
{
    return [NSString stringWithFormat:@"%@?token=%@", FEEDBARK_URL, Login_Token];
}
/********************************************9.支付************************************************************************/

+ (NSString *)balancePayUrl
{
    return [NSString stringWithFormat:@"%@?token=%@", BALANCE_PAY_URL, Login_Token];
}

+ (NSString *)weChatPayUrl
{
    return [NSString stringWithFormat:@"%@?token=%@", WECHAT_PAY_URL, Login_Token];
}

+ (NSString *)aliPayUrl
{
    return [NSString stringWithFormat:@"%@?token=%@", ALIPAY_PAY_URL, Login_Token];
}

/*******************************************10. 申诉************************************************************************/
//新增申诉
+ (NSString *)addAppealUrl
{
    return [NSString stringWithFormat:@"%@?token=%@", ADD_APPEAL_URL, Login_Token];
}

+ (NSString *)acquiringAppealListUrl
{
    return [NSString stringWithFormat:@"%@?token=%@", ACQUIRING_APPEAL_LIST_URL, Login_Token];
}

@end


@implementation WMRequestHelper


static PhoneNotification * _phoneNotification = nil;

+ (void)initialize
{
    _phoneNotification = [PhoneNotification sharedInstance];
}

+ (WMRequestHelper *)shareManager
{
    static WMRequestHelper * manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[WMRequestHelper alloc] init];
        
    });
    return manager;
}

#pragma mark - PUSH_TEST
+ (void)pushTest:(NSString *)token
    withCompletionHandle:(void(^)(BOOL success,id dataDic))handleBlock
{
    [_phoneNotification manuallyHideWithText:nil indicator:YES];
    WMHttpManager * manager = [WMHttpManager sharedManager];
    [manager requestWithMethod:GET WithPath:[NSString stringWithFormat:@"%@?token=%@", PUSH_TEST, Login_Token] WithParams:nil WithSuccessBlock:^(NSDictionary *dic) {
        [_phoneNotification hideNotification];
        handleBlock(YES, dic);
    } WithFailurBlock:^(NSError *error) {
        [_phoneNotification hideNotification];
        handleBlock(NO,error);
    }];
}

#pragma mark - 登录接口
+ (void)loginRequestWithPhone:(NSString *)phone
              validateCodeStr:(NSString *)validateCodeStr
                     platform:(NSString *)platform
                     deviceId:(NSString *)deviceId
         withCompletionHandle:(void(^)(BOOL success,id dataDic))handleBlock
{
    [_phoneNotification manuallyHideWithText:@"登录中" indicator:YES];
    WMHttpManager * manager = [WMHttpManager sharedManager];
    [manager requestWithMethod:POST WithPath:UserLogin_URI WithParams:@{@"phone": phone, @"code":validateCodeStr , @"device": @"iOS", @"deviceId": deviceId} WithSuccessBlock:^(NSDictionary *dic) {
        [_phoneNotification hideNotification];
        handleBlock(YES, dic);
    } WithFailurBlock:^(NSError *error) {
        [_phoneNotification hideNotification];
        [_phoneNotification autoHideWithText:@"登录失败"];
        handleBlock(NO,error);
    }];
}

#pragma mark - 获取验证码
+ (void)acquiringMessageCode:(NSString *)phoneNumber
                        type:(NSString *)type
        withCompletionHandle:(void(^)(BOOL success,id dataDic))handleBlock;
{
    [_phoneNotification manuallyHideWithText:nil indicator:YES];
    WMHttpManager * manager = [WMHttpManager sharedManager];
    [manager requestWithMethod:POST WithPath:ACQUIRING_MESSAGE_CODE WithParams:@{@"phone": phoneNumber, @"type": type} WithSuccessBlock:^(NSDictionary *dic) {
        [_phoneNotification hideNotification];
        handleBlock(YES, dic);
    } WithFailurBlock:^(NSError *error) {
        [_phoneNotification hideNotification];
        handleBlock(NO,error);
    }];
}

#pragma mark - 获取aliyun访问token
+ (void)acquiringAliyunToken:(NSString *)token
        withCompletionHandle:(void(^)(BOOL success,id dataDic))handleBlock
{
    WMHttpManager * manager = [WMHttpManager sharedManager];
    [manager requestWithMethod:GET WithPath:[NSString stringWithFormat:@"%@?token=%@", ACQUIRING_ALIYUN_TOKEN_URL, [[AppSettings sharedInstance] stringForKey:@"token"]] WithParams:nil WithSuccessBlock:^(NSDictionary *dic) {
        handleBlock(YES, dic);
    } WithFailurBlock:^(NSError *error) {
        handleBlock(NO, error);
    }];
}

#pragma mark - 获取用户信息
+ (void)acquiringInformation:(NSString *)token
        withCompletionHandle:(void(^)(BOOL success,id dataDic))handleBlock
{
    WMHttpManager * manager = [WMHttpManager sharedManager];
    [manager requestWithMethod:GET WithPath:[HttpURLManager infomationUrl] WithParams:nil WithSuccessBlock:^(NSDictionary *dic) {
        handleBlock(YES, dic);
    } WithFailurBlock:^(NSError *error) {
        handleBlock(NO, error);
    }];
}

#pragma mark - 修改用户信息
+ (void)modificationUserValue:(NSString *) value
                          key:(NSString *) key
        withCompletionHandle:(void(^)(BOOL success,id dataDic))handleBlock;
{
    WMHttpManager * manager = [WMHttpManager sharedManager];
    [manager requestWithMethod:POST WithPath:[HttpURLManager infomationUrl] WithParams:@{@"key": key, @"value" : value} WithSuccessBlock:^(NSDictionary *dic) {
        handleBlock(YES, dic);
    } WithFailurBlock:^(NSError *error) {
        handleBlock(NO, error);
    }];
}

#pragma mark - 获取用户信用记录
+ (void)acquiringCreditList:(int )limit
                       page:(int )page
       withCompletionHandle:(void(^)(BOOL success,id dataDic))handleBlock
{
    [_phoneNotification manuallyHideWithText:nil indicator:YES];
    WMHttpManager * manager = [WMHttpManager sharedManager];
    NSString *xx=[NSString stringWithFormat:@"{\"limit\":%d,\"page\":%d}",limit, page];
    [manager requestWithMethod:GET WithPath:[HttpURLManager creditUrl] WithParams:@{@"param": xx} WithSuccessBlock:^(NSDictionary *dic) {
        [_phoneNotification hideNotification];
        handleBlock(YES, dic);
    } WithFailurBlock:^(NSError *error) {
        [_phoneNotification hideNotification];
        [_phoneNotification autoHideWithText:@"加载失败"];
        handleBlock(NO,error);
    }];
}

#pragma mark - 获取用户消息列表
+ (void)acquiringChargerList:(int)limit
                        page:(int)page
        withCompletionHandle:(void(^)(BOOL success,id dataDic))handleBlock
{
    [_phoneNotification manuallyHideWithText:nil indicator:YES];
    WMHttpManager * manager = [WMHttpManager sharedManager];

    NSString *xx=[NSString stringWithFormat:@"{\"limit\":%d,\"page\":%d}",limit, page];
    [manager requestWithMethod:GET WithPath:[HttpURLManager messageUrl] WithParams:@{@"param": xx} WithSuccessBlock:^(NSDictionary *dic) {
        [_phoneNotification hideNotification];
        handleBlock(YES, dic);
    } WithFailurBlock:^(NSError *error) {
        [_phoneNotification hideNotification];
        [_phoneNotification autoHideWithText:@"加载失败"];
        handleBlock(NO,error);
    }];
}

#pragma mark - 身份认证
+ (void)userIdentifyWithName:(NSString *)name
                      number:(NSString *)number
        withCompletionHandle:(void(^)(BOOL success,id dataDic))handleBlock
{
    [_phoneNotification manuallyHideWithText:nil indicator:YES];
    WMHttpManager * manager = [WMHttpManager sharedManager];
    [manager requestWithMethod:POST WithPath:[HttpURLManager identifyUrl] WithParams:@{@"name": name, @"number": number} WithSuccessBlock:^(NSDictionary *dic) {
        [_phoneNotification hideNotification];
        handleBlock(YES, dic);
    } WithFailurBlock:^(NSError *error) {
        [_phoneNotification hideNotification];
        [_phoneNotification autoHideWithText:@"认证失败"];
        handleBlock(NO,error);
    }];
}

#pragma mark - 绑定银行卡
/**
 * username : 姓名
 * bankname : 银行名称
 * depositname: 开户行
 * number: 卡号
 */
+ (void)addBankCardWithUsername:(NSString *)username
                       bankname:(NSString *)bankname
                    depositname:(NSString *)depositname
                         number:(NSString *)number
           withCompletionHandle:(void(^)(BOOL success,id dataDic))handleBlock
{
    [_phoneNotification manuallyHideWithText:nil indicator:YES];
    WMHttpManager * manager = [WMHttpManager sharedManager];
    [manager requestWithMethod:POST WithPath:[HttpURLManager addBankCardUrl] WithParams:@{@"username": username, @"bankname": bankname, @"depositname": depositname, @"number": number} WithSuccessBlock:^(NSDictionary *dic) {
        [_phoneNotification hideNotification];
        handleBlock(YES, dic);
    } WithFailurBlock:^(NSError *error) {
        [_phoneNotification hideNotification];
        [_phoneNotification autoHideWithText:@"添加失败"];
        handleBlock(NO,error);
    }];
}

#pragma mark - 获取银行卡信息
+ (void)acquiringBankCardInformation:(NSString *)token
                withCompletionHandle:(void (^)(BOOL success, id dataDic))handleBlock
{
    [_phoneNotification manuallyHideWithText:nil indicator:YES];
    WMHttpManager * manager = [WMHttpManager sharedManager];
    [manager requestWithMethod:GET WithPath:[HttpURLManager addBankCardUrl] WithParams:nil WithSuccessBlock:^(NSDictionary *dic) {
        [_phoneNotification hideNotification];
        handleBlock(YES, dic);
    } WithFailurBlock:^(NSError *error) {
        [_phoneNotification hideNotification];
        [_phoneNotification autoHideWithText:@"加载失败"];
        handleBlock(NO,error);
    }];
}

#pragma mark - 用户删除银行卡
+ (void)deleteBankCardWithCardNumber:(NSString *)cardNumber
                withCompletionHandle:(void (^)(BOOL success, id dataDic))handleBlock
{
    [_phoneNotification manuallyHideWithText:nil indicator:YES];
    WMHttpManager * manager = [WMHttpManager sharedManager];
    [manager requestWithMethod:DELETE WithPath: [NSString stringWithFormat:@"%@/%@?token=%@", DELETE_BANKCARD_URL, cardNumber, [[AppSettings sharedInstance] stringForKey:@"token"]] WithParams:nil WithSuccessBlock:^(NSDictionary *dic) {
        [_phoneNotification hideNotification];
        handleBlock(YES, dic);
    } WithFailurBlock:^(NSError *error) {
        [_phoneNotification hideNotification];
        [_phoneNotification autoHideWithText:@"取消失败"];
        handleBlock(NO,error);
    }];

}

#pragma mark - 修改用户头像接口
+ (void)modifacationUserHeadImage:(UIImage *)headImage
             withCompletionHandle:(void(^)(BOOL success,id dataDic))handleBlock
{
    [_phoneNotification manuallyHideWithText:nil indicator:YES];
    WMHttpManager * manager = [WMHttpManager sharedManager];
    [manager requestWithMethod:UPLOAD WithPath:[HttpURLManager modifacationHeadImageUrl] WithParams:@{@"file":headImage} WithSuccessBlock:^(NSDictionary *dic) {
        [_phoneNotification hideNotification];
        handleBlock(YES, dic);
    } WithFailurBlock:^(NSError *error) {
        [_phoneNotification hideNotification];
        [_phoneNotification autoHideWithText:@"修改失败"];
        handleBlock(NO,error);
    }];
    
    
//    [manager requestWithMethod:GET WithPath:REQUIRE_URL WithParams:@{@"file": token} WithSuccessBlock:^(NSDictionary *dic) {
//        [_phoneNotification hideNotification];
//        handleBlock(YES, dic);
//    } WithFailurBlock:^(NSError *error) {
//        [_phoneNotification hideNotification];
//        [_phoneNotification autoHideWithText:@"加载失败"];
//        handleBlock(NO,error);
//    }];

}

#pragma mark - 用户提现
+ (void)userCashWithMoney: (NSString *)money
                     bcid: (NSString *)bcid
     withCompletionHandle:(void(^)(BOOL success,id dataDic))handleBlock
{
    [_phoneNotification manuallyHideWithText:nil indicator:YES];
    WMHttpManager * manager = [WMHttpManager sharedManager];
    [manager requestWithMethod:POST WithPath:[HttpURLManager userCashUrl] WithParams:@{@"money":money, @"bcid": bcid} WithSuccessBlock:^(NSDictionary *dic) {
        [_phoneNotification hideNotification];
        handleBlock(YES, dic);
    } WithFailurBlock:^(NSError *error) {
        [_phoneNotification hideNotification];
        [_phoneNotification autoHideWithText:@"提现失败"];
        handleBlock(NO,error);
    }];
}

#pragma mark - 用户交易记录
+ (void)userTransactListWithList: (NSString *)limit
                            page: (NSString *)page
            withCompletionHandle:(void(^)(BOOL success,id dataDic))handleBlock
{
    [_phoneNotification manuallyHideWithText:nil indicator:YES];
    WMHttpManager * manager = [WMHttpManager sharedManager];
    NSString *xx=[NSString stringWithFormat:@"{\"limit\":%@,\"page\":%@}",limit, page];
    [manager requestWithMethod:GET WithPath:[HttpURLManager userTransactUrl] WithParams:@{@"param": xx} WithSuccessBlock:^(NSDictionary *dic) {
        [_phoneNotification hideNotification];
        handleBlock(YES, dic);
    } WithFailurBlock:^(NSError *error) {
        [_phoneNotification hideNotification];
        [_phoneNotification autoHideWithText:@"获取列表失败"];
        handleBlock(NO,error);
    }];
}

#pragma mark - 消息列表
+ (void)userMessageListWithList: (NSString *)limit
                           page: (NSString *)page
           withCompletionHandle:(void(^)(BOOL success,id dataDic))handleBlock
{
    [_phoneNotification manuallyHideWithText:nil indicator:YES];
    WMHttpManager * manager = [WMHttpManager sharedManager];
    NSString *xx=[NSString stringWithFormat:@"{\"limit\":%@,\"page\":%@}",limit, page];
    [manager requestWithMethod:GET WithPath:[HttpURLManager userTransactUrl] WithParams:@{@"param": xx} WithSuccessBlock:^(NSDictionary *dic) {
        [_phoneNotification hideNotification];
        handleBlock(YES, dic);
    } WithFailurBlock:^(NSError *error) {
        [_phoneNotification hideNotification];
        [_phoneNotification autoHideWithText:@"获取列表失败"];
        handleBlock(NO,error);
    }];

}

#pragma mark - 获取用户需求
+ (void)acquiringRequire:(NSString *)token
    withCompletionHandle:(void(^)(BOOL success,id dataDic))handleBlock
{
    [_phoneNotification manuallyHideWithText:nil indicator:YES];
    WMHttpManager * manager = [WMHttpManager sharedManager];
    [manager requestWithMethod:GET WithPath:REQUIRE_URL WithParams:@{@"token": token} WithSuccessBlock:^(NSDictionary *dic) {
        [_phoneNotification hideNotification];
        handleBlock(YES, dic);
    } WithFailurBlock:^(NSError *error) {
        [_phoneNotification hideNotification];
        [_phoneNotification autoHideWithText:@"加载失败"];
        handleBlock(NO,error);
    }];
}

#pragma mark -新增用户需求
+ (void)addUserRequire:(NSString *)token
             longitude:(NSString *)longitude
              latitude:(NSString *)latitude
                  addr:(NSString *)addr
               address:(NSString *)address
                 money:(NSString *)money
                  date:(NSString *)date
    withCompletionHandle:(void(^)(BOOL success,id dataDic))handleBlock
{
    [_phoneNotification manuallyHideWithText:nil indicator:YES];
    WMHttpManager * manager = [WMHttpManager sharedManager];
    [manager requestWithMethod:POST WithPath:[HttpURLManager requireUrl] WithParams:@{
                                                                     @"longitude": longitude,
                                                                     @"latitude" : latitude,
                                                                     @"addr" : addr,
                                                                     @"address" : address,
                                                                     @"money" : money,
                                                                     @"date" : date} WithSuccessBlock:^(NSDictionary *dic) {
        [_phoneNotification hideNotification];
        handleBlock(YES, dic);
    } WithFailurBlock:^(NSError *error) {
        [_phoneNotification hideNotification];
        [_phoneNotification autoHideWithText:@"添加失败"];
        handleBlock(NO,error);
    }];
}

#pragma mark - 取消用户需求
// 接口有问题
+ (void)deleteOrder:(NSString *)orderID
withCompletionHandle:(void(^)(BOOL success,id dataDic))handleBlock
{
    [_phoneNotification manuallyHideWithText:nil indicator:YES];
    WMHttpManager * manager = [WMHttpManager sharedManager];
    [manager requestWithMethod:DELETE WithPath:[HttpURLManager requireUrl] WithParams:@{@"id": orderID} WithSuccessBlock:^(NSDictionary *dic) {
        [_phoneNotification hideNotification];
        handleBlock(YES, dic);
    } WithFailurBlock:^(NSError *error) {
        [_phoneNotification hideNotification];
        [_phoneNotification autoHideWithText:@"取消失败"];
        handleBlock(NO,error);
    }];
}

#pragma mark - 修改用户需求（加价）
+ (void)addPrice:(NSString *)orderID
       longitude:(NSString *)longitude
        latitude:(NSString *)latitude
            addr:(NSString *)addr
         address:(NSString *)address
           money:(NSString *)money
            date:(NSString *)date
withCompletionHandle:(void(^)(BOOL success,id dataDic))handleBlock
{
    [_phoneNotification manuallyHideWithText:nil indicator:YES];
    WMHttpManager * manager = [WMHttpManager sharedManager];
    [manager requestWithMethod:PUT WithPath:[HttpURLManager requireUrl] WithParams:@{@"longitude": longitude,
                                                                                     @"latitude" : latitude,
                                                                                     @"addr" : addr,
                                                                                     @"address" : address,
                                                                                     @"money" : money,
                                                                                     @"date" : date,
                                                                                     @"id": orderID}
              WithSuccessBlock:^(NSDictionary *dic) {
                  [_phoneNotification hideNotification];
                  handleBlock(YES, dic);
              } WithFailurBlock:^(NSError *error) {
                  [_phoneNotification autoHideWithText:@"修改失败"];
                  handleBlock(NO,error);
    }];
}

#pragma mark - 获取周围需求列表
+ (void)getPIOList:(NSString *) radius
         longitude:(NSString *)longitude
          latitude:(NSString *)latitude
            filter:(NSString *)filter
              sort:(NSString *)sort
             limit:(NSString *)limit
              page:(NSString *)page
withCompletionHandle:(void(^)(BOOL success,id dataDic))handleBlock
{
    [_phoneNotification manuallyHideWithText:nil indicator:YES];
    WMHttpManager * manager = [WMHttpManager sharedManager];
    NSString *xx=[NSString stringWithFormat:@"{\"longitude\":\"%@\",\"radius\":\"%@\", \"latitude\":\"%@\", \"filter\":\"%@\", \"sort\":\"%@\", \"limit\":\"%@\", \"page\":\"%@\"}",longitude, radius, latitude, filter, sort, limit, page];
    
    [manager requestWithMethod:GET WithPath:[HttpURLManager pioUrl] WithParams:@{@"param":xx,}
              WithSuccessBlock:^(NSDictionary *dic) {
                  [_phoneNotification hideNotification];
                  handleBlock(YES, dic);
              } WithFailurBlock:^(NSError *error) {
                  [_phoneNotification autoHideWithText:@"获取失败"];
                  handleBlock(NO,error);
    }];
}


#pragma mark - 获取用户共享信息接口
+ (void)getUserShareWithCompletionHandle:(void(^)(BOOL success,id dataDic))handleBlock
{
    [_phoneNotification manuallyHideWithText:nil indicator:YES];
    WMHttpManager * manager = [WMHttpManager sharedManager];
    [manager requestWithMethod:GET WithPath:[HttpURLManager userShareUrl] WithParams:nil WithSuccessBlock:^(NSDictionary *dic) {
        [_phoneNotification hideNotification];
        handleBlock(YES, dic);
    } WithFailurBlock:^(NSError *error) {
         [_phoneNotification autoHideWithText:@"获取失败"];
        handleBlock(NO, error);
    }];
}

#pragma mark - 添加用户共享信息接口
+ (void)addUserShare:(NSString *)longitude
            latitude:(NSString *)latitude
                addr:(NSString *)addr
             address:(NSString *)address
            quantity:(NSString *)quantity
              device:(NSString *)device // 充电宝设备UUID
WithCompletionHandle:(void(^)(BOOL success,id dataDic))handleBlock
{
    [_phoneNotification manuallyHideWithText:nil indicator:YES];
    WMHttpManager * manager = [WMHttpManager sharedManager];
    NSDictionary * pramas = @{@"longitude":longitude == nil ? @"" : longitude,
                              @"latitude":latitude == nil ? @"" : latitude,
                              @"addr":addr == nil ? @"" : addr,
                              @"address": address == nil ? @"" : address,
                              @"quantity":quantity == nil ? @"" : quantity ,
                              @"device": device == nil ? @"" : device};
    
    [manager requestWithMethod:POST WithPath:[HttpURLManager userShareUrl] WithParams:pramas WithSuccessBlock:^(NSDictionary *dic) {
        [_phoneNotification hideNotification];
        handleBlock(YES, dic);
    } WithFailurBlock:^(NSError *error) {
        [_phoneNotification autoHideWithText:@"获取失败"];
        handleBlock(NO, error);
    }];

}


#pragma mark - 取消用户共享接口
+ (void)getUserShare:(NSString *)shareID
WithCompletionHandle:(void(^)(BOOL success,id dataDic))handleBlock
{
    [_phoneNotification manuallyHideWithText:nil indicator:YES];
    WMHttpManager * manager = [WMHttpManager sharedManager];
    [manager requestWithMethod:DELETE WithPath:[HttpURLManager userShareUrl] WithParams:@{@"id": shareID} WithSuccessBlock:^(NSDictionary *dic) {
        [_phoneNotification hideNotification];
        handleBlock(YES, dic);
    } WithFailurBlock:^(NSError *error) {
        [_phoneNotification autoHideWithText:@"取消失败"];
        handleBlock(NO, error);
    }];
}


#pragma mark - 获取周围共享列表接口
+ (void)getSharePIOList:(NSString *) radius
              longitude:(NSString *)longitude
               latitude:(NSString *)latitude
                 filter:(NSString *)filter
                   sort:(NSString *)sort
                  limit:(NSString *)limit
                   page:(NSString *)page
   withCompletionHandle:(void(^)(BOOL success,id dataDic))handleBlock
{
    [_phoneNotification manuallyHideWithText:nil indicator:YES];
    WMHttpManager * manager = [WMHttpManager sharedManager];
      NSString *xx=[NSString stringWithFormat:@"{\"longitude\":\"%@\",\"radius\":\"%@\", \"latitude\":\"%@\", \"filter\":\"%@\", \"sort\":\"%@\", \"limit\":\"%@\", \"page\":\"%@\"}",longitude, radius, latitude, filter, sort, limit, page];
    [manager requestWithMethod:GET WithPath:[HttpURLManager pioShareUrl] WithParams:@{@"param":xx}
              WithSuccessBlock:^(NSDictionary *dic) {
                  [_phoneNotification hideNotification];
                  handleBlock(YES, dic);
            } WithFailurBlock:^(NSError *error) {
                [_phoneNotification autoHideWithText:@"获取失败"];
                handleBlock(NO,error);
    }];
}

#pragma mark - 接单接口
+ (void)receiptList:(NSString *) urid
               usid:(NSString *)usid
              uruid:(NSString *)uruid
              usuid:(NSString *)usuid
             device:(NSString *)device
           quantity:(NSString *)quantity
              money:(NSString *)money
withCompletionHandle:(void(^)(BOOL success,id dataDic))handleBlock
{
    [_phoneNotification manuallyHideWithText:nil indicator:YES];
    WMHttpManager * manager = [WMHttpManager sharedManager];
    NSDictionary * pramas = @{@"urid":urid,
                              @"usid":usid,
                              @"uruid":uruid,
                              @"usuid": usuid,
                              @"quantity": quantity,
                              @"money":money,
                              @"device": device};
    
    [manager requestWithMethod:POST WithPath:[HttpURLManager receiptUrl] WithParams:pramas WithSuccessBlock:^(NSDictionary *dic) {
        [_phoneNotification hideNotification];
        handleBlock(YES, dic);
    } WithFailurBlock:^(NSError *error) {
        [_phoneNotification autoHideWithText:@"获取失败"];
        handleBlock(NO, error);
    }];
}

#pragma mark - 获取用户订单接口
+ (void)getUserShareOrderWithCompletionHandle:(void(^)(BOOL success,id dataDic))handleBlock
{
    [_phoneNotification manuallyHideWithText:nil indicator:YES];
    WMHttpManager * manager = [WMHttpManager sharedManager];
    [manager requestWithMethod:GET WithPath:[HttpURLManager arquiringShareUrl] WithParams:nil WithSuccessBlock:^(NSDictionary *dic) {
        [_phoneNotification hideNotification];
        handleBlock(YES, dic);
    } WithFailurBlock:^(NSError *error) {
        [_phoneNotification autoHideWithText:@"获取失败"];
        handleBlock(NO, error);
    }];
}
#pragma mark - 取消用户共享订单接口
+ (void)deleteUserShareOrder:(NSString *)orderID withCompletionHandle:(void (^)(BOOL success, id dataDic))handleBlock
{
    [_phoneNotification manuallyHideWithText:nil indicator:YES];
    WMHttpManager * manager = [WMHttpManager sharedManager];
    [manager requestWithMethod:DELETE WithPath:[HttpURLManager arquiringShareUrl] WithParams:@{@"id" : orderID} WithSuccessBlock:^(NSDictionary *dic) {
        [_phoneNotification hideNotification];
        handleBlock(YES, dic);
    } WithFailurBlock:^(NSError *error) {
        [_phoneNotification autoHideWithText:@"获取失败"];
        handleBlock(NO, error);
    }];
}
#pragma mark - 获取用户需求订单接口
+ (void)getUserRequireOrderWithCompletionHandle:(void(^)(BOOL success,id dataDic))handleBlock
{
    [_phoneNotification manuallyHideWithText:nil indicator:YES];
    WMHttpManager * manager = [WMHttpManager sharedManager];
    [manager requestWithMethod:GET WithPath:[HttpURLManager acquiringOrderUrl] WithParams:nil WithSuccessBlock:^(NSDictionary *dic) {
        [_phoneNotification hideNotification];
        handleBlock(YES, dic);
    } WithFailurBlock:^(NSError *error) {
        [_phoneNotification autoHideWithText:@"获取失败"];
        handleBlock(NO, error);
    }];
}

#pragma mark - 取消用户需求订单接口
+ (void)deleteUserRequireOrder:(NSString *)orderID withCompletionHandle:(void (^)(BOOL success, id dataDic))handleBlock
{
    [_phoneNotification manuallyHideWithText:nil indicator:YES];
    WMHttpManager * manager = [WMHttpManager sharedManager];
    [manager requestWithMethod:DELETE WithPath:[HttpURLManager acquiringOrderUrl] WithParams:@{@"id": orderID} WithSuccessBlock:^(NSDictionary *dic) {
        [_phoneNotification hideNotification];
        handleBlock(YES, dic);
    } WithFailurBlock:^(NSError *error) {
        [_phoneNotification autoHideWithText:@"获取失败"];
        handleBlock(NO, error);
    }];
}

#pragma mark - 获取用户订单列表接口
+ (void)acquiringUserOrderListWithLimit:(int)limit
                                   page:(int)page
                   withCompletionHandle:(void(^)(BOOL success,id dataDic))handleBlock
{
    [_phoneNotification manuallyHideWithText:nil indicator:YES];
    WMHttpManager * manager = [WMHttpManager sharedManager];
    
    NSString *xx=[NSString stringWithFormat:@"{\"limit\":%d,\"page\":%d}",limit, page];
    [manager requestWithMethod:GET WithPath:[HttpURLManager acquiringOrderListUrl] WithParams:@{@"param": xx} WithSuccessBlock:^(NSDictionary *dic) {
        [_phoneNotification hideNotification];
        handleBlock(YES, dic);
    } WithFailurBlock:^(NSError *error) {
        [_phoneNotification hideNotification];
        [_phoneNotification autoHideWithText:@"加载失败"];
        handleBlock(NO,error);
    }];
}

#pragma mark - 订单送达接口
+ (void)shareOrderSendWithOrderID:(NSString *)orderID
             WithCompletionHandle:(void(^)(BOOL success,id dataDic))handleBlock;
{
    [_phoneNotification manuallyHideWithText:nil indicator:YES];
    WMHttpManager * manager = [WMHttpManager sharedManager];
    
    NSLog(@"%@", [NSString stringWithFormat:@"%@/%@", [HttpURLManager shareSendedUrl], orderID]);
    
    [manager requestWithMethod:POST WithPath:[NSString stringWithFormat:@"%@/%@", [HttpURLManager shareSendedUrl], orderID] WithParams:nil WithSuccessBlock:^(NSDictionary *dic) {
        [_phoneNotification hideNotification];
        handleBlock(YES, dic);
    } WithFailurBlock:^(NSError *error) {
        [_phoneNotification hideNotification];
        [_phoneNotification autoHideWithText:@"网络请求失败"];
        handleBlock(NO,error);
    }];
}

#pragma mark - 更新共享用户位置
+ (void)updataShareUserLocationWithOrderID:(NSString *)orderId
                                 longitude:(NSString *)longitude
                                  latitude:(NSString *)latitude
                                   address:(NSString *)address
                      withCompletionHandle:(void(^)(BOOL success,id dataDic))handleBlock
{
    [_phoneNotification manuallyHideWithText:nil indicator:YES];
    WMHttpManager * manager = [WMHttpManager sharedManager];
    NSDictionary * pramas = @{@"longitude":longitude,
                              @"latitude":latitude,
                              @"address":address};
    NSString * path = [NSString stringWithFormat:@"%@/%@?token=%@", UPDATA_SHAREURE_LOCATION_URL, orderId, Login_Token];
    [manager requestWithMethod:POST WithPath:path WithParams:pramas WithSuccessBlock:^(NSDictionary *dic) {
        [_phoneNotification hideNotification];
        handleBlock(YES, dic);
    } WithFailurBlock:^(NSError *error) {
        [_phoneNotification autoHideWithText:@"获取失败"];
        handleBlock(NO, error);
    }];

}

#pragma mark - 获取共享用户位置
+ (void)acquiringShareUserLocationWithOrderID:(NSString *)orderId
                         withCompletionHandle:(void(^)(BOOL success,id dataDic))handleBlock
{
    [_phoneNotification manuallyHideWithText:nil indicator:YES];
    WMHttpManager * manager = [WMHttpManager sharedManager];
    NSString * path = [NSString stringWithFormat:@"%@/%@?token=%@", UPDATA_SHAREURE_LOCATION_URL, orderId, Login_Token];
    [manager requestWithMethod:GET WithPath:path WithParams:nil WithSuccessBlock:^(NSDictionary *dic) {
        [_phoneNotification hideNotification];
        handleBlock(YES, dic);
    } WithFailurBlock:^(NSError *error) {
        [_phoneNotification autoHideWithText:@"获取失败"];
        handleBlock(NO, error);
    }];
}

#pragma mark - /** 获取用户未送达信息 */
+ (void)acquiringUserUnsendedOrderWithLimit:(NSString *)limit
                                       page:(NSString *)page
                       withCompletionHandle:(void(^)(BOOL success,id dataDic))handleBlock
{
    [_phoneNotification manuallyHideWithText:nil indicator:YES];
    WMHttpManager * manager = [WMHttpManager sharedManager];
    
    NSString *xx=[NSString stringWithFormat:@"{\"limit\":%@,\"page\":%@}",limit, page];
    [manager requestWithMethod:GET WithPath:[HttpURLManager acquiringOrderUnsendedListUrl] WithParams:@{@"param": xx} WithSuccessBlock:^(NSDictionary *dic) {
        [_phoneNotification hideNotification];
        handleBlock(YES, dic);
    } WithFailurBlock:^(NSError *error) {
        [_phoneNotification hideNotification];
        [_phoneNotification autoHideWithText:@"加载失败"];
        handleBlock(NO,error);
    }];
}

#pragma mark - 订单未送达接口
+ (void)shareOrderUnsendWithCompletionHandle:(void(^)(BOOL success,id dataDic))handleBlock
{
    [_phoneNotification manuallyHideWithText:nil indicator:YES];
    WMHttpManager * manager = [WMHttpManager sharedManager];
    [manager requestWithMethod:POST WithPath:[HttpURLManager shareUnsendedUrl] WithParams:nil WithSuccessBlock:^(NSDictionary *dic) {
        [_phoneNotification hideNotification];
        handleBlock(YES, dic);
    } WithFailurBlock:^(NSError *error) {
        [_phoneNotification hideNotification];
        [_phoneNotification autoHideWithText:@"网络请求失败"];
        handleBlock(NO,error);
    }];
}

#pragma mark - 获取周围柜机列表
+ (void)getCabinetList:(NSString *) radius
             longitude:(NSString *)longitude
              latitude:(NSString *)latitude
                filter:(NSString *)filter
                  sort:(NSString *)sort
                 limit:(NSString *)limit
                  page:(NSString *)page
  withCompletionHandle:(void(^)(BOOL success,id dataDic))handleBlock
{
    [_phoneNotification manuallyHideWithText:nil indicator:YES];
    WMHttpManager * manager = [WMHttpManager sharedManager];
    NSString *xx=[NSString stringWithFormat:@"{\"longitude\":\"%@\",\"radius\":\"%@\", \"latitude\":\"%@\", \"filter\":\"%@\", \"sort\":\"%@\", \"limit\":\"%@\", \"page\":\"%@\"}",longitude, radius, latitude, filter, sort, limit, page];
    [manager requestWithMethod:GET WithPath:[HttpURLManager acquiringCabinetListUrl] WithParams:@{@"param":xx}
              WithSuccessBlock:^(NSDictionary *dic) {
                  [_phoneNotification hideNotification];
                  handleBlock(YES, dic);
              } WithFailurBlock:^(NSError *error) {
                  [_phoneNotification autoHideWithText:@"获取失败"];
                  handleBlock(NO,error);
    }];
}


#pragma mark - 打开设备充电
+ (void)openToPowerWithUuid:(NSString *)uuid
                  longitude:(NSString *)longitude
                   latitude:(NSString *)latitude
                    address:(NSString *)address
       withCompletionHandle:(void(^)(BOOL success,id dataDic))handleBlock
{
    [_phoneNotification manuallyHideWithText:nil indicator:YES];
    WMHttpManager * manager = [WMHttpManager sharedManager];
    NSDictionary * pramas = @{@"uuid":uuid,
                              @"longitude": longitude,
                              @"latitude": latitude,
                              @"address":address};
    [manager requestWithMethod:POST WithPath:[HttpURLManager openToPower] WithParams:pramas WithSuccessBlock:^(NSDictionary *dic) {
        handleBlock(YES, dic);
    } WithFailurBlock:^(NSError *error) {
        [_phoneNotification autoHideWithText:@"网络异常"];
        handleBlock(NO, error);
    }];
}
#pragma mark - 提交设备状态
+ (void)commitPowerStatusWithUuid:(NSString *)uuid
                      temperature:(NSString *)temperature
                         quantity:(NSString *)quantity
                        longitude:(NSString *)longitude
                         latitude:(NSString *)latitude
                          charger:(NSString *)charger
                             info:(NSString *)info
             withCompletionHandle:(void(^)(BOOL success,id dataDic))handleBlock
{
    [_phoneNotification manuallyHideWithText:nil indicator:YES];
    WMHttpManager * manager = [WMHttpManager sharedManager];
    NSDictionary * pramas = @{@"uuid":uuid,
                              @"temperature":temperature,
                              @"quantity":quantity,
                              @"longitude": longitude,
                              @"latitude": latitude,
                              @"charger":charger,
                              @"info": info};
    [manager requestWithMethod:POST WithPath:[HttpURLManager commitPowerStatus] WithParams:pramas WithSuccessBlock:^(NSDictionary *dic) {
        handleBlock(YES, dic);
    } WithFailurBlock:^(NSError *error) {
        [_phoneNotification autoHideWithText:@"网络异常"];
        handleBlock(NO, error);
    }];
}

#pragma mark - 报修
+ (void)warrantyWithUuid:(NSString *)uuid
                question:(NSString *)question
                 provice:(NSString *)provice
                    city:(NSString *)city
                    town:(NSString *)town
                 address:(NSString *)address
                    date:(NSString *)date
                dateType:(NSString *)dateType
    withCompletionHandle:(void(^)(BOOL success,id dataDic))handleBlock;
{
    [_phoneNotification manuallyHideWithText:nil indicator:YES];
    WMHttpManager * manager = [WMHttpManager sharedManager];
    NSDictionary * pramas = @{@"uuid":uuid,
                              @"question":question,
                              @"provice":provice,
                              @"city": city,
                              @"town": town,
                              @"address":address,
                              @"date": date,
                              @"dateType":dateType};
    
    [manager requestWithMethod:POST WithPath:[HttpURLManager warrantyUrl] WithParams:pramas WithSuccessBlock:^(NSDictionary *dic) {
        handleBlock(YES, dic);
    } WithFailurBlock:^(NSError *error) {
        [_phoneNotification autoHideWithText:@"网络异常"];
        handleBlock(NO, error);
    }];
}

#pragma mark - 上传反馈建议图片
+ (void)uploadFeedBackImage:(UIImage *)feedBackImage
       withCompletionHandle:(void(^)(BOOL success,id dataDic))handleBlock
{
    [_phoneNotification manuallyHideWithText:nil indicator:YES];
    WMHttpManager * manager = [WMHttpManager sharedManager];
    [manager requestWithMethod:UPLOAD WithPath:[HttpURLManager uploadFeedBackImageUrl] WithParams:@{@"file":feedBackImage} WithSuccessBlock:^(NSDictionary *dic) {
        [_phoneNotification hideNotification];
        handleBlock(YES, dic);
    } WithFailurBlock:^(NSError *error) {
        [_phoneNotification hideNotification];
        [_phoneNotification autoHideWithText:@"修改失败"];
        handleBlock(NO,error);
    }];
}

#pragma mark - 提交反馈意见和图片
+ (void)uploadContent:(NSString *)content
               images:(NSArray *)images
 withCompletionHandle:(void(^)(BOOL success,id dataDic))handleBlock
{
    [_phoneNotification manuallyHideWithText:nil indicator:YES];
    WMHttpManager * manager = [WMHttpManager sharedManager];
    NSDictionary * pramas = @{@"content":content,
                              @"images":images};
    
    [manager requestWithMethod:POST WithPath:[HttpURLManager uploadFeedBack] WithParams:pramas WithSuccessBlock:^(NSDictionary *dic) {
        [_phoneNotification autoHideWithText:@"反馈成功"];
        [_phoneNotification hideNotification];
        handleBlock(YES, dic);
    } WithFailurBlock:^(NSError *error) {
        [_phoneNotification autoHideWithText:@"网络异常"];
        handleBlock(NO, error);
    }];
}

#pragma mark - 余额支付
+ (void)payBalanceWithOrderId:(NSString *)orderId
                          fee:(NSInteger)fee
                        money:(NSString *)money
         withCompletionHandle:(void(^)(BOOL success,id dataDic))handleBlock
{
    [_phoneNotification manuallyHideWithText:nil indicator:YES];
    WMHttpManager * manager = [WMHttpManager sharedManager];
    NSDictionary * pramas = @{@"body":@"OOL-支付",
                              @"orderId":orderId,
                              @"fee": [NSString stringWithFormat:@"%ld", fee],
                              @"money": money};
    
    [manager requestWithMethod:POST WithPath:[HttpURLManager balancePayUrl] WithParams:pramas WithSuccessBlock:^(NSDictionary *dic) {
        [_phoneNotification autoHideWithText:@"支付请求成功"];
        handleBlock(YES, dic);
    } WithFailurBlock:^(NSError *error) {
        [_phoneNotification autoHideWithText:@"网络异常"];
        handleBlock(NO, error);
    }];

}

#pragma mark - 微信支付
+ (void)payWechatWithBody:(NSString *)body
                   detail:(NSString *)detail
                  orderId:(NSString *)orderId
                      fee:(NSInteger)fee
                    money:(NSString *)money
     withCompletionHandle:(void(^)(BOOL success,id dataDic))handleBlock
{
    [_phoneNotification manuallyHideWithText:nil indicator:YES];
    WMHttpManager * manager = [WMHttpManager sharedManager];
    NSDictionary * pramas = @{@"body":@"OOL-IOS支付",
                              @"detail":@"支付充电需求的红包",
                              @"orderId":orderId,
                              @"fee": [NSString stringWithFormat:@"%ld", fee * 100],
                              @"money": money};
    
    [manager requestWithMethod:POST WithPath:[HttpURLManager weChatPayUrl] WithParams:pramas WithSuccessBlock:^(NSDictionary *dic) {
        [_phoneNotification autoHideWithText:@"支付请求成功"];
        handleBlock(YES, dic);
    } WithFailurBlock:^(NSError *error) {
        [_phoneNotification autoHideWithText:@"网络异常"];
        handleBlock(NO, error);
    }];
}

#pragma mark - 支付宝支付
+ (void)payAliPayWithTitle:(NSString *)title
                   orderId:(NSString *)orderId
                       fee:(NSInteger)fee
                     money:(NSString *)money
      withCompletionHandle:(void(^)(BOOL success,id dataDic))handleBlock
{
    [_phoneNotification manuallyHideWithText:nil indicator:YES];
    WMHttpManager * manager = [WMHttpManager sharedManager];
    NSDictionary * pramas = @{@"title":@"OOL-IOS支付",
                              @"orderId":orderId,
                              @"fee": [NSString stringWithFormat:@"%ld", fee],
                              @"money": money};
    
    [manager requestWithMethod:POST WithPath:[HttpURLManager aliPayUrl] WithParams:pramas WithSuccessBlock:^(NSDictionary *dic) {
        [_phoneNotification autoHideWithText:@"支付请求成功"];
        handleBlock(YES, dic);
    } WithFailurBlock:^(NSError *error) {
        [_phoneNotification autoHideWithText:@"网络异常"];
        handleBlock(NO, error);
    }];
}

#pragma mark - 新增申诉
+ (void)addAppealWithOrderId:(NSString *)orderId
                     content:(NSString *)content
        withCompletionHandle:(void(^)(BOOL success,id dataDic))handleBlock
{
    [_phoneNotification manuallyHideWithText:nil indicator:YES];
    WMHttpManager * manager = [WMHttpManager sharedManager];
    NSDictionary * pramas = @{@"orderId":orderId,
                              @"content":content};
    
    [manager requestWithMethod:POST WithPath:[HttpURLManager addAppealUrl] WithParams:pramas WithSuccessBlock:^(NSDictionary *dic) {
        [_phoneNotification autoHideWithText:@"申诉成功"];
        [_phoneNotification hideNotification];
        handleBlock(YES, dic);
    } WithFailurBlock:^(NSError *error) {
        [_phoneNotification autoHideWithText:@"申诉失败"];
        handleBlock(NO, error);
    }];
}

#pragma mark - 获取用户申诉列表接口
+ (void)acquiringAppealList:(int)limit
                       page:(int)page
       withCompletionHandle:(void(^)(BOOL success,id dataDic))handleBlock
{
    [_phoneNotification manuallyHideWithText:nil indicator:YES];
    WMHttpManager * manager = [WMHttpManager sharedManager];
    NSString *xx=[NSString stringWithFormat:@"{\"limit\":%d,\"page\":%d}",limit, page];
    [manager requestWithMethod:GET WithPath:[HttpURLManager acquiringAppealListUrl] WithParams:@{@"param": xx} WithSuccessBlock:^(NSDictionary *dic) {
        [_phoneNotification hideNotification];
        handleBlock(YES, dic);
    } WithFailurBlock:^(NSError *error) {
        [_phoneNotification hideNotification];
        [_phoneNotification autoHideWithText:@"加载失败"];
        handleBlock(NO,error);
    }];
}


@end


