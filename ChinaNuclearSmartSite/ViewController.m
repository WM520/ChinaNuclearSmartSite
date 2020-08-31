//
//  ViewController.m
//  ChinaNuclearSmartSite
//
//  Created by miao on 2019/10/19.
//  Copyright © 2019 miao. All rights reserved.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import "ZFScanViewController.h"
#import "UserModel.h"
#import <UMPush/UMessage.h>
//#import <WebViewJavascriptBridge.h>
#import <HikVideoPlayer/HikVideoPlayer.h>
#import <HikVideoPlayer/HVPError.h>

@interface ViewController ()
<WKNavigationDelegate,
WKUIDelegate,
UIScrollViewDelegate,
WKScriptMessageHandler,
TZImagePickerControllerDelegate,
HVPPlayerDelegate>
{
    UIProgressView *progressV;
}

@property (nonatomic, strong) WKWebView *bestWebView;
@property (nonatomic, strong) JSContext *jsContent;
//@property (nonatomic, strong) WebViewJavascriptBridge * bridge;
@property (nonatomic, strong) WKUserContentController *userContentController;
@property (nonatomic, copy) NSString *count;
@property (nonatomic, strong) HVPPlayer *player;

@end

@implementation ViewController

#pragma mark - lifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self initWebView];
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, kStatusBarHeight, SCREEN_WIDTH, 400)];
    [self.view addSubview:contentView];
    _player = [[HVPPlayer alloc] initWithPlayView:contentView];
    _player.delegate = self;
    [_player startRealPlay:@"rtsp://221.130.29.224:554/openUrl/uaOMHgk"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadUI:) name:@"ROLODE" object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

#pragma mark - private methods
- (void)reloadUI:(NSNotification *)notification
{
    NSDictionary * useInfo = notification.userInfo;
    NSString * url = [useInfo objectForKey:@"url"];
    dispatch_sync(dispatch_get_main_queue(), ^{
        [self.bestWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
    });
}

- (void)initWebView
{
    self.detailUrl = APP_URL;
    WKWebViewConfiguration *config = [WKWebViewConfiguration new];
    //初始化偏好设置属性：preferences
    config.preferences = [WKPreferences new];
    //The minimum font size in points default is 0;
    config.preferences.minimumFontSize = 10;
    //是否支持JavaScript
    config.preferences.javaScriptEnabled = YES;
    //不通过用户交互，是否可以打开窗口
    config.preferences.javaScriptCanOpenWindowsAutomatically = YES;
    config.allowsInlineMediaPlayback = YES;
    if (@available(iOS 10.0, *)) {
        config.mediaTypesRequiringUserActionForPlayback = NO;
    }
    
    
    NSString*css = @"body{-webkit-user-select:none;-webkit-user-drag:none;}";

    //css 选中样式取消

    NSMutableString*javascript = [NSMutableString string];

    [javascript appendString:@"var style = document.createElement('style');"];

    [javascript appendString:@"style.type = 'text/css';"];

    [javascript appendFormat:@"var cssContent = document.createTextNode('%@');", css];

    [javascript appendString:@"style.appendChild(cssContent);"];

    [javascript appendString:@"document.body.appendChild(style);"];

    [javascript appendString:@"document.documentElement.style.webkitUserSelect='none';"];//禁止选择

    [javascript appendString:@"document.documentElement.style.webkitTouchCallout='none';"];//禁止长按

    //javascript 注入

    WKUserScript *noneSelectScript = [[WKUserScript alloc] initWithSource:javascript

    injectionTime:WKUserScriptInjectionTimeAtDocumentEnd

    forMainFrameOnly:YES];
    
    
    //这个类主要用来做native与JavaScript的交互管理
    WKUserContentController *userContentController = [[WKUserContentController alloc] init];
    config.userContentController = userContentController;
    [userContentController addUserScript:noneSelectScript];
    self.userContentController = userContentController;

    _bestWebView = [[WKWebView alloc] initWithFrame:CGRectMake(0, kStatusBarHeight + 400, SCREEN_WIDTH, SCREEN_HEIGHT  -kSafeAreaBottomHeight - kStatusBarHeight) configuration:config];
    _bestWebView.backgroundColor = [UIColor whiteColor];
    _bestWebView.scrollView.delegate = self;
    _bestWebView.navigationDelegate = self;
    _bestWebView.UIDelegate = self;
    _bestWebView.allowsBackForwardNavigationGestures = NO;
    _bestWebView.scrollView.bounces = NO;
    [self.view addSubview:_bestWebView];

    progressV = [[UIProgressView alloc] initWithFrame:CGRectZero];
    progressV.progressTintColor = [UIColor colorWithHexString:@"007AFF"];
    progressV.transform = CGAffineTransformMakeScale(1.0f, 1.5f);
    progressV.hidden = YES;
    [self.view addSubview:progressV];
    [progressV mas_makeConstraints:^(MASConstraintMaker *make){
        make.height.equalTo(@2);
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.top.equalTo(_bestWebView.mas_top);
    }];
    [_bestWebView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    [_bestWebView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:NULL];
    
    if(_detailUrl != nil && ![@"" isEqualToString:_detailUrl]){
        [_bestWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_detailUrl]]];
    }
   
}

- (void)dealloc
{
    progressV.hidden = YES;
    /// 移除所有的监听
    [_bestWebView removeObserver:self forKeyPath:@"estimatedProgress"];
    [_bestWebView removeObserver:self forKeyPath:@"title"];
    _bestWebView.scrollView.delegate = nil;
}

- (void)getQrCode
{
    kWeakSelf(self);
    ZFScanViewController * vc = [[ZFScanViewController alloc] init];
    vc.returnScanBarCodeValue = ^(NSString * barCodeString){
        //扫描完成后，在此进行后续操作
        [weakself dismissViewControllerAnimated:YES completion:^{
            NSString *promptCode = [NSString stringWithFormat:@"getQrMethodIos('%@')", barCodeString];
            [self.bestWebView evaluateJavaScript:promptCode completionHandler:^(id _Nullable data, NSError * _Nullable error) {
                     
            }];
        }];
    };
    [self presentViewController:vc animated:YES completion:^{
        
    }];
}
// 选择相片
- (void)useCamera
{
    kWeakSelf(self);
    // 获取相片
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:1 delegate:weakself];
    // 是否允许显示视频
    imagePickerVc.allowPickingVideo = NO;
    if ([_count intValue] > 0) {
        imagePickerVc.maxImagesCount = [_count intValue];
    } else {
        imagePickerVc.maxImagesCount = 1;
    }
    
    [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
//        NSString * pictureDataString = [weakself image2DataURL:photos[0]];
        NSString * pictureDataString = @"";
        if (photos.count == 1) {
              pictureDataString = [weakself image2DataURL:photos[0]];
          } else {
              NSMutableString * tem = [NSMutableString stringWithString:@"["];
              for (int i = 0; i < photos.count; i++) {
                  if ((i + 1) ==  photos.count) {
                      [tem appendString:[NSString stringWithFormat:@"%@]", [weakself image2DataURL:photos[i]]]];
                  } else {
                      [tem appendString:[NSString stringWithFormat:@"%@,", [weakself image2DataURL:photos[i]]]];
                  }
              }
              pictureDataString = [tem copy];
          }
        NSString *promptCode = [NSString stringWithFormat:@"getPhtotoValueIos('%@')", pictureDataString];
        [self.bestWebView evaluateJavaScript:promptCode completionHandler:^(id _Nullable data, NSError * _Nullable error) {
                 
        }];
    }];
    [weakself presentViewController:imagePickerVc animated:YES completion:nil];
}
// 保存登录信息
- (void)setUserInfoToApp:(NSDictionary *)userInfo
{
    // 持久化
    NSString *userInfoFile = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:@"userModel.archiver"];

    UserModel *userModel = [[UserModel alloc]init];
    userModel.token = [userInfo objectForKey:@"token"];
    userModel.projectId = [userInfo objectForKey:@"projectId"];
    userModel.phone = [userInfo objectForKey:@"phone"];
    userModel.userId = [userInfo objectForKey:@"userId"];
    userModel.data = [userInfo objectForKey:@"data"];
    
    NSString * string = [userModel.data objectForKey:@"logStatus"];
    
    if ([string isEqualToString:@"dengchu"]) {
        // 移除
        [UMessage removeAlias:[[NSUserDefaults standardUserDefaults] objectForKey:@"phone"] type:@"UMENG_USER" response:^(id  _Nonnull responseObject, NSError * _Nonnull error) {
            NSLog(@"responseObject = %@, error = %@", responseObject, error);
        }];
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"phone"];
        userModel.token = @"";
        userModel.projectId = @"";
        userModel.phone = @"";
        userModel.userId = @"";
//        NSString * url = @"https://zhgd.hwgc.cn:8050/#/";
//        [self.bestWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
        [NSKeyedArchiver archiveRootObject:userModel toFile:userInfoFile];
    } else {
        [NSKeyedArchiver archiveRootObject:userModel toFile:userInfoFile];
        [[NSUserDefaults standardUserDefaults] setObject:userModel.phone forKey:@"phone"];
        //添加别名
        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"phone"] != nil) {
            [UMessage addAlias:[[NSUserDefaults standardUserDefaults] objectForKey:@"phone"] type:@"UMENG_USER" response:^(id  _Nonnull responseObject, NSError * _Nonnull error) {
                  NSLog(@"responseObject = %@, error = %@", responseObject, error);
            }];
        }
        
        //取出来看一下
        UserModel *unarchiveModel = [NSKeyedUnarchiver unarchiveObjectWithFile:userInfoFile];
        if (unarchiveModel) {
            NSLog(@"%@ %@ %@ %@ %@",unarchiveModel.token,unarchiveModel.projectId,unarchiveModel.phone, unarchiveModel.userId, unarchiveModel.data);
        }
    }
}

- (void)getUserInfoToApp
{
    NSString *userInfoFile = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:@"userModel.archiver"];
    UserModel *unarchiveModel = [NSKeyedUnarchiver unarchiveObjectWithFile:userInfoFile];
    NSDictionary * dic = @{
        @"token":unarchiveModel.token ? unarchiveModel.token : @"",
        @"projectId":unarchiveModel.projectId ? unarchiveModel.projectId : @"",
        @"phone":unarchiveModel.phone ? unarchiveModel.phone : @"",
        @"userId":unarchiveModel.userId ? unarchiveModel.userId : @"",
        @"data":unarchiveModel.data ? unarchiveModel.data : @""
    };
    NSString * jsonString = [self dictionaryToJson: dic];
    NSString * newString = [self noWhiteSpaceString:jsonString];
    NSString *promptCode = [NSString stringWithFormat:@"getUserInfoToApp('%@')", newString];
    [self.bestWebView evaluateJavaScript:promptCode completionHandler:^(id _Nullable data, NSError * _Nullable error) {
               
    }];
}

- (NSString *)noWhiteSpaceString:(NSString *)str {
    NSString *newString = str;
  //去除掉首尾的空白字符和换行字符
    newString = [newString stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    newString = [newString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    newString = [newString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];  //去除掉首尾的空白字符和换行字符使用
    newString = [newString stringByReplacingOccurrencesOfString:@" " withString:@""];
//    可以去掉空格，注意此时生成的strUrl是autorelease属性的，所以不必对strUrl进行release操作！
    return newString;
}

//UIImage -> Base64图片
- (BOOL) imageHasAlpha: (UIImage *) image
{
    CGImageAlphaInfo alpha = CGImageGetAlphaInfo(image.CGImage);
    return (alpha == kCGImageAlphaFirst ||
            alpha == kCGImageAlphaLast ||
            alpha == kCGImageAlphaPremultipliedFirst ||
            alpha == kCGImageAlphaPremultipliedLast);
}

- (UIImage *)compressImage:(UIImage *)image toByte:(NSUInteger)maxLength {
    // Compress by quality
    CGFloat compression = 1;
    NSData *data = UIImageJPEGRepresentation(image, compression);
    if (data.length < maxLength) return image;
    
    CGFloat max = 1;
    CGFloat min = 0;
    for (int i = 0; i < 6; ++i) {
        compression = (max + min) / 2;
        data = UIImageJPEGRepresentation(image, compression);
        if (data.length < maxLength * 0.9) {
            min = compression;
        } else if (data.length > maxLength) {
            max = compression;
        } else {
            break;
        }
    }
    UIImage *resultImage = [UIImage imageWithData:data];
    if (data.length < maxLength) return resultImage;
    
    // Compress by size
    NSUInteger lastDataLength = 0;
    while (data.length > maxLength && data.length != lastDataLength) {
        lastDataLength = data.length;
        CGFloat ratio = (CGFloat)maxLength / data.length;
        CGSize size = CGSizeMake((NSUInteger)(resultImage.size.width * sqrtf(ratio)),
                                 (NSUInteger)(resultImage.size.height * sqrtf(ratio))); // Use NSUInteger to prevent white blank
        UIGraphicsBeginImageContext(size);
        [resultImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
        resultImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        data = UIImageJPEGRepresentation(resultImage, compression);
    }
    
    return resultImage;
}

- (NSString *) image2DataURL: (UIImage *) image
{
    NSData *imageData = nil;
    NSString *mimeType = nil;

    if ([self imageHasAlpha: image]) {
        imageData = UIImagePNGRepresentation([self compressImage:image toByte:300 * 1024]);
        mimeType = @"image/png";
    } else {
        imageData = UIImageJPEGRepresentation([self compressImage:image toByte:300 * 1024], 0.4f);
        mimeType = @"image/jpeg";
    }
    return [imageData base64EncodedStringWithOptions: 0];
}

- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString
{
    if (jsonString == nil) {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

- (NSString*)dictionaryToJson:(NSDictionary *)dic
{
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&parseError];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

#pragma mark - WKUIDelegate
-(WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures
{
    if (!navigationAction.targetFrame.isMainFrame) {
        [webView loadRequest:navigationAction.request];
    }
    return nil;
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    NSLog(@"加载失败%@", error.userInfo);
}

- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *_Nullable))completionHandler
{
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        if (challenge.previousFailureCount == 0) {
            NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
            completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
        } else {
            completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
        }
    }
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    if ([message.name isEqualToString:@"getQrCode"]) {
        //调用原生扫码
        [self getQrCode];
    } else if ([message.name isEqualToString:@"useCamera"]) {
        // 调用原生获取相片功能
        _count = message.body;
        [self useCamera];
    } else if ([message.name isEqualToString:@"setUserInfoToApp"]) {
        // 存取登录信息
        [self setUserInfoToApp: [self dictionaryWithJsonString:message.body]];
    } else if ([message.name isEqualToString:@"getuserLoginInfoToAppIos"]) {
        // 返回登录信息
        [self getUserInfoToApp];
    }
}

#pragma mark - WKNavigationDelegate
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        progressV.progress = _bestWebView.estimatedProgress;
        if (progressV.progress == 1) {
            /*
             *添加一个简单的动画，将progressView的Height变为1.4倍，在开始加载网页的代理中会恢复为1.5倍
             *动画时长0.25s，延时0.3s后开始动画
             *动画结束后将progressView隐藏
             */
            [UIView animateWithDuration:0.25f delay:0.3f options:UIViewAnimationOptionCurveEaseOut animations:^{
                progressV.transform = CGAffineTransformMakeScale(1.0f, 1.4f);
            } completion:^(BOOL finished) {
                progressV.hidden = YES;
            }];
        }
    }  else if ([keyPath isEqualToString:@"title"]) {
        if (object == self.bestWebView) {
            self.title = [self URLDecodedString:self.bestWebView.title];
        }  else {
            [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(nonnull WKNavigationResponse *)navigationResponse decisionHandler:(nonnull void (^)(WKNavigationResponsePolicy))decisionHandler
{
    // 方法一
        NSHTTPURLResponse *response = (NSHTTPURLResponse *)navigationResponse.response;
        NSArray *cookies = [NSHTTPCookie cookiesWithResponseHeaderFields:[response allHeaderFields] forURL:response.URL];
        NSLog(@"response-cookies = %@",cookies);
        
        //方法二
        NSString *cookieString = [[response allHeaderFields] valueForKey:@"Set-Cookie"];
        NSLog(@"cookieString = %@",cookieString);
        
        //方法三（如果有的话）
        NSArray<NSHTTPCookie *> *httpCookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
        NSLog(@"httpCookies = %@",httpCookies);
        
        //方法四
        if(@available(iOS 11, *)){
            //WKHTTPCookieStore的使用
            WKHTTPCookieStore *cookieStore = self.bestWebView.configuration.websiteDataStore.httpCookieStore;
            //获取 cookies
            [cookieStore getAllCookies:^(NSArray<NSHTTPCookie *> * _Nonnull cookies) {
                [cookies enumerateObjectsUsingBlock:^(NSHTTPCookie * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    NSLog(@"cookieStore-cookies_%@:%@",@(idx),obj);
                }];
            }];
        }
        //将cookie设置到本地
        for (NSHTTPCookie *cookie in cookies) {
            //NSHTTPCookie cookie
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
        }
        
        decisionHandler(WKNavigationResponsePolicyAllow);
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    NSString *urlstr = navigationAction.request.URL.absoluteString;
    if ([urlstr hasPrefix:@"iosaction://getQrCode"]) {
        decisionHandler(WKNavigationActionPolicyCancel);
    } else if ([urlstr hasPrefix:@"songshu://"]) {
        decisionHandler(WKNavigationActionPolicyCancel);
    } else {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}

-(NSString *)URLDecodedString:(NSString *)str
{
    NSString *encodedString = str;
    NSString *decodedString  = (__bridge_transfer NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL,(__bridge CFStringRef)encodedString,CFSTR(""),CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
    return decodedString;
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation
{
    progressV.hidden = NO;
    progressV.transform = CGAffineTransformMakeScale(1.0f, 1.5f);
    [self.view bringSubviewToFront:progressV];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation
{
    progressV.hidden = YES;
    [self.bestWebView.configuration.userContentController addScriptMessageHandler:self name:@"getQrCode"];
    [self.bestWebView.configuration.userContentController addScriptMessageHandler:self name:@"useCamera"];
    [self.bestWebView.configuration.userContentController addScriptMessageHandler:self name:@"setUserInfoToApp"];
    [self.bestWebView.configuration.userContentController addScriptMessageHandler:self name:@"getuserLoginInfoToAppIos"] ;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
// OC 调用JS方法 method 的js代码可往下看
       [self getUserInfoToApp];
    });
    
    // 禁用长按效果
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
          
          for (UIView *view in self.bestWebView.subviews) {
              
              if ([NSStringFromClass([view class]) isEqualToString:@"WKScrollView"]) {
                  
                  for (UIGestureRecognizer *gesture in view.gestureRecognizers) {
                      if ([NSStringFromClass([gesture class]) isEqualToString:@"UILongPressGestureRecognizer"]) {
                          [view removeGestureRecognizer:gesture];
                      }
                  }
              }
          }
      });
}

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler{

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();//此处的completionHandler()就是调用JS方法时，`evaluateJavaScript`方法中的completionHandler
    }];
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:nil];
}

//接收到确认面板
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler{
    
}

//接收到输入框
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable result))completionHandler{
    
    NSData *jsonData = [prompt dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if (!err) {
        if([[dict objectForKey:@"selector"]isEqualToString:@"getAppVersion"]){
            
            NSString *userInfoFile = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:@"userModel.archiver"];
             UserModel *unarchiveModel = [NSKeyedUnarchiver unarchiveObjectWithFile:userInfoFile];
            
            NSDictionary * dic = @{
                @"token":unarchiveModel.token ? unarchiveModel.token : @"",
                @"projectId":unarchiveModel.projectId ? unarchiveModel.projectId : @"",
                @"phone":unarchiveModel.phone ? unarchiveModel.phone : @"",
                @"userId":unarchiveModel.userId ? unarchiveModel.userId : @"",
                @"data":unarchiveModel.data ?  unarchiveModel.data: @""
            };
            NSString * jsonString = [self dictionaryToJson: dic];
            NSString * newString = [self noWhiteSpaceString:jsonString];
            completionHandler(newString);
            return;
        } else if ([[dict objectForKey:@"selector"]isEqualToString:@"updateAppSkip"]) {
            NSArray * temA = [dict objectForKey:@"params"];
            NSDictionary * urlDic = temA[0];
            NSString * url = [urlDic objectForKey:@"url"];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
            completionHandler(@"");
            return;
        }
    }

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:prompt message:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = defaultText;
    }];
    [alertController addAction:([UIAlertAction actionWithTitle:@"完成" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(alertController.textFields[0].text?:@"");
    }])];

    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error
{
    progressV.hidden = YES;
}

// 禁止放大缩小
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return nil;
}

#pragma mark - setter or getter
//- (HVPPlayer *)player
//{
//    if (!_player) {
//        _player = [[HVPPlayer alloc] initWithPlayView:self.view];
//        _player.delegate = self;
//    }
//    return _player;
//}

@end

