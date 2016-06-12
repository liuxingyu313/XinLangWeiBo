//
//  LocationSelfTableViewController.m
//  WXWeibo
//
//  Created by JayWon on 15/10/31.
//  Copyright (c) 2015年 JayWon. All rights reserved.
//

#import "LocationSelfTableViewController.h"
#import "UIImageView+WebCache.h"
#import "AppDelegate.h"

@interface LocationSelfTableViewController ()
{
    CLLocationManager *locationManager;
}

@property(nonatomic, strong)NSArray *dataArr;

@end

@implementation LocationSelfTableViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"我在这里";
    //返回
    ThemeButton *button = [[ThemeButton alloc] initWithFrame:CGRectMake(0, 0, 60, 44)];
    button.backImgName = @"titlebar_button_back_9@2x.png";
    [button setTitle:@"返回" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = backItem;
    
    //1.定位，拿到经纬度
    //2.从新浪服务器获取地标信息，当成数据源
    //3.用户选择地标信息
    
    /*
    //是否打开定位服务
    if ([CLLocationManager locationServicesEnabled]) {
        NSLog(@"开启定位服务");
    } else {
        NSLog(@"没有开启定位服务");
    }
    */
    
    /*
     用户授权APP访问定位服务
        1.不允许访问 2.使用应用程序期间 3.后台（始终）
        iOS8 app想要获取定位，必须申请授权，在info.plist中添加：
            NSLocationAlwaysUsageDescription  始终
            NSLocationWhenInUseUsageDescription 使用应用程序期间
     */
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    
    if (kiOS8Later) {
        /*
         kCLAuthorizationStatusNotDetermined = 0,   //用户还没决定 要不要授权
         kCLAuthorizationStatusRestricted,          //应用程序受限制，没有授权
         kCLAuthorizationStatusDenied,              //被用户拒绝授权
         kCLAuthorizationStatusAuthorizedAlways,    //始终
         kCLAuthorizationStatusAuthorizedWhenInUse  //使用应用程序期间
         */
        
        //如果程序定位设置不是 使用应用程序期间，则设置为 使用应用程序期间
        if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedWhenInUse) {
            [locationManager requestWhenInUseAuthorization];
        }
    }
    
    //设置精确度，精度越高越耗电
    [locationManager setDesiredAccuracy:kCLLocationAccuracyNearestTenMeters];
    
    //定位频率，每隔10米定位一次
    CLLocationDistance distance = 10.0;
    locationManager.distanceFilter = distance;
    
    //启动定位
    [locationManager startUpdatingLocation];
    
    self.tableView.rowHeight = 60;
    
    //领秀大厦经纬度（39.924115，116.186059）
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

-(void)backAction
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations
{
    
    for (CLLocation *newLocation in locations) {
        //拿到经纬度
        float latitude = newLocation.coordinate.latitude;
        float longitude = newLocation.coordinate.longitude;
        //停止定位
        [manager stopUpdatingLocation];
        
        
        NSMutableDictionary *mDic = [[NSMutableDictionary alloc] init];
        [mDic setObject:[NSString stringWithFormat:@"%f", latitude] forKey:@"lat"];
        [mDic setObject:[NSString stringWithFormat:@"%f", longitude] forKey:@"long"];
        
        AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
        [appDelegate.sinaWeibo requestWithURL:@"place/nearby/pois.json"
                                       params:mDic
                                   httpMethod:@"GET"
                                  finishBlock:^(SinaWeiboRequest *request, id result) {
                                      
                                      NSArray *poisArr = result[@"pois"];
                                      self.dataArr = poisArr;
                                      [self.tableView reloadData];
                                      
                                  } failBlock:NULL];
    }
    
    /*
    for (CLLocation *newLocation in locations) {
        
        //拿到经纬度
        CLLocationCoordinate2D coor2D = newLocation.coordinate;
        NSLog(@"纬度为:%f, 经度为:%f", coor2D.latitude, coor2D.longitude);
        
        //海拔高度
        CLLocationDistance altitude = newLocation.altitude;
        NSLog(@"高度为:%f", altitude);
        
        //水平精确度, 垂直精确度
        CLLocationAccuracy horizontalAcc = newLocation.horizontalAccuracy;
        CLLocationAccuracy verticalAcc = newLocation.verticalAccuracy;
        NSLog(@"%f, %f", horizontalAcc, verticalAcc);
        
        //北京站 经纬度
        CLLocation *anyLocation = [[CLLocation alloc] initWithLatitude:39.909843 longitude:116.433015];
        CLLocationDistance distance = [newLocation distanceFromLocation:anyLocation];
        NSLog(@"领秀大厦到北京站的距离为:%f米", distance);
        
        
        //位置反编码(根据当前的经纬度获取具体的位置信息)
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        [geocoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *placemarks, NSError *error) {
            
            for (CLPlacemark *placeMark in placemarks) {
                NSLog(@"位置:%@", placeMark.name);
                NSLog(@"街道:%@", placeMark.thoroughfare);
                NSLog(@"子街道:%@", placeMark.subThoroughfare);
                NSLog(@"市:%@", placeMark.locality);
                NSLog(@"区\\县:%@", placeMark.subLocality);
                NSLog(@"行政区:%@", placeMark.administrativeArea);
                NSLog(@"国家:%@", placeMark.country);
            }
        }];
        
        //停止定位
        [manager stopUpdatingLocation];
    }
    */
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.dataArr.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"kLocationCellID"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"kLocationCellID"];
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.textColor = [[ThemeManager shareManager] loadColorWithKeyName:@"More_Item_Text_color"];
        cell.detailTextLabel.textColor = [[ThemeManager shareManager] loadColorWithKeyName:@"More_Item_Text_color"];
    }
    
    NSDictionary *dic = self.dataArr[indexPath.row];
    NSString *title = [dic objectForKey:@"title"];
    NSString *address = [dic objectForKey:@"address"];
    NSString *icon = [dic objectForKey:@"icon"];
    
    if (![icon isKindOfClass:[NSNull class]]) {
        [cell.imageView sd_setImageWithURL:[NSURL URLWithString:icon] placeholderImage:[UIImage imageNamed:@"Resource.bundle/page_image_loading"]];
        
        //固定cell.imageView的大小（第二种方法：子类化cell，重写layoutSubview方法给imageView的frame赋值）
        CGSize itemSize = CGSizeMake(44, 44);
        UIGraphicsBeginImageContextWithOptions(itemSize, NO, UIScreen.mainScreen.scale);
        CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
        [cell.imageView.image drawInRect:imageRect];
        cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    if (![title isKindOfClass:[NSNull class]]) {
        cell.textLabel.text = title;
    }
    
    if (![address isKindOfClass:[NSNull class]]) {
        cell.detailTextLabel.text = address;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_selectLocation) {
        _selectLocation(self.dataArr[indexPath.row]);
    }
    
    [self backAction];
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
