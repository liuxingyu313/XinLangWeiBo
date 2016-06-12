//
//  LocationSelfTableViewController.h
//  WXWeibo
//
//  Created by JayWon on 15/10/31.
//  Copyright (c) 2015年 JayWon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

typedef void(^SelectedLocationDone)(NSDictionary *);

@interface LocationSelfTableViewController : UITableViewController<CLLocationManagerDelegate>

@property(nonatomic, copy)SelectedLocationDone selectLocation;

@end
