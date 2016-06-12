//
//  ThemeTableView.m
//  WXWeibo
//
//  Created by JayWon on 15/10/30.
//  Copyright (c) 2015年 JayWon. All rights reserved.
//

#import "ThemeTableView.h"

@implementation ThemeTableView

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

-(void)themeDidChange
{
    self.backgroundColor = [[ThemeManager shareManager] loadColorWithKeyName:@"More_Item_color"];
    self.separatorColor = [[ThemeManager shareManager] loadColorWithKeyName:@"More_Item_Line_color"];
}

-(instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];
    if (self) {
        [self setupConfig];
    }
    
    return self;
}

-(void)awakeFromNib
{
    [self setupConfig];
}

-(void)setupConfig
{
    [self themeDidChange];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(themeDidChange) name:kThemeDidChangeNotification object:nil];
}

@end
