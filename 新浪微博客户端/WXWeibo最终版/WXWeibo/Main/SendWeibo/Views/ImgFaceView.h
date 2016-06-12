//
//  ImgFaceView.h
//  WXWeibo
//
//  Created by JayWon on 15/10/30.
//  Copyright (c) 2015年 JayWon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImgFaceView : UIView
{
    NSMutableArray *faceItemArr;
    
    UIImageView *manifierView;
    
    int lastTouchIndex;
}

@property(nonatomic, assign)NSInteger pageCount;

//传值kvo监听对象
@property(nonatomic, copy)NSString *faceName_kvo;

@end
