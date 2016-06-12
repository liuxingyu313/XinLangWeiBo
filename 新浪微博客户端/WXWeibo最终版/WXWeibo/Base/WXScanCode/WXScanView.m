//
//  WXScanView.m
//  QRCode
//
//  Created by JayWon on 15/12/10.
//  Copyright © 2015年 JayWon. All rights reserved.
//

#import "WXScanView.h"
#import "WXScanResult.h"
#import <AVFoundation/AVFoundation.h>
#import "WXScanGridView.h"
#import "WXShowResultController.h"
#import "WXMyQRCodeController.h"

@implementation UIView (ViewController)
- (UIViewController *)viewController {
    UIResponder *next = self.nextResponder;
    while (next != nil) {
        if ([next isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)next;
        }
        next = next.nextResponder;
    }
    return nil;
}
@end


@interface WXScanView () <UINavigationControllerDelegate, UIImagePickerControllerDelegate, AVCaptureMetadataOutputObjectsDelegate>
@property (nonatomic, strong)AVCaptureDeviceInput *deviceInput;     //相机输入源（手电筒功能、扫描照片）
@property (nonatomic, strong)AVCaptureMetadataOutput *deviceOuput;  //数据输出源（扫描结果）
@property (nonatomic, strong)AVCaptureSession *session;             //会话总管，管理输入(AVCaptureInput)和输出(AVCaptureOutput)流
@property (nonatomic, weak)AVCaptureVideoPreviewLayer *avLayer;     //显示会话（session）
@property (nonatomic, weak)WXScanGridView *gridView;                //扫描透明层
@property (nonatomic, weak)UIButton *flashBtn;                      //手电筒开关
@end

@implementation WXScanView

- (instancetype)init
{
    return [self initWithFrame:[UIScreen mainScreen].bounds];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _initUI];
    }
    return self;
}

- (void)awakeFromNib {
    [self _initUI];
}

#pragma mark - AVCaptureDeviceInput
- (AVCaptureDeviceInput *)deviceInput {
    if (!_deviceInput) {
        //相机硬件的接口，用于控制硬件特性：镜头的位置、曝光、闪光灯等
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        if (!device) {
            NSLog(@"无可用相机");
            return nil;
        }
        //自动对焦设置
        if (device.isFocusPointOfInterestSupported && [device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
            [device lockForConfiguration:nil];
            [device setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
            [device unlockForConfiguration];
        }
        _deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
        if (!_deviceInput) {
            NSLog(@"您已关闭相机使用权限，请至手机 设置->隐私->相机 中打开");
            return nil;
        }
    }
    return _deviceInput;
}

#pragma mark - 启动
- (void)startScan {
    
    [_gridView startAnimation];
    
    if (!_session.isRunning) {
        [_session startRunning];
    }
}

- (void)stopScan {
    
    [_gridView stopAnimation];
    
    //关闭手电筒
    if(_deviceInput.device.torchMode == AVCaptureTorchModeOn) {
        [self _openOrCloseFlash];
    }
    
    //关闭会话
    if (_session.isRunning)
        [_session stopRunning];
}

#pragma mark -
- (void)_initUI {
    
    //层级关系由下至上依次为：相机 - 半透明层 - 触摸区或提示区
    
    [self _initAVComponents];   //1.相机层
    [self _initScanView];       //2.半透明层
    [self _initTipLabel];       //3.提示语
    [self _initBottomBar];      //4.功能按钮
}

- (void)_initAVComponents {
    if (!self.deviceInput) return;
    
    //1.创建输出流
    AVCaptureMetadataOutput *deviceOuput = [[AVCaptureMetadataOutput alloc] init];
    self.deviceOuput = deviceOuput;
    //设置代理 在主线程里刷新
    [_deviceOuput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    //设置扫描区域（取值是一个比率值），默认全屏幕扫描
    //_deviceOuput.rectOfInterest = CGRectMake(0, 0, 1, 1);

    //2.创建相机
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    self.session = session;
    //预置画面采集质量（高质量音频视频输出）
    if ([_session canSetSessionPreset:AVCaptureSessionPresetHigh]) {
        [_session setSessionPreset:AVCaptureSessionPresetHigh];
    }
    if ([_session canAddInput:self.deviceInput]) {
        [_session addInput:self.deviceInput];
    }
    if ([_session canAddOutput:_deviceOuput]) {
        [_session addOutput:_deviceOuput];
    }
    
    //3.设置支持的扫码格式（坑：需要_deviceOuput被添加到AVCaptureSession后，才能设置metadataObjectTypes）
    //手动设置格式
    //_deviceOuput.metadataObjectTypes = [self defaultMetaDataObjectTypes];
    //系统判断可用的格式
    _deviceOuput.metadataObjectTypes = [_deviceOuput availableMetadataObjectTypes];
    
    //4.相机显示
    AVCaptureVideoPreviewLayer *layer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    layer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    layer.frame = self.layer.bounds;
    [self.layer insertSublayer:layer atIndex:0];
    self.avLayer = layer;
}

//半透明层
- (void)_initScanView {
    WXScanGridView *gridView = [[WXScanGridView alloc] initWithFrame:self.bounds];
    [self addSubview:gridView];
    self.gridView = gridView;
}

- (void)_initTipLabel {
    UILabel *topTitle = [[UILabel alloc] init];
    topTitle.font = [UIFont systemFontOfSize:15];
    topTitle.textAlignment = NSTextAlignmentCenter;
    topTitle.numberOfLines = 0;
    topTitle.text = @"万能扫码 - 📷对准扫描框";
    topTitle.textColor = [UIColor whiteColor];
    [topTitle sizeToFit];
    topTitle.center = CGPointMake(CGRectGetWidth(self.frame)/2, CGRectGetHeight(self.frame)*0.22);
    [self addSubview:topTitle];
}

//相册、开灯、我的二维码
- (void)_initBottomBar {
    CGFloat barHeight = 100.0;
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.frame)-barHeight, CGRectGetWidth(self.frame), barHeight)];
    bottomView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
    [self addSubview:bottomView];

    CGFloat btnWidth = 65;
    CGFloat btnHeight = 87;
    CGFloat btnSpace = (CGRectGetWidth(bottomView.frame)- btnWidth*3) / 4;
    
    UIButton *photoBtn = [[UIButton alloc] initWithFrame:CGRectMake(btnSpace, (barHeight-btnHeight)/2, btnWidth, btnHeight)];
    [photoBtn setImage:[UIImage imageNamed:@"CodeScan.bundle/qrcode_scan_btn_photo_nor"] forState:UIControlStateNormal];
    [photoBtn setImage:[UIImage imageNamed:@"CodeScan.bundle/qrcode_scan_btn_photo_down"] forState:UIControlStateHighlighted];
    [photoBtn addTarget:self action:@selector(_openPhoto) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *flashBtn = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(photoBtn.frame)+btnSpace, (barHeight-btnHeight)/2, btnWidth, btnHeight)];
    [flashBtn setImage:[UIImage imageNamed:@"CodeScan.bundle/qrcode_scan_btn_flash_nor"] forState:UIControlStateNormal];
    [flashBtn addTarget:self action:@selector(_openOrCloseFlash) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *myQRBtn = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(flashBtn.frame)+btnSpace, (barHeight-btnHeight)/2, btnWidth, btnHeight)];
    [myQRBtn setImage:[UIImage imageNamed:@"CodeScan.bundle/qrcode_scan_btn_myqrcode_nor"] forState:UIControlStateNormal];
    [myQRBtn setImage:[UIImage imageNamed:@"CodeScan.bundle/qrcode_scan_btn_myqrcode_down"] forState:UIControlStateHighlighted];
    [myQRBtn addTarget:self action:@selector(_myQRCode) forControlEvents:UIControlEventTouchUpInside];
    
    [bottomView addSubview:flashBtn];
    [bottomView addSubview:photoBtn];
    [bottomView addSubview:myQRBtn];
    
    self.flashBtn = flashBtn;
}

- (NSArray *)defaultMetaDataObjectTypes {
    NSMutableArray *types = [@[AVMetadataObjectTypeQRCode,
                               AVMetadataObjectTypeUPCECode,
                               AVMetadataObjectTypeCode39Code,
                               AVMetadataObjectTypeCode39Mod43Code,
                               AVMetadataObjectTypeEAN13Code,
                               AVMetadataObjectTypeEAN8Code,
                               AVMetadataObjectTypeCode93Code,
                               AVMetadataObjectTypeCode128Code,
                               AVMetadataObjectTypePDF417Code,
                               AVMetadataObjectTypeAztecCode] mutableCopy];
    
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        [types addObjectsFromArray:@[
                                     AVMetadataObjectTypeInterleaved2of5Code,
                                     AVMetadataObjectTypeITF14Code,
                                     AVMetadataObjectTypeDataMatrixCode
                                     ]];
    }
    return types;
}

#pragma mark - 底部功能
//打开相册二维码
- (void)_openPhoto{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    picker.allowsEditing = YES;
    [self.viewController presentViewController:picker animated:YES completion:nil];
}

//手电筒
- (void)_openOrCloseFlash{
    if (!self.deviceInput) return;
    
    [self.deviceInput.device lockForConfiguration:nil];
    _deviceInput.device.torchMode = (_deviceInput.device.torchMode == AVCaptureTorchModeOn) ? AVCaptureTorchModeOff : AVCaptureTorchModeOn;
    [_deviceInput.device unlockForConfiguration];
    
    (_deviceInput.device.torchMode == AVCaptureTorchModeOn) ? [_flashBtn setImage:[UIImage imageNamed:@"CodeScan.bundle/qrcode_scan_btn_flash_down"] forState:UIControlStateNormal] : [_flashBtn setImage:[UIImage imageNamed:@"CodeScan.bundle/qrcode_scan_btn_flash_nor"] forState:UIControlStateNormal];
}

//生成自己的二维码
- (void)_myQRCode{
    WXMyQRCodeController *myQRCodeCtrl = [[WXMyQRCodeController alloc] init];
    [self.viewController.navigationController pushViewController:myQRCodeCtrl animated:YES];
}

#pragma mark -
- (void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage* image = [info objectForKey:UIImagePickerControllerEditedImage];
    if (!image){
        image = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
    [picker dismissViewControllerAnimated:YES completion:nil];

    //识别图片二维码。iOS8之后可使用系统接口，但此api有问题，在iPhone 4s、5、5s(iOS<9) 上detector为nil
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        CIContext *context = [CIContext contextWithOptions:nil];
        CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:context options:@{CIDetectorAccuracy : CIDetectorAccuracyHigh}];
        if (detector) {
        NSArray *features = [detector featuresInImage:[CIImage imageWithCGImage:image.CGImage]];
        if (features.count == 0) {
            NSLog(@"图片中无二维码");
            return;
        }
        
        CIQRCodeFeature *feature = [features firstObject];
        WXScanResult *result = [[WXScanResult alloc] init];
        result.strScanned = feature.messageString;
        result.strBarCodeType = feature.type;
        result.imgScanned = image;
        WXShowResultController *resultCtrl = [[WXShowResultController alloc] initWithResult:result];
        [self.viewController.navigationController pushViewController:resultCtrl animated:YES];
        }
    } else {
        //TODO:iOS7之前使用ZBar识别
        /*
         ZBar 在扫描灵敏度和内存使用上比ZXing优秀，但是02年之后就停止更新，不支持64位处理器（到目前位置还能用）
         ZXing 在灵敏度、识别率、识别效率方面不如ZBar，但是一直有人在维护
         */
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - AVCaptureOutputDelegate 获取扫描结果
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    
    if (metadataObjects.count == 0) {
        return;
    }
    
    AVMetadataObject *metadataObj = [metadataObjects firstObject];
    if ([metadataObj isKindOfClass:[AVMetadataMachineReadableCodeObject class]]) {
        
        [self stopScan];
        
        //1012-iphone  1152-ipad  1109-ipad
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);   //振动提醒
        AudioServicesPlaySystemSound(1109);                     //声音提醒
        
        WXScanResult *result = [[WXScanResult alloc] init];
        result.strScanned = [(AVMetadataMachineReadableCodeObject *)metadataObj stringValue];
        result.strBarCodeType = metadataObj.type;
        WXShowResultController *resultCtrl = [[WXShowResultController alloc] initWithResult:result];
        [self.viewController.navigationController pushViewController:resultCtrl animated:YES];
    }
}

@end
