//
//  ViewController.m
//  ChinaNuclearSmartSite
//
//  Created by miao on 2019/10/19.
//  Copyright © 2019 miao. All rights reserved.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>
#import <Masonry.h>
#import "UIColor+expanded.h"
#import "DimensMacros.h"

@interface ViewController ()
<WKNavigationDelegate,
WKUIDelegate,
UIScrollViewDelegate>
{
    UIProgressView *progressV;
}

@property (nonatomic, strong) WKWebView *bestWebView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self initWebView];
//    [self setWebViewUA];
}

//- (void)setWebViewUA
//{
//    //修改webView UA
//    WKWebView *webView = [[WKWebView alloc] initWithFrame:CGRectZero];
//    _bestWebView = webView;
//   //获取自定义的UA重置字符串
//    NSString *UA = [[MTDGlobalObject shareGlobalObject] getUAStr:MTDUATypeWebView];
//    //替换本地中的UA内容
//    [[NSUserDefaults standardUserDefaults] registerDefaults:@{@"UserAgent":UA}];
//    [[NSUserDefaults standardUserDefaults] synchronize];
//    //设置webView的UA
//    [_bestWebView setCustomUserAgent:UA];
//}

- (void)initWebView
{
    self.title = @"加载中...";
    self.detailUrl = @"http://zhgd.hwgc.cn:8025";
//    self.detailUrl = @"https://www.baidu.com/";
    WKWebViewConfiguration *config = [WKWebViewConfiguration new];
    //初始化偏好设置属性：preferences
    config.preferences = [WKPreferences new];
    //The minimum font size in points default is 0;
    config.preferences.minimumFontSize = 10;
    //是否支持JavaScript
    config.preferences.javaScriptEnabled = YES;
    //不通过用户交互，是否可以打开窗口
    config.preferences.javaScriptCanOpenWindowsAutomatically = NO;

    _bestWebView = [[WKWebView alloc] initWithFrame:CGRectMake(0, kStatusBarHeight, SCREEN_WIDTH, SCREEN_HEIGHT  -kSafeAreaBottomHeight - kStatusBarHeight) configuration:config];
    _bestWebView.scrollView.delegate = self;

    [self.view addSubview:_bestWebView];

    _bestWebView.navigationDelegate = self;
    _bestWebView.UIDelegate = self;

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


#pragma mark - WKUIDelegate
-(WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures
{
    if (!navigationAction.targetFrame.isMainFrame) {
        [webView loadRequest:navigationAction.request];
    }
    return nil;
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
    } else if ([keyPath isEqualToString:@"title"])
    {
        if (object == self.bestWebView)
        {
         
                self.title = [self URLDecodedString:self.bestWebView.title];
            }
            
        else
        {
            [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        }
    }
    else
    {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    NSString *urlstr = navigationAction.request.URL.absoluteString;
    if ([urlstr hasPrefix:@"snt://"]) {
        NSString *query = navigationAction.request.URL.query;
        if (query == nil) {
            query = [urlstr substringFromIndex:[urlstr rangeOfString:@"snt://"].length];
        }
        NSArray *params = [query componentsSeparatedByString:@"&"];
        NSMutableDictionary *paramDic = [[NSMutableDictionary alloc] init];
        for (NSString *item in params) {
            NSArray *values = [item componentsSeparatedByString:@"="];
            if (values.count == 2) {
                [paramDic setValue:[values objectAtIndex:1] forKey:[values objectAtIndex:0]];
            }
            
        }
        if ([@"goodsdetail" isEqualToString:[paramDic valueForKey:@"page"]]) {
//            NSString *itemid = [paramDic valueForKey:@"itemid"];
  
        }
        
        if ([@"goodsList" isEqualToString:[paramDic valueForKey:@"page"]]) {

        }
        
        if ([@"activity" isEqualToString:[paramDic valueForKey:@"page"]]) {

        }
        decisionHandler(WKNavigationActionPolicyCancel);
    } else if ([urlstr hasPrefix:@"songshu://"]) {
        decisionHandler(WKNavigationActionPolicyCancel);
    } else {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}

-(NSString *)URLDecodedString:(NSString *)str
{
    //NSString *decodedString = [encodedString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding ];
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
#pragma mark - getter or setter


@end
