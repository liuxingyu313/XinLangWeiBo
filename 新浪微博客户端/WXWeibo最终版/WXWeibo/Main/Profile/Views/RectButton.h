//
//  RectButton.h
//  WXWeibo
//
//  Created by JayWon on 15/11/2.
//  Copyright (c) 2015年 JayWon. All rights reserved.
//

#import "ThemeButton.h"

@interface RectButton : ThemeButton
{
    UILabel *_rectTitleLabel;
    UILabel *_subTitleLabel;
}

@property(nonatomic, copy)NSString *title;
@property(nonatomic, copy)NSString *subTitle;

@end
