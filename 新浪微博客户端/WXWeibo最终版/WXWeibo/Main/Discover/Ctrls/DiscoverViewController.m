//
//  DiscoverViewController.m
//  WXWeibo
//
//  Created by JayWon on 15/10/20.
//  Copyright (c) 2015年 JayWon. All rights reserved.
//

#import "DiscoverViewController.h"

@interface DiscoverViewController ()

@end

@implementation DiscoverViewController

-(instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(themeDidChange) name:kThemeDidChangeNotification object:nil];
    }
    return self;
}

-(void)themeDidChange
{
    self.view.backgroundColor = [[ThemeManager shareManager] loadColorWithKeyName:@"More_Item_color"];
    self.nearWeiboLabel.colorKeyName = @"More_Item_Text_color";
    self.nearUserLabel.colorKeyName = @"More_Item_Text_color";
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self themeDidChange];
    
    [self resetButtonShadow:_nearUserBtn];
    [self resetButtonShadow:_nearWeiboBtn];
}

-(void)resetButtonShadow:(UIButton *)btn
{
    btn.layer.shadowColor = [UIColor blackColor].CGColor;
    btn.layer.shadowRadius = 5;
    btn.layer.shadowOffset = CGSizeMake(0, 0);
    btn.layer.shadowOpacity = 0.5;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
