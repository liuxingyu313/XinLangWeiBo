//
//  WeiboAnnotationView.h
//  WXWeibo
//
//  Created by JayWon on 15/11/2.
//  Copyright (c) 2015年 JayWon. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "WeiboAnnotation.h"

@interface WeiboAnnotationView : MKAnnotationView
{
    UIImageView *userImgView;       //头像
    UIImageView *weiboImgView;      //微博图片
    UILabel *textLabel;             //微博内容
}

@end
