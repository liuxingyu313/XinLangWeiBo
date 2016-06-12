//
//  UserHeaderView.h
//  WXWeibo
//
//  Created by JayWon on 15/11/2.
//  Copyright (c) 2015年 JayWon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserModel.h"
#import "RectButton.h"

@interface UserHeaderView : UIView

@property(nonatomic, strong)UserModel *userModel;

@property (strong, nonatomic) IBOutlet UIImageView *userImgView;
@property (strong, nonatomic) IBOutlet ThemeLabel *nameLabel;
@property (strong, nonatomic) IBOutlet ThemeLabel *addressLabel;
@property (strong, nonatomic) IBOutlet ThemeLabel *infoLabel;
@property (strong, nonatomic) IBOutlet RectButton *attButton;
@property (strong, nonatomic) IBOutlet RectButton *fansButton;
@property (strong, nonatomic) IBOutlet RectButton *infoButton;
@property (strong, nonatomic) IBOutlet RectButton *moreButton;
@property (strong, nonatomic) IBOutlet ThemeLabel *countLabel;

@end
