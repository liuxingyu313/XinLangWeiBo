//
//  ThemeManager.h
//  WXWeibo
//
//  Created by JayWon on 15/10/21.
//  Copyright (c) 2015年 JayWon. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kThemeDidChangeNotification   @"kThemeDidChangeNotification"

@interface ThemeManager : NSObject

//当前主题的名字
@property(nonatomic, copy)NSString *themeName;

//当前主题的字典，主题名字对应的主题路径
@property(nonatomic, copy)NSDictionary *themeDic;

//主题颜色配置文件
@property(nonatomic, copy)NSDictionary *fontColorDic;


+(instancetype)shareManager;

/**
 *  根据图片文件所在的路径读取图片
 *
 *  @param imgName 主题图片的名字，必须提供完整的图片名字（带后缀）
 *
 *  @return 
 */
-(UIImage *)loadImageWithImgName:(NSString *)imgName;
-(UIColor *)loadColorWithKeyName:(NSString *)colorName;

//ThemeTableViewController cell里面的主题图片
-(UIImage *)loadThemeImageWithThemeName:(NSString *)themeName;

@end
