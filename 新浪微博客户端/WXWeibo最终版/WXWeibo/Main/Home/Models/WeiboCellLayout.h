//
//  WeiboCellLayout.h
//  WXWeibo
//
//  Created by JayWon on 15/10/23.
//  Copyright (c) 2015年 JayWon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WeiboModel.h"

#define kCellHeadHeight         60      //cell头视图的高度
#define kSpaceSize              10      //间距
#define kTextSize               16      //微博字体大小
#define kRetweetTextSize        15      //转发微博字体大小
#define kTextLineSpace          6       //微博正文行间距
#define kRetweetTextLineSpace   4       //转发微博正文行间距
#define kMultipleImgSpace       5       //多图之间的间隔

//由于转发微博主题背景图片带阴影导致尺寸不规则，这里调整一下整体美观度，如果不需要，把值改为0
#define kRetweetBgAlignX        4       //转发微博背景视图起始X坐标对齐微博正文
#define kRetweetBgAlignY        5       //转发微博背景视图起始Y坐标离微博文字底部的距离


/**
 *  WeiboCellLayout 包含 WeiboModel 以及 cell 里面所有 ui 的 frame
 */
@interface WeiboCellLayout : NSObject


@property(nonatomic, strong)WeiboModel *weiboModel;

//cell的高度
@property(nonatomic, assign)CGFloat cellHeight;

//微博正文的frame
@property(nonatomic, assign)CGRect textFrame;

//转发微博背景图片的frame
@property(nonatomic, assign)CGRect retweetBgFrame;

//转发微博正文的frame
@property(nonatomic, assign)CGRect retweetTextFrame;

//微博多图每张图片的frame
@property(nonatomic, strong)NSMutableArray *imgFrameArr;

@end
