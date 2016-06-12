//
//  FaceView.h
//  WXWeibo
//
//  Created by JayWon on 15/10/30.
//  Copyright (c) 2015年 JayWon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImgFaceView.h"

@interface FaceView : UIView <UIScrollViewDelegate>
{
    UIScrollView *scrollView;
    UIPageControl *pgCtrl;
}

@property(nonatomic, weak)ImgFaceView *imgFaceView;

@end
