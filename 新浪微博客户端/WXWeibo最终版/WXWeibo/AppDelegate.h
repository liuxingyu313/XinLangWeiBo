//
//  AppDelegate.h
//  WXWeibo
//
//  Created by JayWon on 15/10/20.
//  Copyright (c) 2015年 JayWon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMDrawerController.h"
#import "SinaWeibo.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property(nonatomic, strong)MMDrawerController *drawerCtrl;
@property(nonatomic, strong)SinaWeibo *sinaWeibo;


- (void)storeAuthData;
- (void)removeAuthData;

@end

