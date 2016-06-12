//
//  CommentCell.m
//  WXWeibo
//
//  Created by JayWon on 15/10/28.
//  Copyright (c) 2015年 JayWon. All rights reserved.
//

#import "CommentCell.h"
#import "UIImageView+WebCache.h"
#import "WebViewController.h"
#import "UIView+ViewController.h"

@implementation CommentCell

- (void)awakeFromNib {
    _userHeaderImgView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didClickUser)];
    [_userHeaderImgView addGestureRecognizer:tap];
    
    // Initialization code
    _usernameLabel.colorKeyName = @"Timeline_Name_color";
    _cmTimeLabel.colorKeyName = @"Timeline_TimeNew_color";
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setLayout:(CommentCellLayout *)layout
{
    if (_layout != layout) {
        _layout = layout;
        
        [_userHeaderImgView sd_setImageWithURL:[NSURL URLWithString:_layout.cmmtModel.user.profile_image_url]];
        _usernameLabel.text = _layout.cmmtModel.user.screen_name;
        _cmTimeLabel.text = [WeiboHelper parseDateStr:_layout.cmmtModel.created_at];
        self.cmmtTextLabel.text = _layout.cmmtModel.text;
        
        self.cmmtTextLabel.frame = _layout.textFrame;
    }
}

@synthesize cmmtTextLabel = _cmmtTextLabel;
-(WXLabel *)cmmtTextLabel
{
    if (!_cmmtTextLabel) {
        _cmmtTextLabel = [[WXLabel alloc] initWithFrame:CGRectZero];
        _cmmtTextLabel.wxLabelDelegate = self;
        _cmmtTextLabel.linespace = kCmmtTextLinespace;
        _cmmtTextLabel.numberOfLines = 0;
        _cmmtTextLabel.font = [UIFont systemFontOfSize:kCmmtFontSize];
        [self.contentView addSubview:_cmmtTextLabel];
    }
    
    return _cmmtTextLabel;
}

#pragma mark - WXLabel Delegate
//返回正则表达式匹配的字符串
- (NSString *)contentsOfRegexStringWithWXLabel:(WXLabel *)wxLabel {
    
    NSString *regEx1 = @"http://([a-zA-Z0-9_.-]+(/)?)+";
    NSString *regEx2 = @"@[\\w.-]{2,30}";
    NSString *regEx3 = @"#[^#]+#";
    
    NSString *regEx =
    [NSString stringWithFormat:@"(%@)|(%@)|(%@)", regEx1, regEx2, regEx3];
    
    return regEx;
}

//设置链接文本的颜色
- (UIColor *)linkColorWithWXLabel:(WXLabel *)wxLabel {
    
    return [[ThemeManager shareManager] loadColorWithKeyName:@"Link_color"];
}

- (void)toucheEndWXLabel:(WXLabel *)wxLabel withContext:(NSString *)context
{
    NSString *urlStr = nil;
    if ([context hasPrefix:@"@"]) {
        urlStr = [NSString stringWithFormat:@"http://m.weibo.cn/n/%@", [[context substringFromIndex:1] URLEncodedString]];
    }else if ([context hasPrefix:@"#"]){
        urlStr = [NSString stringWithFormat:@"http://m.weibo.cn/k/%@", [[context substringWithRange:NSMakeRange(1, context.length-2)] URLEncodedString]];
    }else if ([context hasPrefix:@"http"]){
        urlStr = context;
    }
    if (urlStr) {
        WebViewController *webCtrl = [[WebViewController alloc] initWithURL:[NSURL URLWithString:urlStr]];
        [self.viewController.navigationController pushViewController:webCtrl animated:YES];
    }
}

-(void)didClickUser
{
    if (_layout.cmmtModel.user.id == 0) return;
    NSString *urlStr = [NSString stringWithFormat:@"http://m.weibo.cn/u/%lld",_layout.cmmtModel.user.id];
    WebViewController *webCtrl = [[WebViewController alloc] initWithURL:[NSURL URLWithString:urlStr]];
    [self.viewController.navigationController pushViewController:webCtrl animated:YES];
}
@end
