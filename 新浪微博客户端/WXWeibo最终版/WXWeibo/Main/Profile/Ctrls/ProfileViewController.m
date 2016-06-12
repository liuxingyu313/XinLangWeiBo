//
//  ProfileViewController.m
//  WXWeibo
//
//  Created by JayWon on 15/10/20.
//  Copyright (c) 2015年 JayWon. All rights reserved.
//

#import "ProfileViewController.h"
#import "UserHeaderView.h"
#import "WeiboTableView.h"
#import "WXRefresh.h"
#import "UserModel.h"

@interface ProfileViewController ()
{
    UserHeaderView *headerView;
}
@property (weak, nonatomic) IBOutlet WeiboTableView *userTableView;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationController.navigationBar.translucent = NO;
    
    headerView = [[[NSBundle mainBundle] loadNibNamed:@"UserHeaderView" owner:self options:nil] lastObject];
    self.userTableView.tableHeaderView = headerView;
    
    
    __weak ProfileViewController *weakSelf = self;
    //下拉加载最新
    [_userTableView addPullDownRefreshBlock:^{
        [weakSelf loadUserHeaderData];
        [weakSelf loadData];
    }];
    
    //上拉加载更多
    [_userTableView addInfiniteScrollingWithActionHandler:^{
        [weakSelf loadOldData];
    }];

    //加载数据
    [weakSelf loadUserHeaderData];
    [weakSelf loadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//加载用户基本信息
-(void)loadUserHeaderData
{
    if (!self.appDelegate.sinaWeibo.userID) {
        return;
    }
    
    NSMutableDictionary *mDic = [[NSMutableDictionary alloc] init];
    [mDic setObject:self.appDelegate.sinaWeibo.userID forKey:@"uid"];

    [self.appDelegate.sinaWeibo requestWithURL:@"users/show.json"
                                        params:mDic
                                    httpMethod:@"GET"
                                   finishBlock:^(SinaWeiboRequest *request, id result) {
                                       UserModel *user = [UserModel yy_modelWithDictionary:result];
                                       headerView.userModel = user;
                                   } failBlock:NULL];
}

//下拉加载最新
-(void)loadData
{
    if (!self.appDelegate.sinaWeibo.userID) {
        return;
    }
    
    NSMutableDictionary *mDic = [[NSMutableDictionary alloc] init];
    [mDic setObject:self.appDelegate.sinaWeibo.userID forKey:@"uid"];
    
    uint64_t since_id = 0;
    if (_userTableView.dataArr.count > 0) {
        WeiboCellLayout *layout = _userTableView.dataArr[0];
        since_id = layout.weiboModel.id;
    }
    [mDic setObject:[NSString stringWithFormat:@"%llu", since_id] forKey:@"since_id"];
    
    
    [self.appDelegate.sinaWeibo
     requestWithURL:@"statuses/user_timeline.json"
     params:mDic
     httpMethod:@"GET"
     finishBlock:^(SinaWeiboRequest *request, id result) {
         [self loadDataFinish:result isSinceID:YES];
     } failBlock:^(SinaWeiboRequest *request, NSError *error) {
         [self loadDataFail:error];
     }];
}

//上拉加载更多
-(void)loadOldData
{
    if (!self.appDelegate.sinaWeibo.userID) {
        return;
    }
    
    NSMutableDictionary *mDic = [[NSMutableDictionary alloc] init];
    [mDic setObject:self.appDelegate.sinaWeibo.userID forKey:@"uid"];

    uint64_t max_id = 0;
    if (_userTableView.dataArr.count > 0) {
        WeiboCellLayout *layout = [_userTableView.dataArr lastObject];
        max_id = layout.weiboModel.id;
    }
    [mDic setObject:[NSString stringWithFormat:@"%llu", max_id] forKey:@"max_id"];
    
    [self.appDelegate.sinaWeibo
     requestWithURL:@"statuses/user_timeline.json"
     params:mDic
     httpMethod:@"GET"
     finishBlock:^(SinaWeiboRequest *request, id result) {
         [self loadDataFinish:result isSinceID:NO];
     } failBlock:^(SinaWeiboRequest *request, NSError *error) {
         [self loadDataFail:error];
     }];
}


-(void)loadDataFinish:(id)result isSinceID:(BOOL)isSinceID
{
    NSMutableArray *weiboArr = [[NSMutableArray alloc] init];
    
    NSArray *statusArr = result[@"statuses"];
    for (NSDictionary *dic in statusArr) {
        WeiboModel *weiboModel = [WeiboModel yy_modelWithDictionary:dic];
        
        //把 weiboModel 传给 WeiboCellLayout，提前计算 cell subview 的 frame
        WeiboCellLayout *layout = [[WeiboCellLayout alloc] init];
        layout.weiboModel = weiboModel;
        
        [weiboArr addObject:layout];
    }
    
    if (weiboArr.count > 0) {
        //下拉
        if (isSinceID) {
            [weiboArr addObjectsFromArray:_userTableView.dataArr];
            _userTableView.dataArr = weiboArr;
        }else{  //上拉
            
            //去除重复的数据（新浪的bug）
            WeiboCellLayout *firstLayout = weiboArr[0];
            WeiboCellLayout *lastLayout = [_userTableView.dataArr lastObject];
            if (firstLayout.weiboModel.id == lastLayout.weiboModel.id) {
                [weiboArr removeObject:firstLayout];
            }
            
            [_userTableView.dataArr addObjectsFromArray:weiboArr];
        }
        
        [_userTableView reloadData];
    }
    
    
    [self stopRefresh];
}

-(void)loadDataFail:(NSError *)error
{
    [self stopRefresh];
}

-(void)stopRefresh
{
    [_userTableView.pullToRefreshView stopAnimating];
    [_userTableView.infiniteScrollingView stopAnimating];
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
