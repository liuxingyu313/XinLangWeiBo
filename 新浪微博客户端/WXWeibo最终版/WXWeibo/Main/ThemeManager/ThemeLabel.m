//
//  ThemeLabel.m
//  WXWeibo
//
//  Created by JayWon on 15/10/21.
//  Copyright (c) 2015年 JayWon. All rights reserved.
//

#import "ThemeLabel.h"

@implementation ThemeLabel

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init
{
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupConfig];
    }
    return self;
}

-(void)awakeFromNib
{
    [self setupConfig];
}

-(void)setColorKeyName:(NSString *)colorKeyName
{
    if (_colorKeyName != colorKeyName) {
        _colorKeyName = [colorKeyName copy];
        
        [self themeDidChange];
    }
}

-(void)setupConfig
{
    self.backgroundColor = [UIColor clearColor];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(themeDidChange) name:kThemeDidChangeNotification object:nil];
}


-(void)themeDidChange
{
    self.textColor = [[ThemeManager shareManager] loadColorWithKeyName:_colorKeyName];
}

@end
