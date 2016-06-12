//
//  ThemeManager.m
//  WXWeibo
//
//  Created by JayWon on 15/10/21.
//  Copyright (c) 2015年 JayWon. All rights reserved.
//

#import "ThemeManager.h"

//定义一个默认的主题
#define kDefaultThemeName   @"猫爷"
#define kThemeNameKey   @"kThemeNameKey"

@implementation ThemeManager

+(instancetype)shareManager
{
    static ThemeManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[super allocWithZone:nil] init];
    });
    
    return instance;
}

-(id)copy {
    return self;
}

+(instancetype)allocWithZone:(struct _NSZone *)zone {
    return [self shareManager];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        //1、初始化 themeDic
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"theme" ofType:@"plist"];
        self.themeDic = [NSDictionary dictionaryWithContentsOfFile:filePath];
        
        //2、初始化 themeName，使用NSUserDefaults存储主题的名字
        NSString *themeName = [[NSUserDefaults standardUserDefaults] objectForKey:kThemeNameKey];
        if (themeName) {
            self.themeName = themeName;
        }else{
            self.themeName = kDefaultThemeName;
        }
        
        //3、初始化 fontColorDic，放这不合适。每个主题都有这个配置文件，只要切换了主题，fontColorDic就需要重新读取。程序第一次启动的时候，第2步使用self.themeName 方式赋值 一举两得, 既设置了主题名字，又初始化了 fontColorDic
    }
    return self;
}

//主题文件夹的完整路径
-(NSString *)themePath
{
    NSString *bdPath = [[NSBundle mainBundle] pathForResource:@"Skin" ofType:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:bdPath];

    NSString *themePath = _themeDic[_themeName];
    return [bundle.resourcePath stringByAppendingPathComponent:themePath];
}

-(void)setThemeName:(NSString *)themeName
{
    if (_themeName != themeName) {
        _themeName = [themeName copy];
        
        //3、初始化 fontColorDic（每个主题都有这个文件，只要切换了主题，fontColorDic就需要重新读取）
        NSString *fontFilePath = [[self themePath] stringByAppendingPathComponent:@"config.plist"];
        self.fontColorDic = [NSDictionary dictionaryWithContentsOfFile:fontFilePath];
        
        //保存主题
        [[NSUserDefaults standardUserDefaults] setObject:_themeName forKey:kThemeNameKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

-(UIImage *)loadImageWithImgName:(NSString *)imgName
{
    NSString *imgPath = [[self themePath] stringByAppendingPathComponent:imgName];
    return [UIImage imageWithContentsOfFile:imgPath];
}

-(UIImage *)loadThemeImageWithThemeName:(NSString *)themeName
{
    NSString *bdPath = [[NSBundle mainBundle] pathForResource:@"Skin" ofType:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:bdPath];
    NSString *themePath = [bundle.resourcePath stringByAppendingPathComponent:_themeDic[themeName]];
    NSString *filePath = [themePath stringByAppendingPathComponent:@"more_icon_theme@2x.png"];
    return [UIImage imageWithContentsOfFile:filePath];
}

-(UIColor *)loadColorWithKeyName:(NSString *)colorName
{
    NSDictionary *rgbDic = _fontColorDic[colorName];
    if (rgbDic.count < 3) {
        return nil;
    }
    
    CGFloat red = [rgbDic[@"R"] floatValue];
    CGFloat green = [rgbDic[@"G"] floatValue];
    CGFloat blue = [rgbDic[@"B"] floatValue];
    NSNumber *alphaNum = rgbDic[@"alpha"];
    CGFloat alpha = alphaNum ? [alphaNum floatValue] : 1;
    
    return [UIColor colorWithRed:red/255 green:green/255 blue:blue/255 alpha:alpha];
}

@end
