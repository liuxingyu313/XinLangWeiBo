//
//  RootNavigationController.m
//  WXWeibo
//
//  Created by JayWon on 15/10/20.
//  Copyright (c) 2015年 JayWon. All rights reserved.
//

#import "RootNavigationController.h"

@interface RootNavigationController ()<UIGestureRecognizerDelegate>

@end

@implementation RootNavigationController

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(themeDidChange) name:kThemeDidChangeNotification object:nil];
    }
    return self;
}

-(void)themeDidChange
{
    //设置背景，因为img高度小于64，所以需要自己生成高度64的图片
    UIImage *bgImg = [[ThemeManager shareManager] loadImageWithImgName:@"mask_titlebar@2x.png"];
    
    CGImageRef imageRef = CGImageCreateWithImageInRect(bgImg.CGImage, CGRectMake(0, 0, kScreenWidth, 64));
    
    [self.navigationBar setBackgroundImage:[UIImage imageWithCGImage:imageRef] forBarMetrics:UIBarMetricsDefault];
    
    CGImageRelease(imageRef);
    
    //标题的字体颜色
    UIColor *titleColor = [[ThemeManager shareManager] loadColorWithKeyName:@"Mask_Title_color"];
    NSDictionary *textAttr = @{
                               NSForegroundColorAttributeName : titleColor,
                               NSFontAttributeName : [UIFont boldSystemFontOfSize:20]
                               };
    self.navigationBar.titleTextAttributes = textAttr;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    //设置主题
    [self themeDidChange];
    
    //给导航栏 pop 设置 pan gesture
    [self customPopGesture];
}

/**
 *  利用Runtime机制 给导航栏 pop 添加 pan gesture
 */
-(void)customPopGesture
{
    //关闭 UINavigationController pop 默认的交互手势
    UIGestureRecognizer *gesture = self.interactivePopGestureRecognizer;
    gesture.enabled = NO;
    //NSLog(@"%@", gesture);
    
    //添加一个新的pan手势到 gesture.view 里面
    UIPanGestureRecognizer *popRecognizer = [[UIPanGestureRecognizer alloc] init];
    popRecognizer.delegate = self;
    popRecognizer.maximumNumberOfTouches = 1;
    [gesture.view addGestureRecognizer:popRecognizer];
    
    //获取手势唯一的接收对象（打印gesture）
    NSMutableArray *_targets = [gesture valueForKey:@"_targets"];
    id gestureRecognizerTarget = [_targets firstObject];
    //获取target
    id navigationInteractiveTransition = [gestureRecognizerTarget valueForKey:@"_target"];
    //获取action
    SEL handleTransition = NSSelectorFromString(@"handleNavigationTransition:");
    //设置pan手势事件响应
    [popRecognizer addTarget:navigationInteractiveTransition action:handleTransition];
}

//有两个条件不允许手势执行，1、当前控制器为根控制器；2、push、pop动画正在执行
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    
    return self.viewControllers.count > 1 && ![[self valueForKey:@"_isTransitioning"] boolValue];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
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
