//
//  RightViewController.h
//  WXWeibo
//
//  Created by JayWon on 15/10/28.
//  Copyright (c) 2015年 JayWon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RightViewController : UIViewController

@property (retain, nonatomic) IBOutlet ThemeButton *writeBtn;
@property (retain, nonatomic) IBOutlet ThemeButton *cameraBtn;
@property (retain, nonatomic) IBOutlet ThemeButton *photoBtn;
@property (retain, nonatomic) IBOutlet ThemeButton *videoBtn;
@property (retain, nonatomic) IBOutlet ThemeButton *multPic;
@property (retain, nonatomic) IBOutlet ThemeButton *locationBtn;

- (IBAction)sendAction:(UIButton *)sender;

@end
