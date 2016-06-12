//
//  MessageViewController.m
//  WXWeibo
//
//  Created by JayWon on 15/10/20.
//  Copyright (c) 2015年 JayWon. All rights reserved.
//

#import "MessageViewController.h"
#import "WeiboTableView.h"
#import "WXRefresh.h"

@interface MessageViewController ()

@property (weak, nonatomic) IBOutlet WeiboTableView *tbView;

@end

@implementation MessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    //关闭 navigationBar 半透明效果，让所有subview的起始点坐标在导航栏下方左上角（修正 barView 的起始位置）
    self.navigationController.navigationBar.translucent = NO;
    [self initViews];
    
    
    __weak MessageViewController *weakSelf = self;
    //下拉加载最新
    [_tbView addPullDownRefreshBlock:^{
        [weakSelf loadData];
    }];
    
    //上拉加载更多
    [_tbView addInfiniteScrollingWithActionHandler:^{
        [weakSelf loadOldData];
    }];
    
    
    [self loadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark -
-(void)initViews
{
    NSArray *messageButtons = [NSArray arrayWithObjects:
                               [UIImage imageNamed:@"Resource.bundle/navigationbar_mentions"],
                               [UIImage imageNamed:@"Resource.bundle/navigationbar_comments"],
                               [UIImage imageNamed:@"Resource.bundle/navigationbar_messages"],
                               [UIImage imageNamed:@"Resource.bundle/navigationbar_notice"],
                               nil];
    
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
    for (int i=0; i<messageButtons.count; i++) {
        UIButton *button = [[UIButton alloc] init];
        [button setImage:messageButtons[i] forState:UIControlStateNormal];
        button.showsTouchWhenHighlighted = YES;
        button.frame = CGRectMake(50*i+20, 6, 30, 30);
        [button addTarget:self action:@selector(messageAction:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = 100+i;
        [titleView addSubview:button];
    }
    
    self.navigationItem.titleView = titleView;
}

-(void)messageAction:(UIButton *)button
{
    NSInteger tag = button.tag;
    if (tag == 100) {
        //@消息
        //[self loadData];
    }else if (tag == 101){
        //评论
    }else if (tag == 102){
        //私信
    }else if (tag == 103){
        //通知
    }
}

//下拉加载最新
-(void)loadData
{
    uint64_t since_id = 0;
    if (_tbView.dataArr.count > 0) {
        WeiboCellLayout *layout = _tbView.dataArr[0];
        since_id = layout.weiboModel.id;
    }
    
    NSMutableDictionary *mDic = [NSMutableDictionary dictionaryWithDictionary:
                                 @{
                                   @"since_id" : [NSString stringWithFormat:@"%llu", since_id]
                                   }];
    
    [self.appDelegate.sinaWeibo
     requestWithURL:@"statuses/mentions.json"
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
    uint64_t max_id = 0;
    if (_tbView.dataArr.count > 0) {
        WeiboCellLayout *layout = [_tbView.dataArr lastObject];
        max_id = layout.weiboModel.id;
    }
    
    NSMutableDictionary *mDic = [NSMutableDictionary dictionaryWithDictionary:
                                 @{
                                   @"max_id" : [NSString stringWithFormat:@"%llu", max_id]
                                   }];
    
    [self.appDelegate.sinaWeibo
     requestWithURL:@"statuses/mentions.json"
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
            
            [weiboArr addObjectsFromArray:_tbView.dataArr];
            _tbView.dataArr = weiboArr;
        }else{  //上拉
            
            //去除重复的数据（新浪的bug）
            WeiboCellLayout *firstLayout = weiboArr[0];
            WeiboCellLayout *lastLayout = [_tbView.dataArr lastObject];
            if (firstLayout.weiboModel.id == lastLayout.weiboModel.id) {
                [weiboArr removeObject:firstLayout];
            }
            
            [_tbView.dataArr addObjectsFromArray:weiboArr];
        }
        
        [_tbView reloadData];
    }
    
    
    [self stopRefresh];
}

-(void)loadDataFail:(NSError *)error
{
    [self stopRefresh];
}

-(void)stopRefresh
{
    [_tbView.pullToRefreshView stopAnimating];
    [_tbView.infiniteScrollingView stopAnimating];
}

@end
