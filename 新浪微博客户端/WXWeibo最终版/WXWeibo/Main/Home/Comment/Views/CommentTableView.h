//
//  CommentTableView.h
//  WXWeibo
//
//  Created by JayWon on 15/10/30.
//  Copyright (c) 2015年 JayWon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommentCell.h"
#import "ThemeTableView.h"

@interface CommentTableView : ThemeTableView <UITableViewDataSource, UITableViewDelegate>

@property(nonatomic, strong)NSMutableArray *dataArr;

@end
