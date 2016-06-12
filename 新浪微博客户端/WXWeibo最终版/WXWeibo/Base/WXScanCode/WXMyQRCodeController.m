//
//  WXMyQRCodeController.m
//  QRCode
//
//  Created by JayWon on 15/12/15.
//  Copyright © 2015年 JayWon. All rights reserved.
//

#import "WXMyQRCodeController.h"

@interface WXMyQRCodeController ()
@property(nonatomic, weak)UIImageView *qrImgView;
@end

@implementation WXMyQRCodeController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.extendedLayoutIncludesOpaqueBars = YES;
    
    self.view.backgroundColor = [UIColor colorWithRed:230/255.0 green:230/255.0 blue:230/255.0 alpha:1.0];
    self.navigationItem.title = @"我的二维码";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareQRCode)];
    
    CGFloat x = CGRectGetWidth(self.view.frame)/8;
    CGFloat width = CGRectGetWidth(self.view.frame) - x*2;
    CGFloat height = width;// + 100;
    CGFloat y = (CGRectGetHeight(self.view.frame) - height + 64) / 2;
    
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, width, height)];
    [self.view addSubview:imgView];
    self.qrImgView = imgView;
    
    //加阴影
    self.qrImgView.layer.shadowOffset = CGSizeMake(0, 0);
    self.qrImgView.layer.shadowRadius = 2;
    self.qrImgView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.qrImgView.layer.shadowOpacity = 0.5;
    
    //生成二维码
    [self generateMyQRCode:@"http://www.bjwxhl.com/" QRSize:_qrImgView.frame.size];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 生成二维码
/**
 *  生成二维码
 *
 *  @param sourceStr 二维码源信息
 *  @param size      二维码大小
 */
- (void)generateMyQRCode:(NSString *)sourceStr QRSize:(CGSize)size {
    
    NSData *stringData = [sourceStr dataUsingEncoding: NSUTF8StringEncoding];
    
    //生成
    CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [qrFilter setValue:stringData forKey:@"inputMessage"];
    [qrFilter setValue:@"M" forKey:@"inputCorrectionLevel"];
    
    /*
    //上色（inputColor0 为二维码颜色，inputColor1 为背景颜色，这里把inputColor1上色clearColor在iOS8上有问题）
    CIFilter *colorFilter = [CIFilter filterWithName:@"CIFalseColor" keysAndValues:
                             @"inputImage",qrFilter.outputImage,
                             @"inputColor0",[CIColor colorWithCGColor:[UIColor colorWithRed:50/255.0 green:50/255.0 blue:50/255.0 alpha:1.0].CGColor],
                             //@"inputColor1",[CIColor colorWithCGColor:[UIColor clearColor].CGColor],
                             nil];
    */
    CIImage *qrImage = qrFilter.outputImage;
    
    //绘制
    CGImageRef cgImage = [[CIContext contextWithOptions:nil] createCGImage:qrImage fromRect:qrImage.extent];
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality(context, kCGInterpolationNone);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextDrawImage(context, CGContextGetClipBoundingBox(context), cgImage);
    UIImage *codeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    CGImageRelease(cgImage);
    
    //把 白底黑字二维码 转换成 透明底和指定颜色字的二维码（如不转换直接使用codeImage）
    self.qrImgView.image = [self imageBlackToTransparent:codeImage withRed:60.0f andGreen:74.0f andBlue:89.0f];
}

void ProviderReleaseData (void *info, const void *data, size_t size){
    free((void*)data);
}

//把 白底黑色二维码 转换成 透明底和指定颜色的二维码
- (UIImage*)imageBlackToTransparent:(UIImage*)image withRed:(CGFloat)red andGreen:(CGFloat)green andBlue:(CGFloat)blue{
    const int imageWidth = image.size.width;
    const int imageHeight = image.size.height;
    size_t      bytesPerRow = imageWidth * 4;
    uint32_t* rgbImageBuf = (uint32_t*)malloc(bytesPerRow * imageHeight);
    // create context
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(rgbImageBuf, imageWidth, imageHeight, 8, bytesPerRow, colorSpace,
                                                 kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
    CGContextDrawImage(context, CGRectMake(0, 0, imageWidth, imageHeight), image.CGImage);
    // traverse pixe
    int pixelNum = imageWidth * imageHeight;
    uint32_t* pCurPtr = rgbImageBuf;
    for (int i = 0; i < pixelNum; i++, pCurPtr++){
        if ((*pCurPtr & 0xFFFFFF00) < 0x99999900){
            // change color
            uint8_t* ptr = (uint8_t*)pCurPtr;
            ptr[3] = red; //0~255
            ptr[2] = green;
            ptr[1] = blue;
        }else{
            uint8_t* ptr = (uint8_t*)pCurPtr;
            ptr[0] = 0;
        }
    }
    // context to image
    CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL, rgbImageBuf, bytesPerRow * imageHeight, ProviderReleaseData);
    CGImageRef imageRef = CGImageCreate(imageWidth, imageHeight, 8, 32, bytesPerRow, colorSpace,
                                        kCGImageAlphaLast | kCGBitmapByteOrder32Little, dataProvider,
                                        NULL, true, kCGRenderingIntentDefault);
    CGDataProviderRelease(dataProvider);
    UIImage* resultUIImage = [UIImage imageWithCGImage:imageRef];
    // release
    CGImageRelease(imageRef);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    return resultUIImage;
}

#pragma mark - 分享
- (void)shareQRCode {
    UIActivityViewController *ctrl = [[UIActivityViewController alloc] initWithActivityItems:@[self.qrImgView.image] applicationActivities:nil];
    [self presentViewController:ctrl animated:YES completion:NULL];
    
    ctrl.completionHandler = ^(NSString *activityType, BOOL completed) {
        if ([activityType isEqualToString:UIActivityTypeSaveToCameraRoll] && completed) {
            NSLog(@"保存图片成功");
        }
    };
}

@end
