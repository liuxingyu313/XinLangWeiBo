//
//  ThemeCell.m
//  WXWeibo
//
//  Created by JayWon on 15/10/21.
//  Copyright (c) 2015年 JayWon. All rights reserved.
//

#import "ThemeCell.h"

@implementation ThemeCell

-(void)awakeFromNib
{
    self.themeNameLabel.colorKeyName = @"More_Item_Text_color";
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
