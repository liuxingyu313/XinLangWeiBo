//
//  WeiboCell.h
//  WXWeibo
//
//  Created by JayWon on 15/10/23.
//  Copyright (c) 2015年 JayWon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WeiboCellLayout.h"
#import "WXLabel.h"
#import "WXPhotoBrowser.h"

@interface WeiboCell : UITableViewCell <WXLabelDelegate,PhotoBrowerDelegate>
{
    __weak IBOutlet UIImageView *userHeadImg;
    __weak IBOutlet ThemeLabel *nickNameLabel;
    __weak IBOutlet ThemeLabel *timeLabel;
    __weak IBOutlet ThemeLabel *sourceLabel;
}

@property(nonatomic, strong)WeiboCellLayout *layout;

@property(nonatomic, strong, readonly)WXLabel *weiboTextLabel;          //微博正文
@property(nonatomic, strong, readonly)ThemeImgView *retweetBgImgView;   //转发微博背景
@property(nonatomic, strong, readonly)WXLabel *retweetTextLabel;        //转发微博正文
@property(nonatomic, strong, readonly)NSMutableArray *imgViewArr;       //微博多图数组


@end
