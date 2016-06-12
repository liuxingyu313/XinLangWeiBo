//
//  MoreTableViewController.m
//  WXWeibo
//
//  Created by JayWon on 15/10/21.
//  Copyright (c) 2015年 JayWon. All rights reserved.
//

#import "MoreTableViewController.h"
#import "AppDelegate.h"
#import "UIImageView+WebCache.h"

@interface MoreTableViewController ()
{
    __weak IBOutlet ThemeLabel *themeNameLabel;
    __weak IBOutlet ThemeLabel *row1Label;
    __weak IBOutlet ThemeLabel *row2Label;
    __weak IBOutlet ThemeLabel *row3Label;
    __weak IBOutlet ThemeLabel *row4Label;
    __weak IBOutlet ThemeLabel *clearSizeLabel;
    __weak IBOutlet ThemeLabel *logoutLabel;
    
    __weak IBOutlet ThemeImgView *row1ImgView;
    __weak IBOutlet ThemeImgView *row2ImgView;
    __weak IBOutlet ThemeImgView *row3ImgView;
    __weak IBOutlet ThemeImgView *row4ImgView;
}
@end

@implementation MoreTableViewController

-(instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(themeDidChange) name:kThemeDidChangeNotification object:nil];
    }
    return self;
}

-(void)themeDidChange
{
    self.tableView.backgroundColor = [[ThemeManager shareManager] loadColorWithKeyName:@"More_Item_color"];
    self.tableView.separatorColor = [[ThemeManager shareManager] loadColorWithKeyName:@"More_Item_Line_color"];
  
    themeNameLabel.text = [ThemeManager shareManager].themeName;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self themeDidChange];
    
    themeNameLabel.colorKeyName = @"More_Item_Text_color";
    row1Label.colorKeyName = @"More_Item_Text_color";
    row2Label.colorKeyName = @"More_Item_Text_color";
    row3Label.colorKeyName = @"More_Item_Text_color";
    row4Label.colorKeyName = @"More_Item_Text_color";
    clearSizeLabel.colorKeyName = @"More_Item_Text_color";
    logoutLabel.colorKeyName = @"More_Item_Text_color";
    
    row1ImgView.imgName = @"more_icon_theme@2x.png";
    row2ImgView.imgName = @"more_icon_account@2x.png";
    row3ImgView.imgName = @"more_icon_feedback@2x.png";
    row4ImgView.imgName = @"more_icon_draft@2x.png";
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [self readCacheSize];
}

-(void)readCacheSize
{
    //读缓存可能会阻塞主线程
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSUInteger fileSize = [[SDImageCache sharedImageCache] getSize];
        dispatch_async(dispatch_get_main_queue(), ^{
            clearSizeLabel.text = [NSString stringWithFormat:@"%.2f MB", fileSize / 1024 / 1024.0];
        });
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1 && indexPath.row == 1) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"确定要清空吗?" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alert show];
    }else if (indexPath.section == 2) {
        AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
        [appDelegate.sinaWeibo logOut];
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [[SDImageCache sharedImageCache] clearDisk];
        [self readCacheSize];
    }
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
