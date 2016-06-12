//
//  CommentTableView.m
//  WXWeibo
//
//  Created by JayWon on 15/10/30.
//  Copyright (c) 2015年 JayWon. All rights reserved.
//

#import "CommentTableView.h"

static NSString *kCellID = @"kCmmtTableViewCellID";

@implementation CommentTableView

-(void)setupConfig
{
    [super setupConfig];
    
    _dataArr = [[NSMutableArray alloc] init];
    
    self.delegate = self;
    self.dataSource = self;
    
    [self registerNib:[UINib nibWithNibName:@"CommentCell" bundle:nil] forCellReuseIdentifier:kCellID];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArr.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CommentCellLayout *layout = self.dataArr[indexPath.row];
    return layout.cellHeight;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CommentCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellID forIndexPath:indexPath];
    cell.layout = self.dataArr[indexPath.row];
    
    return cell;
}

@end
