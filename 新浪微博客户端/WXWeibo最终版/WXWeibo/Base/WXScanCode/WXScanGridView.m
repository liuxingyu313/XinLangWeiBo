//
//  WXScanGridView.m
//  QRCode
//
//  Created by JayWon on 15/12/14.
//  Copyright © 2015年 JayWon. All rights reserved.
//

#import "WXScanGridView.h"

#define lineSpace 10

@interface WXScanGridView ()
@property (nonatomic, weak)UIImageView *line;   //扫描线
@property (nonatomic, assign)CGRect scanRect;   //扫描区域
@end

@implementation WXScanGridView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        CGFloat width = frame.size.width * 2 / 3;
        CGFloat height = width;
        CGFloat x = (frame.size.width - width) / 2;
        CGFloat y = (frame.size.height - height) / 2;
        self.scanRect = CGRectMake(x, y, width, height);
        
        UIImage *image = [UIImage imageNamed:@"CodeScan.bundle/qrcode_scan_light_green"];
        UIImageView *line = [[UIImageView alloc] initWithFrame:CGRectMake((frame.size.width - MIN(image.size.width, width)) / 2, y, MIN(image.size.width, width), 2)];
        line.image = image;
        [self addSubview:line];
        self.line = line;
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    
    //获取上下文
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    //添加灰色半透明区域路径
    UIBezierPath *backgroundPath = [UIBezierPath bezierPathWithRect:rect];
    [[UIColor colorWithWhite:0 alpha:.5] setFill];
    CGContextAddPath(ctx, backgroundPath.CGPath);
    
    //添加扫描区域路径
    UIBezierPath *rectPath = [UIBezierPath bezierPathWithRect:_scanRect];
    CGContextAddPath(ctx, rectPath.CGPath);
    
    //绘制所有路径
    CGContextDrawPath(ctx, kCGPathEOFill);
    
    //扫描区域四角边角线
    UIImage *imageTL = [UIImage imageNamed:@"CodeScan.bundle/chat_code_pic_angle_ul.png"];
    UIImage *imageTR = [UIImage imageNamed:@"CodeScan.bundle/chat_code_pic_angle_ur.png"];
    UIImage *imageBL = [UIImage imageNamed:@"CodeScan.bundle/chat_code_pic_angle_ll.png"];
    UIImage *imageBR = [UIImage imageNamed:@"CodeScan.bundle/chat_code_pic_angle_lr.png"];
    CGContextDrawImage(ctx, CGRectMake(CGRectGetMinX(_scanRect)-4, CGRectGetMaxY(_scanRect)-12, 16, 16), imageTL.CGImage);
    CGContextDrawImage(ctx, CGRectMake(CGRectGetMaxX(_scanRect)-12, CGRectGetMaxY(_scanRect)-12, 16, 16), imageTR.CGImage);
    CGContextDrawImage(ctx, CGRectMake(CGRectGetMinX(_scanRect)-4, CGRectGetMinY(_scanRect)-4, 16, 16), imageBL.CGImage);
    CGContextDrawImage(ctx, CGRectMake(CGRectGetMaxX(_scanRect)-12, CGRectGetMinY(_scanRect)-4, 16, 16), imageBR.CGImage);
    
    /*
    //扫描区域四角边角线
    UIBezierPath *cornerlinePath = [UIBezierPath bezierPathWithRect:_scanRect];
    [[UIColor colorWithRed:0.278 green:0.729 blue:1.000 alpha:1.000] setStroke];
    [cornerlinePath stroke];
    
    //扫描区域边框线
    UIBezierPath *borderLinePath = [UIBezierPath bezierPath];
    [self drawLineWithPath:borderLinePath point:CGPointMake(_scanRect.origin.x + lineSpace, _scanRect.origin.y) toPoint:CGPointMake(CGRectGetMaxX(_scanRect) - lineSpace, _scanRect.origin.y)];
    [self drawLineWithPath:borderLinePath point:CGPointMake(_scanRect.origin.x + lineSpace, CGRectGetMaxY(_scanRect)) toPoint:CGPointMake(CGRectGetMaxX(_scanRect) - lineSpace, CGRectGetMaxY(_scanRect))];
    
    [self drawLineWithPath:borderLinePath point:CGPointMake(_scanRect.origin.x, _scanRect.origin.y + lineSpace) toPoint:CGPointMake(_scanRect.origin.x, CGRectGetMaxY(_scanRect) - lineSpace)];
    [self drawLineWithPath:borderLinePath point:CGPointMake(CGRectGetMaxX(_scanRect), _scanRect.origin.y + lineSpace) toPoint:CGPointMake(CGRectGetMaxX(_scanRect), CGRectGetMaxY(_scanRect) - lineSpace)];
    [[UIColor whiteColor] setStroke];
    [borderLinePath stroke];
     */
}

- (void)drawLineWithPath:(UIBezierPath *)path point:(CGPoint)point toPoint:(CGPoint)toPoint {
    [path moveToPoint:point];
    [path addLineToPoint:toPoint];
}

//扫描动画
- (void)startAnimation {
    [self stopAnimation];
    
    CABasicAnimation *basicAnimation = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
    basicAnimation.toValue = @(self.scanRect.size.height - _line.bounds.size.height);
    basicAnimation.duration = 3;
    basicAnimation.repeatCount = MAXFLOAT;
    [_line.layer addAnimation:basicAnimation forKey:@"wxhl"];
}

- (void)stopAnimation {
    [_line.layer removeAnimationForKey:@"wxhl"];
}

@end
