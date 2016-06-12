//
//  UserHeaderView.m
//  WXWeibo
//
//  Created by JayWon on 15/11/2.
//  Copyright (c) 2015年 JayWon. All rights reserved.
//

#import "UserHeaderView.h"
#import "UIImageView+WebCache.h"

#define kBtnSize    70

@implementation UserHeaderView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initViews];
    }
    return self;
}

-(void)awakeFromNib
{
    [self initViews];
}

-(void)initViews
{
    _nameLabel.colorKeyName = @"Profile_BG_Text_color";
    _addressLabel.colorKeyName = @"Profile_BG_Text_color";
    _infoLabel.colorKeyName = @"Profile_BG_Text_color";
    _countLabel.colorKeyName = @"Profile_BG_Text_color";
    
    _attButton.backImgName = @"profile_button3_1.png";
    _fansButton.backImgName = @"profile_button3_1.png";
    _infoButton.backImgName = @"profile_button3_1.png";
    _moreButton.backImgName = @"profile_button3_1.png";
    
    
    float btnSpace = (kScreenWidth - 70*4 - 14*2) / 3;
    _attButton.frame = CGRectMake(14, _attButton.frame.origin.y, kBtnSize, kBtnSize);
    _fansButton.frame = CGRectMake(14+kBtnSize+btnSpace, _fansButton.frame.origin.y, kBtnSize, kBtnSize);
    _infoButton.frame = CGRectMake(14+(kBtnSize+btnSpace)*2, _infoButton.frame.origin.y, kBtnSize, kBtnSize);
    _moreButton.frame = CGRectMake(14+(kBtnSize+btnSpace)*3, _moreButton.frame.origin.y, kBtnSize, kBtnSize);
}

-(void)setUserModel:(UserModel *)userModel
{
    if (_userModel != userModel) {
        _userModel = userModel;
        
        //头像
        NSString *urlStr = self.userModel.avatar_large;
        [self.userImgView sd_setImageWithURL:[NSURL URLWithString:urlStr]];
        
        //昵称
        self.nameLabel.text = self.userModel.screen_name;
        
        //性别
        NSString *gender = self.userModel.gender;
        NSString *sexName = @"未知";
        if ([gender isEqualToString:@"m"]) {
            sexName = @"男";
        }else if ([gender isEqualToString:@"f"]){
            sexName = @"女";
        }
        
        
        //地址
        if (!self.userModel.location) {
            self.userModel.location = @"";
        }
        self.addressLabel.text = [NSString stringWithFormat:@"%@ %@", sexName, self.userModel.location];
        
        //简介
        if (![self.userModel.description isEqualToString:@""]) {
            self.infoLabel.text = self.userModel.desc;
        }
        
        //微博数
        int weiboCount = self.userModel.statuses_count;
        self.countLabel.text = [NSString stringWithFormat:@"共%d条微博", weiboCount];
        
        //关注
        self.attButton.title = @"关注";
        self.attButton.subTitle = [WeiboHelper shortedNumberDesc:self.userModel.friends_count];
        
        //粉丝
        self.fansButton.title = @"粉丝";
        self.fansButton.subTitle = [WeiboHelper shortedNumberDesc:self.userModel.followers_count];
    }
}

@end
