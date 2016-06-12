//
//  WXScanView.h
//  QRCode
//
//  Created by JayWon on 15/12/10.
//  Copyright © 2015年 JayWon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (ViewController)
-(UIViewController *)viewController;
@end

@interface WXScanView : UIView
- (void)startScan;
- (void)stopScan;
@end
