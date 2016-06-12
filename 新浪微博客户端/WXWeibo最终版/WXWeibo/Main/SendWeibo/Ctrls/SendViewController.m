//
//  SendViewController.m
//  WXWeibo
//
//  Created by JayWon on 15/10/30.
//  Copyright (c) 2015年 JayWon. All rights reserved.
//

#import "SendViewController.h"
#import "LocationSelfTableViewController.h"
#import "RootNavigationController.h"
#import "InputAccessoryView.h"
#import "EmoticonInputView.h"

@interface SendViewController ()<EmoticonInputDelegate>
{
    InputAccessoryView *inputAccsView;
}

@property(nonatomic, weak)UITextView *txView;
@property(nonatomic, strong)EmoticonInputView *emtcInputView;

@property(nonatomic, strong)NSDictionary *locationGeoDic;

@end

@implementation SendViewController

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self keyboardEvent];
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self keyboardEvent];
    }
    return self;
}

-(void)keyboardEvent
{
    //键盘弹出，动态调整txView的高度
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardShowNotification:) name:UIKeyboardWillShowNotification object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [[ThemeManager shareManager] loadColorWithKeyName:@"More_Item_color"];
    
    self.title = @"发微博";

    [self configUI];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.txView becomeFirstResponder];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.appDelegate.drawerCtrl closeDrawerAnimated:YES completion:NULL];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    //NSLog(@"%s", __FUNCTION__);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)backAction
{
    [self.txView resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:NULL];
}

//移除位置信息
- (void)removeLocation {
    inputAccsView.locationLabel.text = nil;
    self.locationGeoDic = nil;
    
    inputAccsView.locationBackView.hidden = YES;
}

-(void)sendWeobo
{
    //去掉空白与换行符
    NSString *textStr = [self.txView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (textStr.length == 0) {
        [WeiboHelper showFailHUD:@"微博内容不能为空" withDelayHideTime:2 withView:_txView];
        return;
    }
    if (textStr.length > 140) {
        [WeiboHelper showFailHUD:@"微博内容不能超过140个汉字" withDelayHideTime:2 withView:_txView];
        return;
    }
    
    NSMutableDictionary *mDic = [NSMutableDictionary dictionaryWithObject:textStr forKey:@"status"];
    if (self.locationGeoDic) {
        [mDic setObject:_locationGeoDic[@"lat"] forKey:@"lat"];
        [mDic setObject:_locationGeoDic[@"lon"] forKey:@"long"];
    }
    
    [self.appDelegate.sinaWeibo requestWithURL:@"statuses/update.json"
                                          params:mDic
                                      httpMethod:@"POST"
                                     finishBlock:^(SinaWeiboRequest *request, id result) {
                                         [WeiboHelper showSuccessHUD:@"发送成功" withDelayHideTime:2];
                                         [self backAction];
                                     } failBlock:^(SinaWeiboRequest *request, NSError *error) {
                                         [WeiboHelper showFailHUD:@"发送失败" withDelayHideTime:2 withView:_txView];
                                     }];
}

-(void)configUI
{
    //返回
    ThemeButton *button = [[ThemeButton alloc] initWithFrame:CGRectMake(0, 0, 60, 44)];
    button.backImgName = @"titlebar_button_back_9@2x.png";
    [button setTitle:@"返回" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = backItem;
    
    //发送
    ThemeButton *rightButton = [[ThemeButton alloc] initWithFrame:CGRectMake(0, 0, 60, 44)];
    rightButton.backImgName = @"titlebar_button_9@2x.png";
    [rightButton setTitle:@"发送" forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(sendWeobo) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    //输入区
    UITextView *txView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight-64-216)];
    txView.font = [UIFont systemFontOfSize:15];
    txView.textColor = [[ThemeManager shareManager] loadColorWithKeyName:@"More_Item_Text_color"];
    txView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:txView];
    self.txView = txView;
    
    //键盘正上方辅佐的view
    inputAccsView = [[[NSBundle mainBundle] loadNibNamed:@"InputAccessoryView" owner:self options:nil] firstObject];
    [inputAccsView.clearButton addTarget:self action:@selector(removeLocation) forControlEvents:UIControlEventTouchUpInside];
    inputAccsView.locationBackView.hidden = YES;
    
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, 45, kScreenWidth, 50)];
    //bottomView.backgroundColor = kEmoticonInputViewBgColor;
    NSArray *imgNames = @[
                         @"compose_toolbar_1@2x.png",
                         @"compose_toolbar_3@2x.png",
                         @"compose_toolbar_6@2x.png",
                         @"compose_toolbar_5@2x.png",
                         @"compose_toolbar_4@2x.png",
                         ];
    float itemWidth = kScreenWidth / 5;
    for (int i=0; i<imgNames.count; i++) {
        ThemeButton *btn = [[ThemeButton alloc] init];
        btn.imgName = imgNames[i];
        btn.tag = 300+i;
        btn.frame = CGRectMake(itemWidth * i, 0, itemWidth, 50);
        [btn addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        [bottomView addSubview:btn];
    }
    [inputAccsView addSubview:bottomView];
    txView.inputAccessoryView = inputAccsView;
}

//改变输入框的高度
-(void)keyboardShowNotification:(NSNotification *)notification
{
    NSValue *keyboardValue = notification.userInfo[UIKeyboardFrameEndUserInfoKey];
    CGRect frame = [keyboardValue CGRectValue];
    self.txView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight - 64 - frame.size.height);
}

-(void)buttonAction:(UIButton *)button
{
    switch (button.tag) {
        case 300:
            break;
        case 301:
            break;
        case 302:
        {
            if (!_emtcInputView) {
                _emtcInputView = [[EmoticonInputView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kEmoticonViewHeight)];
                _emtcInputView.delegate = self;
            }

            self.txView.inputView = self.txView.inputView ? nil : _emtcInputView;
            [self.txView reloadInputViews];
            [self.txView becomeFirstResponder];
        }
            break;
        case 303:
        {
            [_txView resignFirstResponder];
            
            LocationSelfTableViewController *locationSelf = [[LocationSelfTableViewController alloc] init];
            
            locationSelf.selectLocation = ^(NSDictionary *result){
                self.locationGeoDic = result;
                
                inputAccsView.locationBackView.hidden = NO;
                NSString *address = [result objectForKey:@"title"];
                if ([address isKindOfClass:[NSNull class]]) {
                    address = [result objectForKey:@"address"];
                }
                inputAccsView.locationLabel.text = address;
            };
            
            RootNavigationController *navCtrl = [[RootNavigationController alloc] initWithRootViewController:locationSelf];
            [self presentViewController:navCtrl animated:YES completion:NULL];
        }
            break;
        case 304:
            break;
            
        default:
            break;
    }
}

#pragma mark - EmoticonInputDelegate
- (void)emoticonInputDidTapText:(NSString *)text {
    if (text.length) {
        [_txView replaceRange:_txView.selectedTextRange withText:text];
    }
}

- (void)emoticonInputDidTapBackspace {
    [_txView deleteBackward];
}

@end
