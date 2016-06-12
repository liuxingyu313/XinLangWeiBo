//
//  WeiboAnnotationView.m
//  WXWeibo
//
//  Created by JayWon on 15/11/2.
//  Copyright (c) 2015年 JayWon. All rights reserved.
//

#import "WeiboAnnotationView.h"
#import "UIImageView+WebCache.h"

@implementation WeiboAnnotationView

-(id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initViews];
    }
    
    return self;
}

-(void)initViews
{
    userImgView = [[UIImageView alloc] initWithFrame:CGRectZero];
    userImgView.layer.borderColor = [UIColor whiteColor].CGColor;
    userImgView.layer.borderWidth = 1;
    
    weiboImgView = [[UIImageView alloc] initWithFrame:CGRectZero];
    weiboImgView.backgroundColor = [UIColor blackColor];
    
    textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    textLabel.font = [UIFont systemFontOfSize:12];
    textLabel.textColor = [UIColor whiteColor];
    textLabel.backgroundColor = [UIColor clearColor];
    textLabel.numberOfLines = 3;
    
    [self addSubview:weiboImgView];
    [self addSubview:textLabel];
    [self addSubview:userImgView];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    
    WeiboAnnotation *weiboAtt = self.annotation;
    
    //赋值
    NSString *thumbPic = weiboAtt.weiboModel.thumbnail_pic;
    [weiboImgView sd_setImageWithURL:[NSURL URLWithString:thumbPic]];
    
    NSString *userUrl = weiboAtt.weiboModel.user.profile_image_url;
    [userImgView sd_setImageWithURL:[NSURL URLWithString:userUrl]];
    
    textLabel.text = weiboAtt.weiboModel.text;
    
    //布局
    if (thumbPic) {
        //背景图片
        self.image = [UIImage imageNamed:@"Resource.bundle/nearby_map_photo_bg"];
        textLabel.hidden = YES;
        weiboImgView.hidden = NO;
        
        //用户头像
        userImgView.frame = CGRectMake(73, 68, 30, 30);
        //微博图片
        weiboImgView.frame = CGRectMake(15, 15, 90, 85);
    }else{
        self.image = [UIImage imageNamed:@"Resource.bundle/nearby_map_content"];
        textLabel.hidden = NO;
        weiboImgView.hidden = YES;
        
        //用户头像
        userImgView.frame = CGRectMake(20, 20, 45, 45);
        //微博内容
        textLabel.frame = CGRectMake(CGRectGetMaxX(userImgView.frame) + 5, CGRectGetMinY(userImgView.frame), 110, 45);
    }
}

@end
