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
#import <Toast/Toast.h>
#import "WMHttpNewManager.h"
#define PLAYER_HIGHT 300
#define kIndicatorViewSize 50
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
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIView *playerView;
@property (nonatomic, strong) UIButton *openButton; // 打开全屏按钮
@property (nonatomic, assign) BOOL isFullScreen;   /// 是否全屏标记
@property (nonatomic, assign) CGRect playerFrame;  /// 记录原始frame
@property (nonatomic, strong) UIView *playerSuperView;
@property (nonatomic, assign) CGRect fullScreenBtnFrame;
@property (nonatomic, strong) UILabel *flagLabel;
@property (nonatomic, strong) UIActivityIndicatorView   *indicatorView;
@property (nonatomic, assign) BOOL isPlaying;

@end

@implementation ViewController

#pragma mark - lifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self initWebView];
//    rtsp://221.130.29.224:554/openUrl/uaOMHgk
//    rtsp://221.130.29.224:554/openUrl/GBaZnva
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadUI:) name:@"ROLODE" object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self request];
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

- (void)request
{
    //    http://htci.rongzer.com/app-web/api/version/upgrade/getNewVersion?orders=1&search_EQ_mobileType=IOS
    
    [[WMHttpNewManager sharedManager] GET:@"/app-web/api/version/upgrade/getNewVersion" parameters:@{@"orders":@"1",@"search_EQ_mobileType":@"IOS"} progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dic = responseObject;
        BOOL isNew = [dic objectForKey:@"isNew"];
        NSLog(@"%d", isNew);
        if (isNew) {
            NSDictionary *data = [dic objectForKey:@"data"];
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"您有新版本更新~" preferredStyle:1];
            NSMutableAttributedString *AttributedStr = [[NSMutableAttributedString alloc] initWithString:@"您有新版本更新~"];
            [AttributedStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14] range:NSMakeRange(0, [[AttributedStr string] length])];
            [alert setValue:AttributedStr forKey:@"attributedMessage"];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"立即更新" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[data objectForKey:@"links"]]];
            }];
            [okAction setValue:[UIColor colorWithHexString:@"#333333"] forKey:@"titleTextColor"];
            
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"离开" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
            }];
            [cancel setValue:[UIColor colorWithHexString:@"#666666"] forKey:@"titleTextColor"];
            
            [alert addAction:okAction];
            [alert addAction:cancel];
            [self presentViewController:alert animated:YES completion:nil];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}

- (void)addPlayer:(id)vaule
{
    [self.contentView removeFromSuperview];
    self.contentView = nil;
    _player = nil;
    _playerView = nil;
    self.flagLabel = nil;
    _isFullScreen = NO;
    
    NSData *jsonData = [vaule dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    
    if ([[dic allKeys] containsObject:@"videoUrl"]) {
        id url = [dic objectForKey:@"videoUrl"];
        if (url == [NSNull null]) {
            self.bestWebView.frame = CGRectMake(0, kStatusBarHeight, SCREEN_WIDTH, SCREEN_HEIGHT  - kStatusBarHeight - kSafeAreaBottomHeight);
            return;
        }
    }
    
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, PLAYER_HIGHT)];
    contentView.backgroundColor = [UIColor colorWithHexString:@"#f2f2f2"];
    [self.view addSubview:contentView];
    self.contentView = contentView;
    
    
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, kStatusBarHeight, 50, 44)];
    [backButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [backButton setImageEdgeInsets:UIEdgeInsetsMake(12, 15, 12, 15)];
    [contentView addSubview:backButton];
    [backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(45, kStatusBarHeight, 250, 44)];
    titleLabel.text = [[dic allKeys] containsObject:@"title"] ? [dic objectForKey:@"title"] : @"";
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.textColor = [UIColor colorWithHexString:@"#000000"];
    titleLabel.font = [UIFont systemFontOfSize:15];
    [contentView addSubview:titleLabel];
//
    UIView *playerView = [[UIView alloc] initWithFrame:CGRectMake(15, kSafeAreaTopHeight, SCREEN_WIDTH - 30, PLAYER_HIGHT - kSafeAreaTopHeight)];
    playerView.layer.cornerRadius = 5;
    playerView.layer.masksToBounds = YES;
    playerView.backgroundColor = [UIColor blackColor];
    [contentView addSubview:playerView];
    self.playerView = playerView;
    
    UILabel *flagLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 130, SCREEN_WIDTH - 30, 20)];
    flagLabel.textAlignment = NSTextAlignmentCenter;
    flagLabel.text = @"获取视频失败，请检查设备和网络后重试";
    flagLabel.font = [UIFont systemFontOfSize:15];
    flagLabel.textColor = [UIColor whiteColor];
    [playerView addSubview:flagLabel];
    flagLabel.hidden = YES;
    self.flagLabel = flagLabel;

    _player = [[HVPPlayer alloc] initWithPlayView:playerView];
    _player.delegate = self;
    [_player startRealPlay:[[dic allKeys] containsObject:@"videoUrl"] ? [[dic objectForKey:@"videoUrl"] stringByReplacingOccurrencesOfString:@"'" withString:@""] : @""];
    
    self.openButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 55, PLAYER_HIGHT - 40, 40, 40)];
    self.openButton.backgroundColor = [UIColor colorWithHexString:@"#E2E2E2"];
    self.openButton.alpha = 0.6;
    self.openButton.layer.cornerRadius = 2;
    self.openButton.layer.masksToBounds = YES;
    [self.openButton setImage:[UIImage imageNamed:@"open"] forState:UIControlStateNormal];
    [contentView addSubview:self.openButton];
    [self.openButton addTarget:self action:@selector(onClick) forControlEvents:UIControlEventTouchUpInside];
    
    self.bestWebView.frame = CGRectMake(0, PLAYER_HIGHT, SCREEN_WIDTH, SCREEN_HEIGHT  - PLAYER_HIGHT - kSafeAreaBottomHeight);
    
    [self.view addSubview:self.indicatorView];
    self.indicatorView.frame = CGRectMake(SCREEN_WIDTH/2 - kIndicatorViewSize/2, kSafeAreaTopHeight + 125 - kIndicatorViewSize/2, kIndicatorViewSize, kIndicatorViewSize);
}

/**
 播放状态回调

 @param player 当前播放器
 @param playStatus 播放状态
 @param errorCode 错误码
 */
- (void)player:(HVPPlayer *)player playStatus:(HVPPlayStatus)playStatus errorCode:(HVPErrorCode)errorCode
{
//    NSLog(@"%lu", (unsigned long)playStatus);
//    if (HVPPlayStatusFailure == playStatus) {
//
//    } else if (HVPErrorCodeSuccess == playStatus) {
//        self.flagLabel.hidden = NO;
//        self.playerView.backgroundColor = [UIColor blackColor];
//        self.player = nil;
//    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // 如果有加载动画，结束加载动画
        if ([self.indicatorView isAnimating]) {
            [self.indicatorView stopAnimating];
        }
        _isPlaying = NO;
        NSString *message;
        // 预览时，没有HVPPlayStatusFinish状态，该状态表明录像片段已播放完
        if (playStatus == HVPPlayStatusSuccess) {
            _isPlaying = YES;
            // 默认开启声音
            self.openButton.hidden = NO;
            [self.player enableSound:YES error:nil];
        }
        else if (playStatus == HVPPlayStatusFailure) {
            if (errorCode == HVPErrorCodeURLInvalid) {
                message = @"URL输入错误请检查URL或者URL已失效请更换URL";
            }
            else {
                message = [NSString stringWithFormat:@"开启预览失败, 错误码是 : 0x%08lx", errorCode];
            }
            _player = nil;
            _flagLabel.hidden = NO;
            self.openButton.hidden = YES;
        }
        else if (playStatus == HVPPlayStatusException) {
            // 预览过程中出现异常, 可能是取流中断，可能是其他原因导致的，具体根据错误码进行区分
            // 做一些提示操作
        }
        if (message) {
//            [self.view makeToast:message duration:2 position:CSToastPositionCenter];
        }
    });
    
    
}

// 页面返回
- (void)back
{
//    hvrTopage
    NSString *promptCode = @"hvrTopage()";
    [self.bestWebView evaluateJavaScript:promptCode completionHandler:^(id _Nullable data, NSError * _Nullable error) {
        [self.contentView removeFromSuperview];
        self.contentView = nil;
        self.player = nil;
        self.playerView = nil;
        self.openButton = nil;
        self.flagLabel = nil;
        self.bestWebView.frame = CGRectMake(0, kStatusBarHeight, SCREEN_WIDTH, SCREEN_HEIGHT  - kStatusBarHeight - kSafeAreaBottomHeight);
    }];
}

- (void)onClick
{
    if (!_isFullScreen) {
        [self entryFullScreen];
        
    } else {
        [self exitFullScreen];
    }
}

// 进入全屏模式
- (void)entryFullScreen
{
    if (self.isFullScreen) {
        return;
    }
    
    self.bestWebView.hidden = YES;
    self.playerSuperView = self.playerView.superview;
    self.playerFrame = self.playerView.frame;
    self.fullScreenBtnFrame = self.openButton.frame;
    
    CGRect rectInWindow = [self.playerView convertRect:self.playerView.bounds toView:[UIApplication sharedApplication].keyWindow];
    CGRect btnRect = [self.openButton convertRect:self.openButton.bounds toView:[UIApplication sharedApplication].keyWindow];
    [self.playerView removeFromSuperview];
    [self.openButton removeFromSuperview];
    self.playerView.frame = rectInWindow;
    self.openButton.frame = CGRectMake(0, SCREEN_HEIGHT - 40, 40, 40);

    [[UIApplication sharedApplication].keyWindow addSubview:self.playerView];
    [[UIApplication sharedApplication].keyWindow addSubview:self.openButton];
    //
    [UIView animateWithDuration:0.3 animations:^{
        self.playerView.transform = CGAffineTransformMakeRotation(M_PI_2);
        self.openButton.transform = CGAffineTransformMakeRotation(M_PI_2);
        self.playerView.bounds = CGRectMake(0, 0, CGRectGetHeight([UIApplication sharedApplication].keyWindow.bounds), CGRectGetWidth([UIApplication sharedApplication].keyWindow.bounds));
        self.playerView.center = CGPointMake(CGRectGetMidX([UIApplication sharedApplication].keyWindow.bounds), CGRectGetMidY([UIApplication sharedApplication].keyWindow.bounds));
    } completion:^(BOOL finished) {
        [self.openButton setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
        self.isFullScreen = YES;
    }];
    
}

// 退出全屏模式
- (void)exitFullScreen
{
    self.bestWebView.hidden = NO;
    
    if (!self.isFullScreen) {
        return;
    }
    
    CGRect frame = [self.playerSuperView convertRect:self.playerFrame toView:[UIApplication sharedApplication].keyWindow];
    [UIView animateWithDuration:0.3 animations:^{
        self.playerView.transform = CGAffineTransformIdentity;
        self.openButton.transform = CGAffineTransformIdentity;
        self.playerView.frame = frame;
        self.openButton.frame = self.fullScreenBtnFrame;
    } completion:^(BOOL finished) {
        [self.playerView removeFromSuperview];
        [self.openButton removeFromSuperview];
        self.playerView.frame = self.playerFrame;
        [self.playerSuperView addSubview:self.playerView];
        [self.playerSuperView addSubview:self.openButton];
        self.isFullScreen = NO;
        [self.openButton setImage:[UIImage imageNamed:@"open"] forState:UIControlStateNormal];
    }];
    
}

/// 进入全屏模式
//- (void)entryFullScreen {
//    if (self.isFullScreen) {
//        return;
//    }
//
//    self.playerSuperView = self.playView.superview;
//    self.playerFrame = self.playView.frame;
//    self.fullScreenBtnFrame = self.fullScreenBtn.frame;
//
//    CGRect rectInWindow = [self.playView convertRect:self.playView.bounds toView:[UIApplication sharedApplication].keyWindow];
//    CGRect btnRect = [self.fullScreenBtn convertRect:self.fullScreenBtn.bounds toView:[UIApplication sharedApplication].keyWindow];
//    [self.playView removeFromSuperview];
//    [self.fullScreenBtn removeFromSuperview];
//    self.playView.frame = rectInWindow;
//    self.fullScreenBtn.frame = btnRect;
//
//
//    [[UIApplication sharedApplication].keyWindow addSubview:self.playView];
//    [[UIApplication sharedApplication].keyWindow addSubview:self.fullScreenBtn];
//
//    [UIView animateWithDuration:0.3 animations:^{
//
//        self.playView.transform = CGAffineTransformMakeRotation(M_PI_2);
//        self.playView.bounds = CGRectMake(0, 0, CGRectGetHeight([UIApplication sharedApplication].keyWindow.bounds), CGRectGetWidth([UIApplication sharedApplication].keyWindow.bounds));
//        self.playView.center = CGPointMake(CGRectGetMidX([UIApplication sharedApplication].keyWindow.bounds), CGRectGetMidY([UIApplication sharedApplication].keyWindow.bounds));
//    } completion:^(BOOL finished) {
//        [self.fullScreenBtn setTitle:@"退出全屏" forState:UIControlStateNormal];
//        self.isFullScreen = YES;
//    }];
//}
//
///// 退出全屏模式
//- (void)exitFullScreen {
//    if (!self.isFullScreen) {
//        return;
//    }
//
//    CGRect frame = [self.playerSuperView convertRect:self.playerFrame toView:[UIApplication sharedApplication].keyWindow];
//    [UIView animateWithDuration:0.3 animations:^{
//        self.playView.transform = CGAffineTransformIdentity;
//        self.playView.frame = frame;
//    } completion:^(BOOL finished) {
//        [self.playView removeFromSuperview];
//        [self.fullScreenBtn removeFromSuperview];
//        self.playView.frame = self.playerFrame;
//        [self.playerSuperView addSubview:self.playView];
//        [self.playerSuperView addSubview:self.fullScreenBtn];
//        self.isFullScreen = NO;
//        [self.fullScreenBtn setTitle:@"切为全屏" forState:UIControlStateNormal];
//    }];
//}


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

    _bestWebView = [[WKWebView alloc] initWithFrame:CGRectMake(0, kStatusBarHeight, SCREEN_WIDTH, SCREEN_HEIGHT  - kStatusBarHeight - kSafeAreaBottomHeight) configuration:config];
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
    } else if ([message.name isEqualToString:@"iosHvrToPage"]) {
        [self addPlayer:message.body];
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
    [self.bestWebView.configuration.userContentController addScriptMessageHandler:self name:@"getuserLoginInfoToAppIos"];
    [self.bestWebView.configuration.userContentController addScriptMessageHandler:self name:@"iosHvrToPage"];
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

- (UIActivityIndicatorView *)indicatorView {
    if (!_indicatorView) {
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    return _indicatorView;
}


@end

