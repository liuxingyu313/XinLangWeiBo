//
//  CommentCellLayout.m
//  WXWeibo
//
//  Created by JayWon on 15/10/30.
//  Copyright (c) 2015年 JayWon. All rights reserved.
//

#import "CommentCellLayout.h"

@implementation CommentCellLayout

-(void)setCmmtModel:(CommentModel *)cmmtModel
{
    if (_cmmtModel != cmmtModel) {
        _cmmtModel = cmmtModel;
        
        [self layoutFrame];
    }
}

-(void)layoutFrame
{
    CGFloat textWidth = kScreenWidth - kCmmtTextX - kLinespace*2;
    CGFloat textHeight = [WXLabel getTextHeight:kCmmtFontSize width:textWidth text:_cmmtModel.text linespace:kCmmtTextLinespace];
    self.textFrame = CGRectMake(kCmmtTextX+kLinespace, kCmmtTextY+kLinespace, textWidth, textHeight);
    self.cellHeight = CGRectGetMaxY(self.textFrame)+kLinespace;
}

@end
