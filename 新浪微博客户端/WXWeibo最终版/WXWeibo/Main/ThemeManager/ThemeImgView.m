//
//  ThemeImgView.m
//  WXWeibo
//
//  Created by JayWon on 15/10/21.
//  Copyright (c) 2015年 JayWon. All rights reserved.
//

#import "ThemeImgView.h"

@implementation ThemeImgView

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

-(instancetype)initWithImage:(UIImage *)image
{
    self = [super initWithImage:image];
    if (self) {
        [self setupConfig];
    }
    
    return self;
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

-(void)setImgName:(NSString *)imgName
{
    if (_imgName != imgName) {
        _imgName = [imgName copy];
        
        [self themeDidChange];
    }
}

-(void)setupConfig
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(themeDidChange) name:kThemeDidChangeNotification object:nil];
}


-(void)themeDidChange
{
    UIImage *img = [[ThemeManager shareManager] loadImageWithImgName:_imgName];
    self.image = [img resizableImageWithCapInsets:self.edgeInset resizingMode:UIImageResizingModeStretch];
}


@end
