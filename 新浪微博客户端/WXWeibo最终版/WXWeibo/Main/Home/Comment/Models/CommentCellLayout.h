//
//  CommentCellLayout.h
//  WXWeibo
//
//  Created by JayWon on 15/10/30.
//  Copyright (c) 2015年 JayWon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommentModel.h"
#import "WXLabel.h"

#define kCmmtTextX 50
#define kCmmtTextY 50
#define kLinespace 10

#define kCmmtFontSize 15
#define kCmmtTextLinespace  4

@interface CommentCellLayout : NSObject


@property(nonatomic, strong)CommentModel *cmmtModel;

//cell的高度
@property(nonatomic, assign)CGFloat cellHeight;

//微博正文的frame
@property(nonatomic, assign)CGRect textFrame;

@end
