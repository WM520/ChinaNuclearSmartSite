//
//  WebViewController.m
//  ChinaNuclearSmartSite
//
//  Created by miao on 2019/10/25.
//  Copyright © 2019 miao. All rights reserved.
//

#import "WebViewController.h"
#import <JavaScriptCore/JavaScriptCore.h>

@interface WebViewController ()
<UIWebViewDelegate>

@property (nonatomic, strong) UIWebView * webView;


@end

@implementation WebViewController

//- (void)viewDidLoad {
//    [super viewDidLoad];
//    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadUI:) name:@"ROLODE" object:nil];
//    // 1. 实例化一个UIWebView
//    UIWebView *webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
//    webView.delegate = self;
//    // 2. 获得NSURLRequest对象
//    NSString *str = @"https://zhgd.hwgc.cn:8050";
//    NSURL *url = [NSURL URLWithString:str];
//    NSURLRequest *request = [NSURLRequest requestWithURL:url];
//    // 3. 调用UIWebView的loadRequest方法加载网页内容
//    [webView loadRequest:request];
//    self.webView = webView;
//    [self.view addSubview:webView];
//}
//
//// 推送过来刷新页面
//- (void)reloadUI:(NSNotification *)notification
//{
//    NSDictionary * useInfo = notification.userInfo;
//    NSString * url = [useInfo objectForKey:@"url"];
//    dispatch_sync(dispatch_get_main_queue(), ^{
//        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
//    });
//}
//
//
//
//
////! UIWebView在每次加载请求完成后会调用此方法
//- (void)webViewDidFinishLoad:(UIWebView *)webView {
//    
//    //! 获取JS代码的执行环境/上下文/作用域
//    JSContext *context = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
//
//    //! 监听JS代码里面的jsToOc方法（执行效果上可以理解成重写了JS的jsToOc方法）
//    context[@"getQrCode"] = ^(NSString *action, NSString *params) {
//        dispatch_async(dispatch_get_main_queue(), ^{
////            [UIWebViewJavaScriptCoreController showAlertWithTitle:action message:params cancelHandler:nil];
//        });
//    };
//}



@end
