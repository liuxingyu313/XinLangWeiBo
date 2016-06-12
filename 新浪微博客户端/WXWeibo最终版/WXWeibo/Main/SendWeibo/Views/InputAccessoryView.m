//
//  InputAccessoryView.m
//  WXWeibo
//
//  Created by JayWon on 15/10/31.
//  Copyright (c) 2015年 JayWon. All rights reserved.
//

#import "InputAccessoryView.h"

@implementation InputAccessoryView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)awakeFromNib
{
    _locationIconView.imgName = @"compose_toolbar_5@2x.png";
    _locationLabel.colorKeyName = @"More_Item_Text_color";
}

@end
