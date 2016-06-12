//
//  WeiboTableView.h
//  WXWeibo
//
//  Created by JayWon on 15/10/23.
//  Copyright (c) 2015年 JayWon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WeiboCell.h"
#import "ThemeTableView.h"

@interface WeiboTableView : ThemeTableView <UITableViewDelegate, UITableViewDataSource>

@property(nonatomic, strong)NSMutableArray *dataArr;

@end
