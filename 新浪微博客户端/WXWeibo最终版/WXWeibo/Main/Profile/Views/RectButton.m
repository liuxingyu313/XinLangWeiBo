//
//  RectButton.m
//  WXWeibo
//
//  Created by JayWon on 15/11/2.
//  Copyright (c) 2015年 JayWon. All rights reserved.
//

#import "RectButton.h"

@implementation RectButton

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)setTitle:(NSString *)title
{
    if (_title != title) {
        _title = [title copy];
    
        if (!_rectTitleLabel) {
            [self setTitle:nil forState:UIControlStateNormal];
            
            _rectTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            _rectTitleLabel.backgroundColor = [UIColor clearColor];
            _rectTitleLabel.font = [UIFont systemFontOfSize:14];
            _rectTitleLabel.textColor = [UIColor colorWithRed:50.0/255 green:80.0/255 blue:135.0/255 alpha:1];
            _rectTitleLabel.textAlignment = NSTextAlignmentCenter;
            [self addSubview:_rectTitleLabel];
        }
        
        _rectTitleLabel.text = _title;
    }
}

-(void)setSubTitle:(NSString *)subTitle
{
    if (_subTitle != subTitle) {
        _subTitle = [subTitle copy];
    
        if (!_subTitleLabel) {
            [self setTitle:nil forState:UIControlStateNormal];
            
            _subTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            _subTitleLabel.backgroundColor = [UIColor clearColor];
            _subTitleLabel.font = [UIFont systemFontOfSize:14];
            _subTitleLabel.textColor = [UIColor orangeColor];
            _subTitleLabel.textAlignment = NSTextAlignmentCenter;
            [self addSubview:_subTitleLabel];
        }
        
        _subTitleLabel.text = _subTitle;
    }
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    _subTitleLabel.frame = CGRectMake(0, 15, CGRectGetWidth(self.frame), 21);
    _rectTitleLabel.frame = CGRectMake(0, CGRectGetMaxY(_subTitleLabel.frame), CGRectGetWidth(self.frame), 21);
}

@end
