//
//  UserModel.m
//  WXWeibo
//
//  Created by JayWon on 15/10/23.
//  Copyright (c) 2015年 JayWon. All rights reserved.
//

#import "UserModel.h"

@implementation UserModel

//设置特殊属性的映射关系（attribute ：json key）
+ (NSDictionary *)modelCustomPropertyMapper {
    return  @{
              @"desc" : @"description"
             };
}

@end
