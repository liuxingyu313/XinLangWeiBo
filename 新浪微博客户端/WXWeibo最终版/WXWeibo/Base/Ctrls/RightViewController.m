//
//  RightViewController.m
//  WXWeibo
//
//  Created by JayWon on 15/10/28.
//  Copyright (c) 2015年 JayWon. All rights reserved.
//

#import "RightViewController.h"
#import "SendViewController.h"
#import "RootNavigationController.h"
#import "QRCodeController.h"
#import "WXScanViewController.h"

@interface RightViewController ()

@end

@implementation RightViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _writeBtn.imgName =     @"newbar_icon_1@2x.png";
    _cameraBtn.imgName =    @"newbar_icon_2@2x.png";
    _photoBtn.imgName =     @"newbar_icon_3@2x.png";
    _videoBtn.imgName =     @"newbar_icon_2@2x.png";
    _multPic.imgName =      @"newbar_icon_4@2x.png";
    _locationBtn.imgName =  @"newbar_icon_5@2x.png";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)sendAction:(UIButton *)sender {
    switch (sender.tag) {
        case 200:
        {
            SendViewController *sendViewCtrl = [[SendViewController alloc] init];
            RootNavigationController *navCtrl = [[RootNavigationController alloc] initWithRootViewController:sendViewCtrl];
            [self presentViewController:navCtrl animated:YES completion:NULL];
        }
            break;
        case 201:
            
            break;
        case 202:
            
            break;
        case 203:
            
            break;
        case 204:
            
            break;
        case 205:
            
            break;
        case 206:
            
            break;
        case 207:
        {
            //[self presentViewController:[[QRCodeController alloc] init] animated:YES completion:NULL];
            
            WXScanViewController *qtCtrl = [[WXScanViewController alloc] init];
            RootNavigationController *navCtrl = [[RootNavigationController alloc] initWithRootViewController:qtCtrl];
            navCtrl.navigationBar.tintColor = [UIColor whiteColor];
            [self presentViewController:navCtrl animated:YES completion:NULL];
            break;
        }
        default:
            break;
    }
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
