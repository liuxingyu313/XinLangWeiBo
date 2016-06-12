//
//  RootTabBarController.m
//  WXWeibo
//
//  Created by JayWon on 15/10/20.
//  Copyright (c) 2015年 JayWon. All rights reserved.
//

#import "RootTabBarController.h"
#import "AppDelegate.h"

#define kBadgeViewSize 32

@interface RootTabBarController ()
{
    ThemeImgView *selectItem;
    ThemeImgView *badgeView;
}

@end

@implementation RootTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    // Do any additional setup after loading the view.
    
    //1、创建viewCtrls
    [self createViewCtrls];
    
    //2、自定义uitabbar
    [self customTabBar];
    
    [self loadUnReadWeibo];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//如果RootTabBarController是通过storyboard加载的,那么移除的动作需要放在这个方法里面
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //移除系统tabbar自带的item
    [self removeUITabBarButton];
}

-(void)createViewCtrls
{
    NSArray *storyboardNames = @[@"Home", @"Message", @"Profile", @"Discover", @"More"];
    NSMutableArray *viewCtrls = [NSMutableArray arrayWithCapacity:storyboardNames.count];
    for (int i = 0; i < storyboardNames.count; i++) {
        NSString *stbdName = storyboardNames[i];
        UIStoryboard *stbd = [UIStoryboard storyboardWithName:stbdName bundle:nil];
        UIViewController *viewCtrl = [stbd instantiateInitialViewController];
        [viewCtrls addObject:viewCtrl];
    }
    
    self.viewControllers = viewCtrls;
}

-(void)customTabBar
{
    float itemWidth = kScreenWidth / 5;
    
    ThemeImgView *tabBarBG = [[ThemeImgView alloc] initWithFrame:CGRectMake(0, -6, kScreenWidth, 55)];
    tabBarBG.imgName = @"mask_navbar@2x.png";
    //tabBarBG.userInteractionEnabled = YES;
    [self.tabBar addSubview:tabBarBG];
    
    //选中的样式
    selectItem = [[ThemeImgView alloc] initWithFrame:CGRectMake(0, 2, itemWidth, 45)];
    selectItem.imgName = @"home_bottom_tab_arrow@2x.png";
    [self.tabBar addSubview:selectItem];
    
    
    //tabbar按钮
    NSArray *imgArr = @[
                        @"home_tab_icon_1@2x.png",
                        @"home_tab_icon_2@2x.png",
                        @"home_tab_icon_3@2x.png",
                        @"home_tab_icon_4@2x.png",
                        @"home_tab_icon_5@2x.png",
                        ];
    
    for (int i=0; i<imgArr.count; i++) {
        NSString *imgName = imgArr[i];
        
        ThemeButton *button = [[ThemeButton alloc] initWithFrame:CGRectMake(i*itemWidth, 2, itemWidth, 45)];
        button.imgName = imgName;
        [button addTarget:self action:@selector(selectTab:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = 1000 + i;
        [self.tabBar addSubview:button];
    }
    
}

-(void)selectTab:(UIButton *)sender
{
    self.selectedIndex = sender.tag - 1000;
    
    [UIView animateWithDuration:.3 animations:^{
        selectItem.center = sender.center;
    }];
}

-(void)removeUITabBarButton
{
    for (UIView *view in self.tabBar.subviews) {
        if ([view isKindOfClass:NSClassFromString(@"UITabBarButton")]) {
            [view removeFromSuperview];
        }
    }
}

-(void)loadUnReadWeibo
{
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    [delegate.sinaWeibo
     requestWithURL:@"remind/unread_count.json"
     params:nil
     httpMethod:@"GET"
     finishBlock:^(SinaWeiboRequest *request, id result) {
         [self loadUnReadWeiboFinish:result];
     } failBlock:NULL];
    
    [self performSelector:@selector(loadUnReadWeibo) withObject:nil afterDelay:30];
    
    //取消
    //[NSObject cancelPreviousPerformRequestsWithTarget:<#(id)#> selector:<#(SEL)#> object:<#(id)#>];
}

-(void)loadUnReadWeiboFinish:(id)result
{
    if (!badgeView) {
        badgeView = [[ThemeImgView alloc] initWithFrame:CGRectMake(kScreenWidth/5-kBadgeViewSize, 0, kBadgeViewSize, kBadgeViewSize)];
        badgeView.imgName = @"number_notify_9@2x.png";
        [self.tabBar addSubview:badgeView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kBadgeViewSize, kBadgeViewSize)];
        label.textAlignment = NSTextAlignmentCenter;
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont boldSystemFontOfSize:11];
        label.tag = 2015;
        [badgeView addSubview:label];
    }
    
    int num = [result[@"status"] intValue];
    if (num > 0) {
        badgeView.hidden = NO;
        num = MIN(num, 99);
        UILabel *label = (UILabel *)[badgeView viewWithTag:2015];
        label.text = [NSString stringWithFormat:@"%d", num];
    }else{
        badgeView.hidden = YES;
    }
}

//重写类目的方法
-(void)hideBadge
{
    badgeView.hidden = YES;
}

@end
