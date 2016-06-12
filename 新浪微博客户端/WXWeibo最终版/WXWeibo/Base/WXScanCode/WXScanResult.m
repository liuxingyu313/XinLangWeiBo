//
//  WXScanResult.m
//  QRCode
//
//  Created by JayWon on 15/12/14.
//  Copyright © 2015年 JayWon. All rights reserved.
//

#import "WXScanResult.h"

@implementation WXScanResult

- (instancetype)initWithScanString:(NSString*)str imgScan:(UIImage*)img barCodeType:(NSString*)type {
    if (self = [super init]) {
        self.strScanned = str;
        self.imgScanned = img;
        self.strBarCodeType = type;
    }
    return self;
}

@end
