//
//  AppDelegate.m
//  WXWeibo
//
//  Created by JayWon on 15/10/20.
//  Copyright (c) 2015年 JayWon. All rights reserved.
//

#import "AppDelegate.h"
#import "RootTabBarController.h"
#import "MMExampleDrawerVisualStateManager.h"

@interface AppDelegate () <SinaWeiboDelegate>

@end

@implementation AppDelegate

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)themeDidChange
{
    UIImage *img = [[ThemeManager shareManager] loadImageWithImgName:@"mask_bg.jpg"];
    self.window.backgroundColor = [UIColor colorWithPatternImage:img];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [self setupSinaWeibo];
    
    UIStoryboard *leftStbd = [UIStoryboard storyboardWithName:@"Left" bundle:nil];
    UIStoryboard *rightStbd = [UIStoryboard storyboardWithName:@"Right" bundle:nil];
    UINavigationController *leftNavCtrl = [leftStbd instantiateInitialViewController];
    UINavigationController *rightNavCtrl = [rightStbd instantiateInitialViewController];
    
    RootTabBarController *tabbarCtrl = [[RootTabBarController alloc] init];
    self.drawerCtrl = [[MMDrawerController alloc]
                       initWithCenterViewController:tabbarCtrl
                       leftDrawerViewController:leftNavCtrl
                       rightDrawerViewController:rightNavCtrl];
    
    //设置左右viewCtrl的宽度
    [self.drawerCtrl setMaximumLeftDrawerWidth:200];
    [self.drawerCtrl setMaximumRightDrawerWidth:80];
    
    //设置手势操作的区域
    [self.drawerCtrl setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeAll];
    [self.drawerCtrl setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeAll];
    
    self.drawerCtrl.view.backgroundColor = [UIColor clearColor];
    
    //配置管理动画的block
    [self.drawerCtrl
     setDrawerVisualStateBlock:^(MMDrawerController *drawerController, MMDrawerSide drawerSide, CGFloat percentVisible) {
         MMDrawerControllerDrawerVisualStateBlock block;
         block = [[MMExampleDrawerVisualStateManager sharedManager]
                  drawerVisualStateBlockForDrawerSide:drawerSide];
         if(block){
             block(drawerController, drawerSide, percentVisible);
         }
     }];
    
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self themeDidChange];
    self.window.rootViewController = self.drawerCtrl;
    [self.window makeKeyAndVisible];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(themeDidChange) name:kThemeDidChangeNotification object:nil];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    [self.sinaWeibo applicationDidBecomeActive];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return [self.sinaWeibo handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [self.sinaWeibo handleOpenURL:url];
}

#pragma mark - SinaWeibo
-(void)setupSinaWeibo
{
    self.sinaWeibo = [[SinaWeibo alloc] initWithAppKey:kAppKey appSecret:kAppSecret appRedirectURI:kAppRedirectURI andDelegate:self];
    
    //读取认证信息
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *sinaweiboInfo = [defaults objectForKey:@"SinaWeiboAuthData"];
    if ([sinaweiboInfo objectForKey:@"AccessTokenKey"] && [sinaweiboInfo objectForKey:@"ExpirationDateKey"] && [sinaweiboInfo objectForKey:@"UserIDKey"])
    {
        _sinaWeibo.accessToken = [sinaweiboInfo objectForKey:@"AccessTokenKey"];
        _sinaWeibo.expirationDate = [sinaweiboInfo objectForKey:@"ExpirationDateKey"];
        _sinaWeibo.userID = [sinaweiboInfo objectForKey:@"UserIDKey"];
    }
}

- (void)removeAuthData
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"SinaWeiboAuthData"];
}

- (void)storeAuthData
{
    NSDictionary *authData = [NSDictionary dictionaryWithObjectsAndKeys:
                              _sinaWeibo.accessToken, @"AccessTokenKey",
                              _sinaWeibo.expirationDate, @"ExpirationDateKey",
                              _sinaWeibo.userID, @"UserIDKey",
                              _sinaWeibo.refreshToken, @"refresh_token", nil];
    [[NSUserDefaults standardUserDefaults] setObject:authData forKey:@"SinaWeiboAuthData"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
