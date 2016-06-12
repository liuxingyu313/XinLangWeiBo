//
//  ThemeImgView.h
//  WXWeibo
//
//  Created by JayWon on 15/10/21.
//  Copyright (c) 2015年 JayWon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ThemeImgView : UIImageView

@property(nonatomic, copy)NSString *imgName;

//处理图片拉伸
@property(nonatomic, assign)UIEdgeInsets edgeInset;

@end
