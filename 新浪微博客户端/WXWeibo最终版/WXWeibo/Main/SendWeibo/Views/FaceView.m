//
//  FaceView.m
//  WXWeibo
//
//  Created by JayWon on 15/10/30.
//  Copyright (c) 2015年 JayWon. All rights reserved.
//

#import "FaceView.h"

@implementation FaceView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    UIImage *img = [UIImage imageNamed:@"emoticon_keyboard_background"];
    [img drawInRect:rect];
}


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initSubView];
    }
    return self;
}

-(void)initSubView
{
    //图片表情
    ImgFaceView *imgFaceView = [[ImgFaceView alloc] initWithFrame:CGRectZero];
    
    //滑动
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, CGRectGetHeight(imgFaceView.frame))];
    scrollView.pagingEnabled = YES;
    scrollView.delegate = self;
    scrollView.clipsToBounds = NO;  //设置放大镜不裁剪
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.contentSize = CGSizeMake(imgFaceView.frame.size.width, scrollView.frame.size.height);
    [self addSubview:scrollView];
    [scrollView addSubview:imgFaceView];
    self.imgFaceView = imgFaceView;
    
    //页码
    pgCtrl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(scrollView.frame), kScreenWidth, 36)];
    pgCtrl.numberOfPages = imgFaceView.pageCount;
    pgCtrl.currentPage = 0;
    [pgCtrl addTarget:self action:@selector(changePageAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:pgCtrl];
    
    //重新赋值自己frame
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, CGRectGetMaxY(pgCtrl.frame));
}


-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView_
{
    int  page = scrollView.contentOffset.x / kScreenWidth;
    pgCtrl.currentPage = page;
}

-(void)changePageAction
{
    [scrollView setContentOffset:CGPointMake(pgCtrl.currentPage*kScreenWidth, scrollView.contentOffset.y) animated:YES];
}


@end
