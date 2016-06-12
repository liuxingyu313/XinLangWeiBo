//
//  EmoticonCell.h
//  WXWeibo
//
//  Created by JayWon on 15/11/25.
//  Copyright © 2015年 JayWon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EmoticonModel.h"

#define kEmoticonSize       32  //一个表情的大小
#define kMagnifierEmtcSize  44  //放大镜里面表情的大小
#define kItemHeight         50  //EmoticonCell的高度

@interface EmoticonCell : UICollectionViewCell

@property (nonatomic, strong) EmoticonModel *emoticon;
@property (nonatomic, assign) BOOL isDelete;
@property (nonatomic, strong) UIImageView *imageView;

-(NSString *)emojiUnicodeWithString:(NSString *)str;

@end
