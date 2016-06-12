//
//  CameraView.m
//  AVCapureSession
//
//  Created by liuwei on 15/11/30.
//  Copyright © 2015年 wxhl. All rights reserved.
//

#import "CameraView.h"
#define lineSpace 10
@implementation CameraView{
    
    UIImageView *_line;
    UILabel *_promLabel;
}

- (id)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
      
        [self _createViews];
    }
    
    return self;
}

- (void)_createViews{

    self.backgroundColor = [UIColor clearColor];
    CGFloat width = self.frame.size.width * 2 / 3;
    CGFloat height = width;
    CGFloat x = (self.frame.size.width - width) / 2;
    CGFloat y = (self.frame.size.height - height) / 2;
    
    //扫描区域
    self.scanRect = CGRectMake(x, y, width, height);
    
    //扫描线
    UIImage *image = [UIImage imageNamed:@"line.png"];
    image = [image stretchableImageWithLeftCapWidth:image.
             size.height / 2 topCapHeight:image.size.width / 2];
    _line = [[UIImageView alloc] initWithFrame:CGRectMake((self.frame.size.width - image.size.width) / 2, y,image.size.width, 1)];
    _line.image = image;
    [self addSubview:_line];
    
    //提示语
    _promLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, CGRectGetMaxY(self.scanRect) + 10, width, 20)];
    _promLabel.text = @"将二维码/条形码放入框内，即可完成扫描";
    _promLabel.font = [UIFont systemFontOfSize:11];
    _promLabel.textColor = [UIColor whiteColor];
    _promLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_promLabel];
}

//扫描动画
-(void)animation
{
    CABasicAnimation *basicAnimation = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
    basicAnimation.toValue = @(self.scanRect.size.height);
    basicAnimation.duration = 3;
    basicAnimation.repeatCount = MAXFLOAT;
    [_line.layer addAnimation:basicAnimation forKey:@"wxhl"];
}

- (void)drawRect:(CGRect)rect {
    [self animation];
    //灰色半透明背景
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    UIBezierPath *backgroundPath = [UIBezierPath bezierPathWithRect:rect];
    [[UIColor colorWithWhite:0 alpha:.5] setFill];
    CGContextAddPath(ctx, backgroundPath.CGPath);
    
    //绿色扫描区域
    CGFloat width = self.scanRect.size.width;
    CGFloat height = self.scanRect.size.height;
    CGFloat x = self.scanRect.origin.x;
    CGFloat y = self.scanRect.origin.y;
    UIBezierPath *rectPath = [UIBezierPath bezierPathWithRect:CGRectMake(x, y, width, height)];
    CGContextAddPath(ctx, rectPath.CGPath);
    CGContextDrawPath(ctx, kCGPathEOFill);
    
    //四周的绿线
    UIBezierPath *greenlinePath = [UIBezierPath bezierPathWithRect:CGRectMake(x, y, width, height)];
    [[UIColor greenColor] setStroke];
    [greenlinePath stroke];
    
    //四周的白线
    UIBezierPath *writelinePath = [UIBezierPath bezierPath];
    [self drawLineWithPath:writelinePath point:CGPointMake(x + lineSpace, y) toPoint:CGPointMake(x + width -  lineSpace, y)];
    [self drawLineWithPath:writelinePath point:CGPointMake(x + lineSpace, y + height) toPoint:CGPointMake(x + width -lineSpace, y + height)];
    
    [self drawLineWithPath:writelinePath point:CGPointMake(x, y + lineSpace) toPoint:CGPointMake(x, y + height -lineSpace)];
    [self drawLineWithPath:writelinePath point:CGPointMake(x + width, y + lineSpace) toPoint:CGPointMake(x + width, y + height -lineSpace)];
    [[UIColor whiteColor] setStroke];
    [writelinePath stroke];
}

- (void)drawLineWithPath:(UIBezierPath *)path point:(CGPoint)point toPoint:(CGPoint)toPoint{
    [path moveToPoint:point];
    [path addLineToPoint:toPoint];
}

@end
