//
//  CommentViewController.m
//  WXWeibo
//
//  Created by JayWon on 15/10/30.
//  Copyright (c) 2015年 JayWon. All rights reserved.
//

#import "CommentViewController.h"
#import "CommentTableView.h"
#import "WXRefresh.h"

@interface CommentViewController ()

@property (weak, nonatomic) IBOutlet CommentTableView *cmmtTableView;

@end

@implementation CommentViewController

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.title = @"微博正文";
    
    //使用hidesBottomBarWhenPushed push到一个使用了自动布局的UIViewController（UITableViewController没这问题），会看到UITabBar的底色背景
    //解决办法：找到UIViewController对应的Navigation Controller，选中Attribute Inspector，取消选中Under Bottom Bars
    
    [self configUI];
    [self loadCommentData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
-(void)dealloc
{
    NSLog(@"%s", __FUNCTION__);
}
*/

-(void)configUI
{
    //header
    WeiboCell *cmmtHeaderView = [[[NSBundle mainBundle] loadNibNamed:@"WeiboCell" owner:self options:nil] firstObject];
    cmmtHeaderView.layout = self.weiboLayout;
    cmmtHeaderView.frame = CGRectMake(0, 0, kScreenWidth, self.weiboLayout.cellHeight);
    self.cmmtTableView.tableHeaderView = cmmtHeaderView;
}

-(void)loadCommentData
{
    NSString *weiboID = [NSString stringWithFormat:@"%llu", self.weiboLayout.weiboModel.id];
    NSMutableDictionary *mDic = [NSMutableDictionary dictionaryWithObject:weiboID forKey:@"id"];
    [self.appDelegate.sinaWeibo requestWithURL:@"comments/show.json"
                                        params:mDic
                                    httpMethod:@"GET"
                                   finishBlock:^(SinaWeiboRequest *request, id result) {
                                         [self loadDataFinished:result];
                                   } failBlock:NULL];

}

-(void)loadDataFinished:(NSDictionary *)result
{
    NSArray *arr = [result objectForKey:@"comments"];
    NSMutableArray *comments = [[NSMutableArray alloc] initWithCapacity:arr.count];
    for (NSDictionary *dic in arr) {
        CommentModel *cmmtModel = [CommentModel yy_modelWithDictionary:dic];
        CommentCellLayout *layout = [[CommentCellLayout alloc] init];
        layout.cmmtModel = cmmtModel;
        [comments addObject:layout];
    }
    
    self.cmmtTableView.dataArr = comments;
    [self.cmmtTableView reloadData];
    
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
