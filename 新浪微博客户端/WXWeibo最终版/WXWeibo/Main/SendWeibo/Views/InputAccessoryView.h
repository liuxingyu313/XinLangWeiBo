//
//  InputAccessoryView.h
//  WXWeibo
//
//  Created by JayWon on 15/10/31.
//  Copyright (c) 2015年 JayWon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InputAccessoryView : UIView
@property (weak, nonatomic) IBOutlet UIView *locationBackView;
@property (weak, nonatomic) IBOutlet ThemeImgView *locationIconView;
@property (weak, nonatomic) IBOutlet ThemeLabel *locationLabel;
@property (weak, nonatomic) IBOutlet UIButton *clearButton;

@end
