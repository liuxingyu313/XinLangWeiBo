//
//  RootViewController.m
//  WXWeibo
//
//  Created by JayWon on 15/10/23.
//  Copyright (c) 2015年 JayWon. All rights reserved.
//

#import "RootViewController.h"

@interface RootViewController () 

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self createBackButton];
}

-(void)createBackButton
{
    //返回
    NSUInteger count = self.navigationController.viewControllers.count;
    if (count > 1) {
        ThemeButton *button = [[ThemeButton alloc] initWithFrame:CGRectMake(0, 0, 60, 44)];
        button.backImgName = @"titlebar_button_back_9@2x.png";
        [button setTitle:@"返回" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:button];
        self.navigationItem.leftBarButtonItem = backItem;
    }
}

-(void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSUInteger count = self.navigationController.viewControllers.count;
    if (count > 1) {
        //禁止滑动
        [[self appDelegate].drawerCtrl setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeNone];
    }else{
        [[self appDelegate].drawerCtrl setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeAll];
    }
}

-(AppDelegate *)appDelegate
{
    return [[UIApplication sharedApplication] delegate];
}

@end
