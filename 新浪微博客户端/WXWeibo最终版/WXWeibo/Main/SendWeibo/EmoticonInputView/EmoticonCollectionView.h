//
//  EmoticonCollectionView.h
//  WXWeibo
//
//  Created by JayWon on 15/11/25.
//  Copyright © 2015年 JayWon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EmoticonCell.h"

#define kRowCount       3   //3行
#define kColumnCount    7   //7列
#define kOnePageCount   ((kRowCount)*(kColumnCount) - 1)  //一页表情的个数

@protocol EmoticonTapDelegate <UICollectionViewDelegate>
-(void)emoticonDidTapCell:(EmoticonCell *)cell;
@end

@interface EmoticonCollectionView : UICollectionView
{
    UIImageView *_magnifier;        //放大镜
    UIImageView *_magnifierContent; //放大镜里面的图片
}

@end
