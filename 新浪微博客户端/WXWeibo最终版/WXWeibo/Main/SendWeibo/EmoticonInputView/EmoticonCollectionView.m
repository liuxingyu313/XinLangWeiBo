//
//  EmoticonCollectionView.m
//  WXWeibo
//
//  Created by JayWon on 15/11/25.
//  Copyright © 2015年 JayWon. All rights reserved.
//

#import "EmoticonCollectionView.h"
#import "EmoticonCell.h"

@implementation EmoticonCollectionView

-(instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout
{
    self = [super initWithFrame:frame collectionViewLayout:layout];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.pagingEnabled = YES;
        self.showsHorizontalScrollIndicator = NO;
        self.clipsToBounds = NO;
        self.canCancelContentTouches = NO;
        self.multipleTouchEnabled = NO;
        
        _magnifier = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Resource.bundle/emoticon_keyboard_magnifier"]];
        _magnifierContent = [[UIImageView alloc] initWithFrame:CGRectMake((CGRectGetWidth(_magnifier.frame)-kMagnifierEmtcSize)/2, 5, kMagnifierEmtcSize, kMagnifierEmtcSize)];
        
        [_magnifier addSubview:_magnifierContent];
        [self addSubview:_magnifier];
        _magnifier.hidden = YES;
    }
    return self;
}

-(void)showMagnifierForCell:(EmoticonCell *)cell {
    if (!cell || cell.isDelete || !cell.imageView.image) {
        [self hideMagnifier];
        return;
    }
    
    _magnifierContent.image = cell.imageView.image;
    
    //计算放大镜的位置
    CGRect rect = [cell convertRect:cell.bounds toView:self];
    CGFloat _magnifierX = CGRectGetMidX(rect) - CGRectGetWidth(_magnifier.frame)/2;
    CGFloat _magnifierY = CGRectGetMaxY(rect) - 10 - CGRectGetHeight(_magnifier.frame);
    _magnifier.frame = CGRectMake(_magnifierX, _magnifierY, CGRectGetWidth(_magnifier.frame), CGRectGetHeight(_magnifier.frame));
    _magnifier.hidden = NO;
}

-(void)hideMagnifier {
    _magnifier.hidden = YES;
}

//根据触摸的点获取对应的cell
-(EmoticonCell *)cellForTouches:(NSSet *)touches {
    UITouch *touch = touches.anyObject;
    CGPoint point = [touch locationInView:self];
    NSIndexPath *indexPath = [self indexPathForItemAtPoint:point];
    if (indexPath) {
        EmoticonCell *cell = (id)[self cellForItemAtIndexPath:indexPath];
        return cell;
    }
    return nil;
}

#pragma mark -
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    EmoticonCell *cell = [self cellForTouches:touches];
    [self showMagnifierForCell:cell];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    EmoticonCell *cell = [self cellForTouches:touches];
    [self showMagnifierForCell:cell];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    EmoticonCell *cell = [self cellForTouches:touches];
    if ([self.delegate respondsToSelector:@selector(emoticonDidTapCell:)]) {
        [((id<EmoticonTapDelegate>) self.delegate) emoticonDidTapCell:cell];
    }
    [self hideMagnifier];
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [self hideMagnifier];
}

@end
