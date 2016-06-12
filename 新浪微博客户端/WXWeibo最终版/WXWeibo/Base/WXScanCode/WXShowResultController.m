//
//  WXShowResultController.m
//  QRCode
//
//  Created by JayWon on 15/12/15.
//  Copyright © 2015年 JayWon. All rights reserved.
//

#import "WXShowResultController.h"

@interface WXShowResultController ()<UIWebViewDelegate>
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) UIActivityIndicatorView *idctView;
@property (nonatomic, strong) WXScanResult *scanResult;
@end

@implementation WXShowResultController

- (instancetype)initWithResult:(WXScanResult *)scanResult {
    self = [super init];
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
        self.scanResult = scanResult;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    //判断二维码内容是否为网址
    NSString *regex = @"\\bhttps?://[a-zA-Z0-9\\-.]+(?::(\\d+))?(?:(?:/[a-zA-Z0-9\\-._?,'+\\&%$=~*!():@\\\\]*)+)?";
    NSRegularExpression *regular = [NSRegularExpression regularExpressionWithPattern:regex options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray *items = [regular matchesInString:_scanResult.strScanned options:NSMatchingReportProgress range:NSMakeRange(0, _scanResult.strScanned.length)];
    if (items.count > 0) {
        [self.view addSubview:self.webView];
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_scanResult.strScanned]]];
    }else{
        //显示内容
        self.navigationItem.title = _scanResult.strBarCodeType;
        self.view.backgroundColor = [UIColor colorWithRed:230/255.0 green:230/255.0 blue:230/255.0 alpha:1.0];
        UIImageView *imgView = [[UIImageView alloc] initWithImage:_scanResult.imgScanned];
        CGFloat ratio = 0.75;
        CGFloat width = imgView.image.size.width / [UIScreen mainScreen].scale * ratio;
        CGFloat height = imgView.image.size.height / [UIScreen mainScreen].scale * ratio;
        imgView.frame = CGRectMake(0, 0, width, height);
        imgView.center = self.view.center;
        [self.view addSubview:imgView];

        UILabel *codeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, 50)];
        codeLabel.font = [UIFont systemFontOfSize:22];
        codeLabel.textAlignment = NSTextAlignmentCenter;
        codeLabel.numberOfLines = 0;
        codeLabel.textColor = [UIColor orangeColor];
        codeLabel.text = _scanResult.strScanned;
        [codeLabel sizeToFit];
        codeLabel.center = CGPointMake(self.view.center.x, CGRectGetMinY(imgView.frame) - 80);
        [self.view addSubview:codeLabel];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIWebView *)webView {
    if (!_webView) {
        _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds)-64)];
        _webView.delegate = self;
        _idctView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_idctView];
    }
    return _webView;
}

#pragma mark -
- (void)webViewDidStartLoad:(UIWebView *)webView {
    [_idctView startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    self.navigationItem.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    [_idctView stopAnimating];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [_idctView stopAnimating];
}

@end
