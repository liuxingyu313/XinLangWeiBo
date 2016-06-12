//
//  CommentCell.h
//  WXWeibo
//
//  Created by JayWon on 15/10/28.
//  Copyright (c) 2015年 JayWon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommentCellLayout.h"

@interface CommentCell : UITableViewCell <WXLabelDelegate>

@property(nonatomic, strong) CommentCellLayout *layout;

@property (weak, nonatomic) IBOutlet UIImageView *userHeaderImgView;
@property (weak, nonatomic) IBOutlet ThemeLabel *usernameLabel;
@property (weak, nonatomic) IBOutlet ThemeLabel *cmTimeLabel;

@property(nonatomic, strong, readonly)WXLabel *cmmtTextLabel;

@end
