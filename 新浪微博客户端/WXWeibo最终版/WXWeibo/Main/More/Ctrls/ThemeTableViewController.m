//
//  ThemeTableViewController.m
//  WXWeibo
//
//  Created by JayWon on 15/10/21.
//  Copyright (c) 2015年 JayWon. All rights reserved.
//

#import "ThemeTableViewController.h"
#import "ThemeCell.h"
#import "AppDelegate.h"

@interface ThemeTableViewController ()
{
    NSArray *themeArr;
}

@end

@implementation ThemeTableViewController

-(instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        //隐藏tabbar
        self.hidesBottomBarWhenPushed = YES;
        
        //用ThemeTableView代替
        //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(themeDidChange) name:kThemeDidChangeNotification object:nil];
    }
    return self;
}

/*
-(void)themeDidChange
{
    self.tableView.backgroundColor = [[ThemeManager shareManager] loadColorWithKeyName:@"More_Item_color"];
    self.tableView.separatorColor = [[ThemeManager shareManager] loadColorWithKeyName:@"More_Item_Line_color"];
}
*/

- (void)viewDidLoad {
    [super viewDidLoad];
    
    themeArr = [[ThemeManager shareManager].themeDic allKeys];
    [self.tableView registerNib:[UINib nibWithNibName:@"ThemeCell" bundle:nil] forCellReuseIdentifier:kThemeViewCtrlID];
    
    //[self themeDidChange];
    
    //返回
    ThemeButton *button = [[ThemeButton alloc] initWithFrame:CGRectMake(0, 0, 60, 44)];
    button.backImgName = @"titlebar_button_back_9@2x.png";
    [button setTitle:@"返回" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = backItem;
}

-(void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(AppDelegate *)appDelegate
{
    return (AppDelegate *)[UIApplication sharedApplication].delegate;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    //禁止滑动
    [self.appDelegate.drawerCtrl setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeNone];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.appDelegate.drawerCtrl setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeAll];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    //NSLog(@"%s", __FUNCTION__);
}
*/

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return themeArr.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ThemeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"kThemeViewCtrlID" forIndexPath:indexPath];
    
    // Configure the cell...
    NSString *themeName = themeArr[indexPath.row];
    cell.themeNameLabel.text = themeName;
    cell.headImgView.image = [[ThemeManager shareManager] loadThemeImageWithThemeName:themeName];
    
    if ([themeName isEqualToString:[ThemeManager shareManager].themeName]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{    
    NSString *themeName = themeArr[indexPath.row];
    [ThemeManager shareManager].themeName = themeName;
    //发通知切换主题
    [[NSNotificationCenter defaultCenter] postNotificationName:kThemeDidChangeNotification object:nil];
    [tableView reloadData];
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
