//
//  DiscoverViewController.h
//  WXWeibo
//
//  Created by JayWon on 15/10/20.
//  Copyright (c) 2015年 JayWon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RootViewController.h"

@interface DiscoverViewController : RootViewController

@property (weak, nonatomic) IBOutlet UIButton *nearWeiboBtn;
@property (weak, nonatomic) IBOutlet UIButton *nearUserBtn;
@property (weak, nonatomic) IBOutlet ThemeLabel *nearWeiboLabel;
@property (weak, nonatomic) IBOutlet ThemeLabel *nearUserLabel;

@end
