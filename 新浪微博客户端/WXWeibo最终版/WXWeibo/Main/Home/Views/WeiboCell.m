//
//  WeiboCell.m
//  WXWeibo
//
//  Created by JayWon on 15/10/23.
//  Copyright (c) 2015年 JayWon. All rights reserved.
//

#import "WeiboCell.h"
#import "UIImageView+WebCache.h"
#import <QuartzCore/QuartzCore.h>
#import "UIView+ViewController.h"
#import "WebViewController.h"

@implementation WeiboCell

- (void)awakeFromNib {
    
    userHeadImg.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didClickUser)];
    [userHeadImg addGestureRecognizer:tap];
    
    //设置头像的圆角、边框
    userHeadImg.layer.cornerRadius = 5;
    userHeadImg.layer.borderWidth = 0.5;
    userHeadImg.layer.borderColor = [UIColor grayColor].CGColor;
    userHeadImg.layer.masksToBounds = YES;
    
    
    nickNameLabel.colorKeyName = @"Timeline_Name_color";
    timeLabel.colorKeyName = @"Timeline_TimeNew_color";
    sourceLabel.colorKeyName = @"Timeline_Retweet_color";
}


-(void)setLayout:(WeiboCellLayout *)layout
{
    if (_layout != layout) {
        _layout = layout;
        
        //1、头像、昵称赋值
        [userHeadImg sd_setImageWithURL:[NSURL URLWithString:_layout.weiboModel.user.profile_image_url]];
        nickNameLabel.text = _layout.weiboModel.user.screen_name;
        timeLabel.text = [WeiboHelper parseDateStr:_layout.weiboModel.created_at];
        sourceLabel.text = [WeiboHelper parseWeoboSource:_layout.weiboModel.source];
        
        //2、微博正文赋值
        self.weiboTextLabel.text = _layout.weiboModel.text;

        //3、微博多图赋值
        [self showImgs:self.layout.weiboModel.pic_urls];
        
        if (_layout.weiboModel.retweeted_status) {
            //4、转发微博背景赋值
            self.retweetBgImgView.edgeInset = UIEdgeInsetsMake(10, 30, 10, 10);
            self.retweetBgImgView.imgName = @"timeline_rt_border_9@2x.png";

            //5、转发微博的文字赋值
            self.retweetTextLabel.text = _layout.weiboModel.retweeted_status.text;
            
            //6、转发微博多图赋值，与第3步 微博多图赋值 存在业务上的互斥，两个showImgs调用只会执行一个（转发微博有图的时候微博就不会有图，微博有图的时候转发微博就不会有图）
            [self showImgs:self.layout.weiboModel.retweeted_status.pic_urls];
        }
        
        //所有cell的subview赋值frame
        [self setCellSubviewFrame];
    }
}

//微博图片赋值
-(void)showImgs:(NSArray *)imgsArr
{
    for (int i=0; i<imgsArr.count; i++) {
        UIImageView *imgView = self.imgViewArr[i];
        NSString *imgUrlStr = imgsArr[i][@"thumbnail_pic"];
        [imgView sd_setImageWithURL:[NSURL URLWithString:imgUrlStr]];
    }
}

//不管微博 有没有图片或者转发微博，cell的重用需要给subview重新赋值frame
-(void)setCellSubviewFrame
{
    self.weiboTextLabel.frame = _layout.textFrame;
    self.retweetBgImgView.frame = _layout.retweetBgFrame;
    self.retweetTextLabel.frame = _layout.retweetTextFrame;
    
    //给9个imgview重新赋值frame（有图的赋值正确的frame；没图的赋值CGRectZero，达到隐藏的目的）
    for (int i=0; i<self.imgViewArr.count; i++) {
        UIImageView *imgView = self.imgViewArr[i];
        imgView.frame = [self.layout.imgFrameArr[i] CGRectValue];
    }
}

#pragma mark - UI初始化
@synthesize weiboTextLabel = _weiboTextLabel;
@synthesize retweetBgImgView = _retweetBgImgView;
@synthesize retweetTextLabel = _retweetTextLabel;

@synthesize imgViewArr = _imgViewArr;

-(WXLabel *)weiboTextLabel
{
    if (!_weiboTextLabel) {
        _weiboTextLabel = [[WXLabel alloc] initWithFrame:CGRectZero];
        _weiboTextLabel.wxLabelDelegate = self;
        _weiboTextLabel.font = [UIFont systemFontOfSize:kTextSize];
        _weiboTextLabel.linespace = kTextLineSpace;
        [self.contentView addSubview:_weiboTextLabel];
    }
    
    return _weiboTextLabel;
}

-(ThemeImgView *)retweetBgImgView
{
    if (!_retweetBgImgView) {
        _retweetBgImgView = [[ThemeImgView alloc] init];
        [self.contentView insertSubview:_retweetBgImgView atIndex:0];
    }
    
    return _retweetBgImgView;
}

-(WXLabel *)retweetTextLabel
{
    if (!_retweetTextLabel) {
        _retweetTextLabel = [[WXLabel alloc] initWithFrame:CGRectZero];
        _retweetTextLabel.wxLabelDelegate = self;
        _retweetTextLabel.font = [UIFont systemFontOfSize:kRetweetTextSize];
        _retweetTextLabel.linespace = kRetweetTextLineSpace;
        [self.contentView addSubview:_retweetTextLabel];
    }
    
    return _retweetTextLabel;
}

-(NSMutableArray *)imgViewArr
{
    if (!_imgViewArr) {
        _imgViewArr = [[NSMutableArray alloc] init];
        
        for (int i=0; i<9; i++) {
            UIImageView *imgView = [[UIImageView alloc] init];
            imgView.contentMode = UIViewContentModeScaleAspectFill; //缩放填满
            imgView.clipsToBounds = YES;                            //超出部分裁剪
            imgView.tag = i;
            [self.contentView addSubview:imgView];
            [_imgViewArr addObject:imgView];
            
            //单击手势,显示相册
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
            imgView.userInteractionEnabled = YES;
            imgView.tag = i;
            [imgView addGestureRecognizer:tap];
        }
    }
    
    return _imgViewArr;
}
-(void)tapAction:(UITapGestureRecognizer *)tap{
    //显示相册
    [WXPhotoBrowser showImageInView:self.window.rootViewController.view selectImageIndex:tap.view.tag delegate:self];
}

#pragma mark - PhotoBrowserDelegate
-(NSUInteger)numberOfPhotosInPhotoBrowser:(WXPhotoBrowser *)photoBrowser {
    
    return self.layout.weiboModel.pic_urls.count ? : self.layout.weiboModel.retweeted_status.pic_urls.count;
}
-(WXPhoto *)photoBrowser:(WXPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    
    NSArray *urls = nil;
    WeiboModel *model = self.layout.weiboModel;
    if (model.pic_urls.count != 0) {
        urls = model.pic_urls;
    }else if(model.retweeted_status.pic_urls.count != 0){
        urls = model.retweeted_status.pic_urls;
    }
    //替换为大图
    NSString *url = [urls[index][@"thumbnail_pic"] stringByReplacingOccurrencesOfString:@"thumbnail" withString:@"large"];
    
    WXPhoto *photo = [[WXPhoto alloc] init];
    //原始的imageView
    photo.srcImageView = self.imgViewArr[index];
    //大图的url
    photo.url = [NSURL URLWithString:url];
    return photo;
}


#pragma mark - WXLabel Delegate
//返回正则表达式匹配的字符串
-(NSString *)contentsOfRegexStringWithWXLabel:(WXLabel *)wxLabel
{
    NSString *regEx1 = @"http://([a-zA-Z0-9_.-]+(/)?)+";
    NSString *regEx2 = @"@[\\w.-]{2,30}";
    NSString *regEx3 = @"#[^#]+#";
    
    NSString *regEx =
    [NSString stringWithFormat:@"(%@)|(%@)|(%@)", regEx1, regEx2, regEx3];
    
    return regEx;
}

//设置链接文本的颜色
-(UIColor *)linkColorWithWXLabel:(WXLabel *)wxLabel
{
    return [[ThemeManager shareManager] loadColorWithKeyName:@"Link_color"];
}

-(void)toucheEndWXLabel:(WXLabel *)wxLabel withContext:(NSString *)context
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
    if (_layout.weiboModel.user.id == 0) return;
    NSString *urlStr = [NSString stringWithFormat:@"http://m.weibo.cn/u/%lld",_layout.weiboModel.user.id];
    WebViewController *webCtrl = [[WebViewController alloc] initWithURL:[NSURL URLWithString:urlStr]];
    [self.viewController.navigationController pushViewController:webCtrl animated:YES];
}

@end
