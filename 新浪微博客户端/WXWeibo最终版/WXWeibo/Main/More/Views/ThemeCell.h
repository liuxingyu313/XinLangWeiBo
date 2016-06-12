//
//  ThemeCell.h
//  WXWeibo
//
//  Created by JayWon on 15/10/21.
//  Copyright (c) 2015年 JayWon. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kThemeViewCtrlID    @"kThemeViewCtrlID"

@interface ThemeCell : UITableViewCell

@property (weak, nonatomic) IBOutlet ThemeImgView *headImgView;
@property (weak, nonatomic) IBOutlet ThemeLabel *themeNameLabel;

@end
