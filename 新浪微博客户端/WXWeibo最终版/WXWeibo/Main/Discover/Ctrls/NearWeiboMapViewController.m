//
//  NearWeiboMapViewController.m
//  WXWeibo
//
//  Created by JayWon on 15/10/31.
//  Copyright (c) 2015年 JayWon. All rights reserved.
//

#import "NearWeiboMapViewController.h"
#import <MapKit/MapKit.h>
#import "WeiboAnnotationView.h"
#import "CommentViewController.h"

@interface NearWeiboMapViewController ()<MKMapViewDelegate>
{
    CLLocationManager *locationManager;
    
    BOOL locationFlag;              //过滤重复定位
}

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end

@implementation NearWeiboMapViewController

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
    
    if (kiOS8Later) {
        locationManager = [[CLLocationManager alloc] init];
        if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedWhenInUse) {
            [locationManager requestWhenInUseAuthorization];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
- (void)dealloc
{
    NSLog(@"%s", __FUNCTION__);
}
*/

//4.请求附近的微博
-(void)loadNearWeibo:(NSString *)lat longitude:(NSString *)lon
{
    NSMutableDictionary *mDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:lon, @"long", lat, @"lat", nil];
    [self.appDelegate.sinaWeibo requestWithURL:@"place/nearby_timeline.json"
                                        params:mDic
                                    httpMethod:@"GET"
                                   finishBlock:^(SinaWeiboRequest *request, id result) {
                                       [self loadDataFinish:result];
                                   } failBlock:^(SinaWeiboRequest *request, NSError *error) {
                                       [WeiboHelper showFailHUD:@"请求网络失败" withDelayHideTime:2 withView:self.view];
                                   }];
}

//5.解析成model
-(void)loadDataFinish:(NSDictionary *)result
{
    NSArray *status = result[@"statuses"];
    for (int i=0; i<status.count; i++) {
        WeiboModel *model = [WeiboModel yy_modelWithDictionary:status[i]];
        
        //6.把WeiboModel和WeiboAnnotation建立联系
        WeiboAnnotation *wbAtt = [[WeiboAnnotation alloc] init];
        wbAtt.weiboModel = model;
        
        //7.把WeiboAnnotation添加到地图上面
        [self.mapView addAnnotation:wbAtt];
    }
}


#pragma mark - MKMapViewDelegate
//1.定位, 用户的位置已经更新(方法会多次调用)
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    if (!locationFlag) {
        locationFlag = YES;
        
        CLLocationCoordinate2D coor2D = userLocation.location.coordinate;
        
        //显示的跨度
        MKCoordinateSpan span = {0.05, 0.05};
        MKCoordinateRegion region = MKCoordinateRegionMake(coor2D, span);
        //2.设置地图显示的区域
        [self.mapView setRegion:region animated:YES];
        
        //3.拿到经纬度
        NSString *lon = [NSString stringWithFormat:@"%f", coor2D.longitude];
        NSString *lat = [NSString stringWithFormat:@"%f", coor2D.latitude];

        [self loadNearWeibo:lat longitude:lon];
        
        //请求微博过后，停止显示用户的位置可以停止定位，保证请求微博只执行一次，但是这样就看不到自己的位置了
        //mapView.showsUserLocation = NO;
    };
}

//8.绘制MKAnnotationView（原理同UITableViewCell）
-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    //如果是自己的annotation,就不需要MKAnnotationView
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }
    
    static NSString *strID = @"kWeoboMKAnnotationViewID";
    //9.定制WeiboAnnotationView
    WeiboAnnotationView *anntView = (WeiboAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:strID];
    if (!anntView) {
        anntView = [[WeiboAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:strID];
    }
    
    return anntView;
}

//9.加特技显示。此方法会执行多次（不停的缩放地图，出列可重用的MKAnnotationView就会执行这个方法）
- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{    
    for (int i=0; i<views.count; i++) {
        UIView *attView = views[i];
        
        //1.先隐藏, 缩小尺寸
        attView.alpha = 0;
        attView.transform = CGAffineTransformMakeScale(0.7, 0.7);
        
        //2.动画
        //要求:1.透明度0->1; 2.先放大超过原始尺寸, 然后缩小到原始尺寸;
        [UIView animateWithDuration:0.3 animations:^{
            [UIView setAnimationDelay:0.2*i];   //最关键的一句，每个view延迟不同的时间显示
            attView.alpha = 1;
            attView.transform = CGAffineTransformMakeScale(1.2, 1.2);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.3 animations:^{
                attView.transform = CGAffineTransformIdentity;
            }];
        }];
    }
}

//选中push
-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    //过滤自己
    if (![view isKindOfClass:[WeiboAnnotationView class]]) {
        return;
    }
    
    //拿到 weiboModel，转换成 WeiboCellLayout，赋值给 CommentViewController
    WeiboAnnotation *weiboAtt = view.annotation;
    WeiboCellLayout *layout = [[WeiboCellLayout alloc] init];
    layout.weiboModel = weiboAtt.weiboModel;
    
    
    UIStoryboard *stbd = [UIStoryboard storyboardWithName:@"Home" bundle:nil];
    CommentViewController *cmmtCtrl = [stbd instantiateViewControllerWithIdentifier:@"kCommentViewControllerID"];
    cmmtCtrl.weiboLayout = layout;
    [self.navigationController pushViewController:cmmtCtrl animated:YES];
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
