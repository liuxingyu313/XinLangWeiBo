//
//  HomeViewController.m
//  WXWeibo
//
//  Created by JayWon on 15/10/20.
//  Copyright (c) 2015年 JayWon. All rights reserved.
//

#import "HomeViewController.h"
#import "WeiboTableView.h"
#import "WXRefresh.h"
#import <AudioToolbox/AudioToolbox.h>
#import "UITabBarController+Custom.h"
#import "RootTabBarController.h"
#import "DBManager.h"

@interface HomeViewController ()
{
    __weak IBOutlet WeiboTableView *weiboTableView;
    
    ThemeImgView *barView;
    SystemSoundID soundID;
}
@end

@implementation HomeViewController

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        NSString *filePath = [[WeiboHelper ringtoneBundle] pathForResource:@"msgcome" ofType:@"wav"];
        NSURL *url = [NSURL fileURLWithPath:filePath];
        //把声音文件注册为系统声音
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)url, &soundID);
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //关闭 navigationBar 半透明效果，让所有subview的起始点坐标在导航栏下方左上角（修正 barView 的起始位置）
    self.navigationController.navigationBar.translucent = NO;
    
    //关闭scrollview默认往下偏移64个像素显示
    //self.automaticallyAdjustsScrollViewInsets = NO;
    
    
    __weak HomeViewController *weakSelf = self;
    //下拉加载最新
    [weiboTableView addPullDownRefreshBlock:^{
        if ([weakSelf.appDelegate.sinaWeibo isAuthValid]) {
            [weakSelf loadData];
        }else{
            [weakSelf.appDelegate.sinaWeibo logIn];
        }
    }];
    
    //上拉加载更多
    [weiboTableView addInfiniteScrollingWithActionHandler:^{
        [weakSelf loadOldData];
    }];
    
    //登录
    [self login];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//下拉加载最新
-(void)loadData
{
    uint64_t since_id = 0;
    if (weiboTableView.dataArr.count > 0) {
        WeiboCellLayout *layout = weiboTableView.dataArr[0];
        since_id = layout.weiboModel.id;
    }
    
    NSMutableDictionary *mDic = [NSMutableDictionary dictionaryWithDictionary:
                                 @{
                                   @"since_id" : [NSString stringWithFormat:@"%llu", since_id]
                                   
                                   }];
    //查询缓存数据
    [[DBManager shareManager] statusesWithParams:mDic success:^(NSArray *results) {
        //如果有缓存数据
        if (results.count > 0) {
            //把从数据库中查询出来的数据显示在tableView上
            [self loadDataFinish:results isSinceID:YES];
            
        }else {
            
            [self.appDelegate.sinaWeibo
             requestWithURL:@"statuses/home_timeline.json"
             params:mDic
             httpMethod:@"GET"
             finishBlock:^(SinaWeiboRequest *request, id result) {
                 //保存数据
                 [[DBManager shareManager] saveStatuses:result[@"statuses"]];
                 [self loadDataFinish:result[@"statuses"] isSinceID:YES];
             } failBlock:^(SinaWeiboRequest *request, NSError *error) {
                 [self loadDataFail:error];
             }];
        }
    }];
    
    
}

//上拉加载更多
-(void)loadOldData
{
    
    uint64_t max_id = 0;
    if (weiboTableView.dataArr.count > 0) {
        WeiboCellLayout *layout = [weiboTableView.dataArr lastObject];
        max_id = layout.weiboModel.id;
    }
    
    NSMutableDictionary *mDic = [NSMutableDictionary dictionaryWithDictionary:
                                 @{
                                   @"max_id" : [NSString stringWithFormat:@"%llu", max_id]
                                   }];
    //查询缓存数据
    [[DBManager shareManager] statusesWithParams:mDic success:^(NSArray *results) {
        if (results.count > 1) {
            
            [self loadDataFinish:results isSinceID:NO];
        }else {
            
            [self.appDelegate.sinaWeibo
             requestWithURL:@"statuses/home_timeline.json"
             params:mDic
             httpMethod:@"GET"
             finishBlock:^(SinaWeiboRequest *request, id result) {
                 //保存数据
                 [[DBManager shareManager] saveStatuses:result[@"statuses"]];
                 [self loadDataFinish:result[@"statuses"] isSinceID:NO];
             } failBlock:^(SinaWeiboRequest *request, NSError *error) {
                 [self loadDataFail:error];
             }];
            
        }
    }];
    
}

-(void)loadDataFinish:(NSArray *)statuses isSinceID:(BOOL)isSinceID
{
    NSMutableArray *weiboArr = [[NSMutableArray alloc] init];
    
    for (NSDictionary *dic in statuses) {
        WeiboModel *weiboModel = [WeiboModel yy_modelWithDictionary:dic];
        
        //把 weiboModel 传给 WeiboCellLayout，提前计算 cell subview 的 frame
        WeiboCellLayout *layout = [[WeiboCellLayout alloc] init];
        layout.weiboModel = weiboModel;
        
        [weiboArr addObject:layout];
    }
    
    if (weiboArr.count > 0) {
        //下拉
        if (isSinceID) {
            
            //显示加载的最新微博数
            [self showNewWeiboCount:weiboArr.count];
            
            [weiboArr addObjectsFromArray:weiboTableView.dataArr];
            weiboTableView.dataArr = weiboArr;
        }else{  //上拉
            
            //去除重复的数据（新浪的bug）
            WeiboCellLayout *firstLayout = weiboArr[0];
            WeiboCellLayout *lastLayout = [weiboTableView.dataArr lastObject];
            if (firstLayout.weiboModel.id == lastLayout.weiboModel.id) {
                [weiboArr removeObject:firstLayout];
            }
            
            [weiboTableView.dataArr addObjectsFromArray:weiboArr];
        }
        
        [weiboTableView reloadData];
    }
    
    
    [self stopRefresh];
}

-(void)loadDataFail:(NSError *)error
{
    [self stopRefresh];
}

-(void)stopRefresh
{
    [weiboTableView.pullToRefreshView stopAnimating];
    [weiboTableView.infiniteScrollingView stopAnimating];
}

-(void)showNewWeiboCount:(NSInteger)count
{
    if (!barView) {
        barView = [[ThemeImgView alloc] initWithFrame:CGRectMake(0, -40, kScreenWidth, 40)];
        barView.imgName = @"timeline_notify.png";
        [self.view addSubview:barView];
        
        ThemeLabel *tipLabel = [[ThemeLabel alloc] initWithFrame:CGRectZero];
        tipLabel.tag = 2015;
        tipLabel.font = [UIFont systemFontOfSize:16];
        tipLabel.colorKeyName = @"Timeline_Notice_color";
        tipLabel.backgroundColor = [UIColor clearColor];
        [barView addSubview:tipLabel];
    }
    
    UILabel *label = (UILabel *)[self.view viewWithTag:2015];
    label.text = [NSString stringWithFormat:@"%ld条新微博", (long)count];
    [label sizeToFit];
    label.center = CGPointMake(barView.center.x, barView.bounds.size.height/2);
    
    
    [UIView animateWithDuration:0.5 animations:^{
        barView.transform = CGAffineTransformMakeTranslation(0, 40);
    } completion:^(BOOL finished) {
        if (finished) {
            [UIView animateWithDuration:1
                                  delay:1
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 barView.transform = CGAffineTransformIdentity;
                             } completion:NULL];
        }
    }];
    
    //播放声音
    AudioServicesPlaySystemSound(soundID);
    
    //隐藏badgeView, 类目+多态写法
    [self.tabBarController hideBadge];
}

-(void)login
{
    self.appDelegate.sinaWeibo.delegate = self;
    [self.appDelegate.sinaWeibo logIn];
}

#pragma mark - SinaWeibo Delegate
- (void)sinaweiboDidLogIn:(SinaWeibo *)sinaweibo
{
    //1、保存认证数据
    [self.appDelegate storeAuthData];
    
    //2、直接加载数据
    [self loadData];
    
    //2、登录成功 自动触发一个下拉动作（加强用户体验）（目前这个方法有bug）
    //    [weiboTableView triggerPullToRefresh];
}

- (void)sinaweiboDidLogOut:(SinaWeibo *)sinaweibo
{
    //移除认证信息
    [self.appDelegate removeAuthData];
    
    //注销成功重新弹出登录
    RootTabBarController *tabbarCtrl = [[RootTabBarController alloc] init];
    self.appDelegate.drawerCtrl.centerViewController = tabbarCtrl;
}

//弹出登录框不登录时（点左上角红x按钮）收起下拉
- (void)sinaweiboLogInDidCancel:(SinaWeibo *)sinaweibo
{
    [self stopRefresh];
}

- (void)sinaweibo:(SinaWeibo *)sinaweibo logInDidFailWithError:(NSError *)error
{
    NSLog(@"sinaweibo logInDidFailWithError %@", error);
}

//访问令牌过期了或者无效了，需要重新登录
- (void)sinaweibo:(SinaWeibo *)sinaweibo accessTokenInvalidOrExpired:(NSError *)error
{
    [self.appDelegate removeAuthData];
}


@end
