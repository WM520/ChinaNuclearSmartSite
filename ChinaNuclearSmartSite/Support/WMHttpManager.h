//
//  WMHttpManager.h
//  PowerBank
//
//  Created by baiju on 2017/8/15.
//  Copyright © 2017年 wangmiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>


#define Login_Token [[AppSettings sharedInstance] stringForKey:@"token"] == nil ? @"" : [[AppSettings sharedInstance] stringForKey:@"token"]
/** 推送测试 */
#define PUSH_TEST @"/test/yuntuisong"
/** 登录 */
#define UserLogin_URI  @"/v1/login"
/** 获取验证码 */
#define ACQUIRING_MESSAGE_CODE @"/v1/sendMsgCode"
/** 获取aliyun访问token */
#define ACQUIRING_ALIYUN_TOKEN_URL  @"/common/v1/aliyun/ststoken"
/** 获取用户信息 */
#define PERSONAL_INFORMATION_URL @"/user/v1/info"
/** 获取用户信用记录 */
#define PERSONAL_CREDIT_URL @"/credit/v1/list"
/** 获取用户充电记录 */
#define PERSONAL_CHARGER_URL @"/user/v1/charger/list"
/** 身份认证 */
#define PERSONAL_IDENTIFY_URL @"/user/v1/identify"
/** 绑定银行卡 */
#define ADD_BANKCARD_URL @"/user/v1/bankcard"
/** 修改用户头像 */
#define MODIFACATION_HEADIMAGE_URL @"/user/v1/headimage"
/** 获取银行卡信息 */
#define DELETE_BANKCARD_URL @"/user/v1/bankcard"
/** 用户提现 POST */
#define USER_CASH_URL @"/user/v1/cash"
/** 获取用户交易记录 */
#define USER_TRANSACT_URL @"/user/v1/trade"
/** 获取用户消息列表 */
#define USER_MESSAGE_URL @"/user/v1/notice"
/** 设置消息已读  /user/v1/notice/消息ID(PUT)*/
#define USER_MESSAGE_ISSCAN_URL @"/user/v1/notice"
/** 删除消息 /user/v1/notice/消息ID(DELETE) */
#define DELETE_MESSAGE_URL @"/user/v1/notice"
/*********************3需求***************************************************/
/** 获取用户需求 */
#define REQUIRE_URL @"/user/v1/require"
/** 获取周围需求列表 */
#define PIO_URL @"/require/v1/list"
/*********************4共享**************************************************/
/** 用户共享 */
#define SHARE_URL @"/user/v1/share"
/** 获取周围共享列表 */
#define PIO_SHARE_URL @"/share/v1/list"
/*********************5订单**************************************************/
/** 接单 */
#define RECEIPT_LIST_URL @"/user/v1/order"
/** 获取用户订单需求（取消） */
#define ACQUIRING_ORDER_URL @"/user/v1/order/require"
/** 获取用户共享订单(取消) */
#define SHAER_ORDER_URL @"/user/v1/order/share"
/** 获取用户订单列表 */
#define ACQUIRING_ORDER_LIST_URL @"/user/v1/order/list"
/** 订单送达 */
#define ORDER_SENDED_URL @"/user/v1/order/sended"
/** 更新共享用户位置post(get 获取共享用户位置) */
#define UPDATA_SHAREURE_LOCATION_URL @"/user/v1/order/share/address"
/** 获取用户未送达信息列表 */
#define ACQUIRING_ORDER_UNSENDED_URL @"/user/v1/order/nosend/list"
/** 订单未送达接口 */
#define ORDER_UNSENDED_URL @"/user/v1/order/nosended"
/*********************6.柜机**************************************************/
/** 获取柜机列表 */
#define CABINET_LIST_URL @"/cabinet/v1/list"
/*********************7.设备**************************************************/
// 打开设备充电接口
#define OPEN_POWER_URL @"/device/v1/open"
// 提交设备状态
#define CHARGING_STATUS_URL @"/device/v1/status"
// 报修
#define FEEDBACK_REPAIR_URL @"/repair/v1/new"
/*********************8.反馈建议**************************************************/
// 上传反馈建议图片
#define  FEEDBARK_UPLOAD_URL @"/feedback/v1/upload/image"
// 提交反馈建议接口
#define FEEDBARK_URL @"/feedback/v1/new"
/*********************9.支付**************************************************/
// 获取支付方式列表
#define ACQUIRING_PAY_URL @"/pay/v1/paytype"
// 余额支付
#define BALANCE_PAY_URL @"/pay/v1/balance/pay"
// 微信支付
#define WECHAT_PAY_URL @"/pay/v1/wechat/pay"
// 支付宝支付
#define ALIPAY_PAY_URL @"/pay/v1/alipay/pay"
/*********************10. 申诉************************************************/
/** 新增申诉 */
#define ADD_APPEAL_URL @"/appeal/v1/new"
/** 获取用户申诉列表 */
#define ACQUIRING_APPEAL_LIST_URL @"/appeal/v1/list"
//请求成功回调block
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


@interface WMHttpManager : AFHTTPSessionManager
// 网络请求类
+ (WMHttpManager *)sharedManager;

- (void)requestWithMethod:(HTTPMethod)method
                 WithPath:(NSString *)path
               WithParams:(id)params
         WithSuccessBlock:(requestSuccessBlock)success
          WithFailurBlock:(requestFailureBlock)failure;

@end

@interface HttpURLManager : NSObject

+ (NSString *)requireUrl;

@end

@interface WMRequestHelper : NSObject
// 网络接口单例类
+ (WMRequestHelper *)shareManager;

+ (void)pushTest:(NSString *)token
withCompletionHandle:(void(^)(BOOL success,id dataDic))handleBlock;

/**
 *  登录（通）
 *
 *  @param phone           手机号
 *  @param validateCodeStr 验证码
 *  @param handleBlock     回调
 */
+ (void)loginRequestWithPhone:(NSString *)phone
              validateCodeStr:(NSString *)validateCodeStr
                     platform:(NSString *)platform
                     deviceId:(NSString *)deviceId
         withCompletionHandle:(void(^)(BOOL success,id dataDic))handleBlock;

#pragma mark - 获取验证码
+ (void)acquiringMessageCode:(NSString *)phoneNumber
                        type:(NSString *)type
        withCompletionHandle:(void(^)(BOOL success,id dataDic))handleBlock;

#pragma mark - 获取aliyun访问token
+ (void)acquiringAliyunToken:(NSString *)token
        withCompletionHandle:(void(^)(BOOL success,id dataDic))handleBlock;

#pragma mark - 获取用户信息
+ (void)acquiringInformation:(NSString *)token
    withCompletionHandle:(void(^)(BOOL success,id dataDic))handleBlock;

#pragma mark - 修改用户信息
+ (void)modificationUserValue:(NSString *) value
                          key:(NSString *) key
         withCompletionHandle:(void(^)(BOOL success,id dataDic))handleBlock;

#pragma mark - 获取用户信用记录
+ (void)acquiringCreditList:(int)limit
                       page:(int)page
       withCompletionHandle:(void(^)(BOOL success,id dataDic))handleBlock;

#pragma mark - 获取用户充电记录
+ (void)acquiringChargerList:(int)limit
                       page:(int)page
       withCompletionHandle:(void(^)(BOOL success,id dataDic))handleBlock;

#pragma mark - 身份认证
+ (void)userIdentifyWithName:(NSString *)name
                      number:(NSString *)number
        withCompletionHandle:(void(^)(BOOL success,id dataDic))handleBlock;

#pragma mark - 绑定银行卡
+ (void)addBankCardWithUsername:(NSString *)username
                       bankname:(NSString *)bankname
                    depositname:(NSString *)depositname
                         number:(NSString *)number
           withCompletionHandle:(void(^)(BOOL success,id dataDic))handleBlock;
#pragma mark - 获取银行卡信息
+ (void)acquiringBankCardInformation:(NSString *)token
                withCompletionHandle:(void (^)(BOOL success, id dataDic))handleBlock;
#pragma mark - 用户删除银行卡
+ (void)deleteBankCardWithCardNumber:(NSString *)cardNumber
                withCompletionHandle:(void (^)(BOOL success, id dataDic))handleBlock;
#pragma mark - 修改用户头像接口
+ (void)modifacationUserHeadImage:(UIImage *)headImage
             withCompletionHandle:(void(^)(BOOL success,id dataDic))handleBlock;

#pragma mark - 用户提现
+ (void)userCashWithMoney: (NSString *)money
                     bcid: (NSString *)bcid
     withCompletionHandle:(void(^)(BOOL success,id dataDic))handleBlock;

#pragma mark - 用户交易记录
+ (void)userTransactListWithList: (NSString *)limit
                            page: (NSString *)page
            withCompletionHandle:(void(^)(BOOL success,id dataDic))handleBlock;

#pragma mark - 消息列表
+ (void)userMessageListWithList: (NSString *)limit
                            page: (NSString *)page
            withCompletionHandle:(void(^)(BOOL success,id dataDic))handleBlock;

#pragma mark - 获取用户需求
+ (void)acquiringRequire:(NSString *)token
    withCompletionHandle:(void(^)(BOOL success,id dataDic))handleBlock;


#pragma mark -新增用户需求
+ (void)addUserRequire:(NSString *)token
             longitude:(NSString *)longitude
              latitude:(NSString *)latitude
                  addr:(NSString *)addr
               address:(NSString *)address
                 money:(NSString *)money
                  date:(NSString *)date
  withCompletionHandle:(void(^)(BOOL success,id dataDic))handleBlock;

#pragma mark - 取消用户需求
+ (void)deleteOrder:(NSString *)orderID
withCompletionHandle:(void(^)(BOOL success,id dataDic))handleBlock;

#pragma mark - 修改用户需求（加价）
+ (void)addPrice:(NSString *)orderID
       longitude:(NSString *)longitude
        latitude:(NSString *)latitude
            addr:(NSString *)addr
         address:(NSString *)address
           money:(NSString *)money
            date:(NSString *)date
withCompletionHandle:(void(^)(BOOL success,id dataDic))handleBlock;


#pragma mark - 获取周围需求列表
+ (void)getPIOList:(NSString *) radius
       longitude:(NSString *)longitude
        latitude:(NSString *)latitude
            filter:(NSString *)filter
              sort:(NSString *)sort
           limit:(NSString *)limit
            page:(NSString *)page
withCompletionHandle:(void(^)(BOOL success,id dataDic))handleBlock;


#pragma mark - 获取用户共享信息接口
+ (void)getUserShareWithCompletionHandle:(void(^)(BOOL success,id dataDic))handleBlock;

#pragma mark - 添加用户共享信息接口
+ (void)addUserShare:(NSString *)longitude
            latitude:(NSString *)latitude
                addr:(NSString *)addr
             address:(NSString *)address
            quantity:(NSString *)quantity
              device:(NSString *)device // 充电宝设备UUID
WithCompletionHandle:(void(^)(BOOL success,id dataDic))handleBlock;

#pragma mark - 取消用户共享接口
+ (void)getUserShare:(NSString *)shareID
WithCompletionHandle:(void(^)(BOOL success,id dataDic))handleBlock;

#pragma mark - 获取周围共享列表接口
+ (void)getSharePIOList:(NSString *) radius
         longitude:(NSString *)longitude
          latitude:(NSString *)latitude
            filter:(NSString *)filter
              sort:(NSString *)sort
             limit:(NSString *)limit
              page:(NSString *)page
withCompletionHandle:(void(^)(BOOL success,id dataDic))handleBlock;

#pragma mark - 接单接口
+ (void)receiptList:(NSString *) urid
               usid:(NSString *)usid
              uruid:(NSString *)uruid
              usuid:(NSString *)usuid
             device:(NSString *)device
           quantity:(NSString *)quantity
              money:(NSString *)money
withCompletionHandle:(void(^)(BOOL success,id dataDic))handleBlock;
#pragma mark - 获取用户需求订单接口
+ (void)getUserRequireOrderWithCompletionHandle:(void(^)(BOOL success,id dataDic))handleBlock;
#pragma mark - 取消用户需求订单接口
+ (void)deleteUserRequireOrder:(NSString *)orderID withCompletionHandle:(void (^)(BOOL success, id dataDic))handleBlock;
#pragma mark - 获取用户共享订单接口
+ (void)getUserShareOrderWithCompletionHandle:(void(^)(BOOL success,id dataDic))handleBlock;
#pragma mark - 取消用户共享订单接口
+ (void)deleteUserShareOrder:(NSString *)orderID withCompletionHandle:(void (^)(BOOL, id))handleBlock;

#pragma mark - 获取用户订单列表接口
+ (void)acquiringUserOrderListWithLimit:(int)limit
                          page:(int)page
                   withCompletionHandle:(void(^)(BOOL success,id dataDic))handleBlock;



#pragma mark - 订单送达接口
+ (void)shareOrderSendWithOrderID:(NSString *)orderID
             WithCompletionHandle:(void(^)(BOOL success,id dataDic))handleBlock;

#pragma mark - 更新共享用户位置
+ (void)updataShareUserLocationWithOrderID:(NSString *)orderId
                                 longitude:(NSString *)longitude
                                  latitude:(NSString *)latitude
                                   address:(NSString *)address
                      withCompletionHandle:(void(^)(BOOL success,id dataDic))handleBlock;
#pragma mark - 获取共享用户位置
+ (void)acquiringShareUserLocationWithOrderID:(NSString *)orderId
                         withCompletionHandle:(void(^)(BOOL success,id dataDic))handleBlock;

#pragma mark - 获取用户未送达列表
+ (void)acquiringUserUnsendedOrderWithLimit:(NSString *)limit
                                       page:(NSString *)page
                       withCompletionHandle:(void(^)(BOOL success,id dataDic))handleBlock;

#pragma mark - 订单未送达接口
+ (void)shareOrderUnsendWithCompletionHandle:(void(^)(BOOL success,id dataDic))handleBlock;

#pragma mark - 获取周围柜机列表
+ (void)getCabinetList:(NSString *) radius
              longitude:(NSString *)longitude
               latitude:(NSString *)latitude
                 filter:(NSString *)filter
                   sort:(NSString *)sort
                  limit:(NSString *)limit
                   page:(NSString *)page
   withCompletionHandle:(void(^)(BOOL success,id dataDic))handleBlock;


#pragma mark - 打开设备充电
+ (void)openToPowerWithUuid:(NSString *)uuid
                  longitude:(NSString *)longitude
                   latitude:(NSString *)latitude
                    address:(NSString *)address
    withCompletionHandle:(void(^)(BOOL success,id dataDic))handleBlock;
#pragma mark - 提交设备状态
+ (void)commitPowerStatusWithUuid:(NSString *)uuid
                      temperature:(NSString *)temperature
                         quantity:(NSString *)quantity
                        longitude:(NSString *)longitude
                         latitude:(NSString *)latitude
                          charger:(NSString *)charger
                             info:(NSString *)info
       withCompletionHandle:(void(^)(BOOL success,id dataDic))handleBlock;

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



#pragma mark - 上传反馈建议图片
+ (void)uploadFeedBackImage:(UIImage *)feedBackImage
       withCompletionHandle:(void(^)(BOOL success,id dataDic))handleBlock;

#pragma mark - 提交反馈意见和图片
+ (void)uploadContent:(NSString *)content
               images:(NSArray *)images
 withCompletionHandle:(void(^)(BOOL success,id dataDic))handleBlock;

#pragma mark - 余额支付
+ (void)payBalanceWithOrderId:(NSString *)orderId
                          fee:(NSInteger)fee
                        money:(NSString *)money
         withCompletionHandle:(void(^)(BOOL success,id dataDic))handleBlock;

#pragma mark - 微信支付
+ (void)payWechatWithBody:(NSString *)body
                   detail:(NSString *)detail
                  orderId:(NSString *)orderId
                      fee:(NSInteger)fee
                    money:(NSString *)money
     withCompletionHandle:(void(^)(BOOL success,id dataDic))handleBlock;

#pragma mark - 支付宝支付
+ (void)payAliPayWithTitle:(NSString *)title
                   orderId:(NSString *)orderId
                       fee:(NSInteger)fee
                     money:(NSString *)money
      withCompletionHandle:(void(^)(BOOL success,id dataDic))handleBlock;


#pragma mark - 新增申诉
+ (void)addAppealWithOrderId:(NSString *)orderId
                     content:(NSString *)content
        withCompletionHandle:(void(^)(BOOL success,id dataDic))handleBlock;

#pragma mark - 获取用户申诉列表接口
+ (void)acquiringAppealList:(int)limit
                        page:(int)page
        withCompletionHandle:(void(^)(BOOL success,id dataDic))handleBlock;
@end


