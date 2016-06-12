//
//  ViewController.m
//  AVCapureSession
//
//  Created by liuwei on 15/11/27.
//  Copyright (c) 2015年 wxhl. All rights reserved.
//

#import "QRCodeController.h"
#import "CameraView.h"
#import <AVFoundation/AVFoundation.h>
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

@interface QRCodeController ()<AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic,strong)UILabel *resultLable;
@property (nonatomic,strong)UIWebView *webView;
@property (nonatomic,strong)AVCaptureDeviceInput *input;
@property (nonatomic,strong)AVCaptureMetadataOutput *ouput;
@property (nonatomic, strong) UIButton *cancelBtn;

@end

@implementation QRCodeController{
    AVCaptureSession *session;
    AVCaptureVideoPreviewLayer *layer;
    CameraView *cameraView;
}
- (UILabel *)resultLable{
    
    if (_resultLable == nil) {
        
        _resultLable = [[UILabel alloc] initWithFrame:CGRectZero];
        _resultLable.frame = CGRectMake(30, 60, kScreenWidth - 2 * 30, 30);
        _resultLable.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:_resultLable];
    }
    return _resultLable;
}
- (UIWebView *)webView{
    
    if (_webView == nil) {
        
        _webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
        [self.view addSubview:_webView];
    }
    return _webView;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //1.初始化组件
    [self setupAVComponents];
    //2.创建视图
    [self createViews];
    //3.扫描
    [self scanf];
}

//设置输入输入流
- (void)setupAVComponents{

    //获取摄像设备
    AVCaptureDevice * device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (!device){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"无可用相机" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil, nil];
        [alertView show];
        return;
    };
    //创建输入流
     _input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    //创建输出流
    _ouput = [[AVCaptureMetadataOutput alloc]init];
    //设置代理 在主线程里刷新
    [_ouput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    //初始化链接对象
    session = [[AVCaptureSession alloc]init];
    //高质量采集率
    [session setSessionPreset:AVCaptureSessionPresetHigh];
    
    [session addInput:_input];
    [session addOutput:_ouput];
    //设置扫码支持的编码格式(如下设置条形码和二维码兼容)
    _ouput.metadataObjectTypes=@[AVMetadataObjectTypeQRCode,AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code];
}
//创建视图
- (void)createViews{

    layer = [AVCaptureVideoPreviewLayer layerWithSession:session];
    layer.videoGravity=AVLayerVideoGravityResizeAspectFill;
    layer.frame=self.view.layer.bounds;
    [self.view.layer addSublayer:layer];
    
    //相机界面
    cameraView = [[CameraView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:cameraView];
    
    //关闭按钮
    _cancelBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    _cancelBtn.frame = CGRectMake((kScreenWidth - 80) / 2,CGRectGetMaxY(cameraView.scanRect) + 50, 80, 30);
    _cancelBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [_cancelBtn setTitle:@"关闭" forState:UIControlStateNormal];
    [_cancelBtn addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_cancelBtn];

}
//开始扫描
- (void)scanf{
    
    CGFloat width = cameraView.scanRect.size.width;
    CGFloat height = cameraView.scanRect.size.height;
    CGFloat x = cameraView.scanRect.origin.x;
    CGFloat y = cameraView.scanRect.origin.y;
    // (默认全屏幕扫描)扫描区域（y的起点/屏幕的高，x的起点/屏幕的宽，扫描的区域的高/屏幕的高，扫描的区域的宽/屏幕的宽）提高扫描速度
    _ouput.rectOfInterest=CGRectMake(y / kScreenHeight,x / kScreenWidth,height / kScreenHeight,width / kScreenWidth);
    //开始捕获
    [session startRunning];
}

- (void)cancelAction{
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark -AVCaptureOutputDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    
    if (metadataObjects.count>0) {
        [session stopRunning];
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex : 0 ];
        [self showMsg:metadataObject.stringValue];
    }
}
//显示扫描结果
- (void)showMsg:(NSString *)result{

    [cameraView removeFromSuperview];
    [layer removeFromSuperlayer];
    
    //匹配 url
    NSString *regex = @"\\bhttps?://[a-zA-Z0-9\\-.]+(?::(\\d+))?(?:(?:/[a-zA-Z0-9\\-._?,'+\\&%$=~*!():@\\\\]*)+)?";
    NSRegularExpression *regular = [NSRegularExpression regularExpressionWithPattern:regex options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray *items = [regular matchesInString:result options:NSMatchingReportProgress range:NSMakeRange(0, result.length)];
    if (items.count > 0) {
        //加载网页
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:result]]];
    }else{
        //显示内容
        self.resultLable.text = result;
    }
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        
        [self dismissViewControllerAnimated:YES completion:NULL];
    }
}
@end
