//
//  FeedbacksTableViewController.m
//  WXWeibo
//
//  Created by JayWon on 15/11/9.
//  Copyright © 2015年 JayWon. All rights reserved.
//

#import "FeedbacksTableViewController.h"
#import "ThemeCell.h"
#import <MessageUI/MessageUI.h>

@interface FeedbacksTableViewController ()
<MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate>
{
    NSArray *dataArr;
}

@end

@implementation FeedbacksTableViewController

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
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.title = @"反馈方式";
    dataArr = @[@"电话", @"短信", @"邮件", @"网页", @"蓝牙", @"WXMovie"];
    
    //返回
    ThemeButton *button = [[ThemeButton alloc] initWithFrame:CGRectMake(0, 0, 60, 44)];
    button.backImgName = @"titlebar_button_back_9@2x.png";
    [button setTitle:@"返回" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = backItem;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"ThemeCell" bundle:nil] forCellReuseIdentifier:kThemeViewCtrlID];
}

-(void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return dataArr.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ThemeCell *cell = [tableView dequeueReusableCellWithIdentifier:kThemeViewCtrlID forIndexPath:indexPath];
    NSString *imgName = [NSString stringWithFormat:@"Resource.bundle/common_icon_membership_level%ld", (long)indexPath.row+1];
    cell.headImgView.image = [UIImage imageNamed:imgName];
    cell.themeNameLabel.text = dataArr[indexPath.row];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
            [self phoneCallTask];
            break;
        case 1:
            [self sendMsg];
            break;
        case 2:
            [self sendEmail];
            break;
        case 3:
            [self browserCallTask];
            break;
        case 4:
            [self bluetoothBLE];
            break;
        case 5:
            [self callWXMovieApp];
            break;
            
        default:
            break;
    }
}

#pragma mark - 私有方法
-(void)openUrl:(NSString *)urlStr{
    NSURL *url = [NSURL URLWithString:urlStr];
    UIApplication *application = [UIApplication sharedApplication];
    if(![application canOpenURL:url]){
        NSString *errStr = [NSString stringWithFormat:@"无法打开\"%@\",请检查此程序是否安装",url];
        [WeiboHelper showFailHUD:errStr withDelayHideTime:2 withView:self.view];
        return;
    }
    [[UIApplication sharedApplication] openURL:url];
}

-(void)phoneCallTask
{
    NSString *deviceType = [UIDevice currentDevice].model;
    if (TARGET_IPHONE_SIMULATOR || [deviceType  isEqualToString:@"iPod touch"]||[deviceType  isEqualToString:@"iPad"]) {
        [WeiboHelper showFailHUD:@"设备不支持打电话" withDelayHideTime:2 withView:self.view];
        return;
    }
    
    NSString *phoneNumber = @"10010";
    
    //这种方式会直接拨打电话
    //NSString *url = [NSString stringWithFormat:@"tel://%@", phoneNumber];
    
    //这种方式会提示用户确认是否拨打电话
    NSString *url = [NSString stringWithFormat:@"telprompt://%@", phoneNumber];
    
    [self openUrl:url];
}

-(void)sendMsg
{
    /*
    //方法一：跳出app发信息
    NSString *phoneNumber = @"10010";
    NSString *url = [NSString stringWithFormat:@"sms://%@", phoneNumber];
    [self openUrl:url];
    */
    
    //方法二：程序内发信息
    if([MFMessageComposeViewController canSendText]){
        MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc]init];
        //收件人
        messageController.recipients = @[@"10010", @"10086"];
        //信息正文
        messageController.body = @"冬天来了，大家注意保暖，有对象的抱对象，没对象的多吃点狗粮。。。";
        //设置代理,注意这里不是delegate而是messageComposeDelegate
        messageController.messageComposeDelegate = self;
        
        //如果运行商支持主题
        if([MFMessageComposeViewController canSendSubject]){
            messageController.subject = @"😍请叫我雷锋😍";
        }
        //如果运行商支持附件
        if ([MFMessageComposeViewController canSendAttachments]) {
            NSString *path = [[WeiboHelper resourceBundle] pathForResource:@"meinv.jpg" ofType:nil];
            NSURL *url = [NSURL fileURLWithPath:path];
            [messageController addAttachmentURL:url withAlternateFilename:@"meinv.jpg"];
        }
        
        [self presentViewController:messageController animated:YES completion:nil];
    }else{
        [WeiboHelper showFailHUD:@"设备不支持发短信" withDelayHideTime:2 withView:self.view];
    }
}

-(void)sendEmail
{
    /*
    //方法一：跳出app发邮件
    NSString *mailAddress= @"junewhj@qq.com";
    NSString *url = [NSString stringWithFormat:@"mailto://%@", mailAddress];
    [self openUrl:url];
    */
    
    //方法二：程序内发邮件
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailController = [[MFMailComposeViewController alloc]init];
        //设置代理，注意这里不是delegate，而是mailComposeDelegate
        mailController.mailComposeDelegate = self;
        //设置收件人
        [mailController setToRecipients:@[@"junewhj@qq.com", @"136888803@qq.com"]];
        //设置抄送人
        [mailController setCcRecipients:@[@"wanghj@bjwxhl.com"]];
        //设置密送人
        [mailController setBccRecipients:@[@"136888803@qq.com"]];
        //设置主题
        [mailController setSubject:@"😍请叫我雷锋😍"];
        //设置内容
        [mailController setMessageBody:@"冬天来了，大家注意保暖，有对象的抱对象，没对象的多吃点狗粮。。。" isHTML:YES];
        //添加附件
        NSString *file = [[WeiboHelper resourceBundle] pathForResource:@"meinv.jpg" ofType:nil];
        NSData *data = [NSData dataWithContentsOfFile:file];
        [mailController addAttachmentData:data mimeType:@"image/jpeg" fileName:@"meinv.jpg"];//第二个参数时mimeType类型，jpg图片对应image/jpeg

        [self presentViewController:mailController animated:YES completion:nil];
    }else{
        [WeiboHelper showFailHUD:@"设备不支持发邮件" withDelayHideTime:2 withView:self.view];
    }
}

-(void)browserCallTask
{
    //方法一：跳转到系统浏览器打开网页
    NSString *url = @"http://www.bjwxhl.com/";
    [self openUrl:url];
    
    //方法二：用一个webview在程序内加载网页
}

/*
 蓝牙（蓝牙低功耗技术 BLE（Bluetooth Low Energy），在iOS中进行蓝牙传输应用开发常用的框架有如下几种：
 
    1、GameKit.framework                   iOS7之前的蓝牙通讯框架，专为游戏信息传输而设立
    2、MultipeerConnectivity.framework     iOS7引入的蓝牙通讯开发框架，用于取代GameKit，一种支持Wi-Fi网络、P2P Wi-Fi以及蓝牙个人局域网的通信框架
    3、CoreBluetooth.framework             功能强大的蓝牙开发框架，要求设备必须支持蓝牙4.0。
 
 前两个框架使用起来比较简单，但是缺点也比较明显，仅仅支持iOS设备，传输内容仅限于沙盒或者照片库中用户选择的文件，并且第一个框架只能在同一个应用之间进行传输（一个iOS设备安装应用A，另一个iOS设备上安装应用B是无法传输的）
 CoreBluetooth iOS6开始 完全基于BLE4.0标准 并且支持非iOS设备，你可以通过iOS设备向Android、Windows Phone以及其他安装有蓝牙4.0芯片的智能设备传输，因此也是目前智能家居、无线支付等热门智能设备所推崇的技术。
 
 注意：iPhone4以下设备不支持BLE，另外iOS7.0、8.0模拟器也无法模拟BLE
*/
-(void)bluetoothBLE
{
    
}

//打开WXMovie App反馈（兼容iOS9）
-(void)callWXMovieApp
{
    /*
     步骤：
     1、在 WXMovie App 的 info.plist 里面添加 URL Types，定义 URL Schemes 为 wxhl.movie（名字随意）
     2、在本程序的 info.plist 里面添加 LSApplicationQueriesSchemes（iOS9 白名单），把上面的 wxhl.movie 设置为本程序的白名单
     3、访问 WXMovie App 的 url 必须带上后面的 ://（坑）
     */
    NSString *url = @"wxhl.movie://";
    [self openUrl:url];
}

#pragma mark - MFMessageComposeViewController代理方法
-(void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result{
    switch (result) {
        case MessageComposeResultSent:
            [WeiboHelper showSuccessHUD:@"发送成功" withDelayHideTime:2];
            break;
        case MessageComposeResultCancelled:
            [WeiboHelper showFailHUD:@"取消发送" withDelayHideTime:2 withView:self.view];
            break;
        default:
            [WeiboHelper showFailHUD:@"发送失败" withDelayHideTime:2 withView:self.view];
            break;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - MFMailComposeViewController代理方法
-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    switch (result) {
        case MFMailComposeResultSent:
            [WeiboHelper showSuccessHUD:@"发送成功" withDelayHideTime:2];
            break;
        case MFMailComposeResultSaved://如果存储为草稿（存储后可以到系统邮件应用的对应草稿箱找到）
            [WeiboHelper showSuccessHUD:@"邮件已保存为草稿" withDelayHideTime:2];
            break;
        case MFMailComposeResultCancelled:
            [WeiboHelper showFailHUD:@"取消发送" withDelayHideTime:2 withView:self.view];
            break;
            
        default:
            [WeiboHelper showFailHUD:@"发送失败" withDelayHideTime:2 withView:self.view];
            break;
    }
    if (error) {
        NSString *errStr = [NSString stringWithFormat:@"发送邮件过程中发生错误，错误信息：%@", error.localizedDescription];
        [WeiboHelper showFailHUD:errStr withDelayHideTime:2 withView:self.view];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
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
