//
//  WXScanResult.h
//  QRCode
//
//  Created by JayWon on 15/12/14.
//  Copyright © 2015年 JayWon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface WXScanResult : NSObject

- (instancetype)initWithScanString:(NSString*)str imgScan:(UIImage*)img barCodeType:(NSString*)type;

@property (nonatomic, copy)NSString* strScanned;        //扫码字符串
@property (nonatomic, copy)NSString* strBarCodeType;    //扫码类型
@property (nonatomic, strong)UIImage* imgScanned;       //扫码图像

@end
