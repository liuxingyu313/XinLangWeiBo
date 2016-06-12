//
//  WXScanViewController.m
//  QRCode
//
//  Created by JayWon on 15/12/15.
//  Copyright © 2015年 JayWon. All rights reserved.
//

#import "WXScanViewController.h"
#import "WXScanView.h"

@interface WXScanViewController ()
@property (nonatomic, strong)WXScanView *qrScanView;
@property (nonatomic, strong)UILabel *promptLabel;
@end

@implementation WXScanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //延伸布局包含不透明的bar
    self.extendedLayoutIncludesOpaqueBars = YES;
    
    self.navigationItem.title = @"二维码/条码";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemReply target:self action:@selector(_backAction:)];
    self.view.backgroundColor = [UIColor grayColor];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.view bringSubviewToFront:self.promptLabel];
    self.promptLabel.alpha = 1;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.promptLabel.alpha = 0;
    [self.qrScanView startScan];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.qrScanView stopScan];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - 私有方法
- (void)_backAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (WXScanView *)qrScanView {
    if (!_qrScanView) {
        _qrScanView = [[WXScanView alloc] initWithFrame:self.view.bounds];
        [self.view addSubview:_qrScanView];
    }
    return _qrScanView;
}

- (UILabel *)promptLabel {
    if (!_promptLabel) {
        _promptLabel = [[UILabel alloc] init];
        _promptLabel.font = [UIFont boldSystemFontOfSize:15];
        _promptLabel.textAlignment = NSTextAlignmentCenter;
        _promptLabel.numberOfLines = 0;
        _promptLabel.textColor = [UIColor yellowColor];
        _promptLabel.text = @"📷 启动中...";
        [_promptLabel sizeToFit];
        _promptLabel.center = self.view.center;
        [self.view addSubview:_promptLabel];
    }
    return _promptLabel;
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
