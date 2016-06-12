//
//  EmoticonModel.m
//  WXWeibo
//
//  Created by JayWon on 15/11/25.
//  Copyright © 2015年 JayWon. All rights reserved.
//

#import "EmoticonModel.h"

@implementation EmoticonModel

+(NSArray *)modelPropertyBlacklist {
    return @[@"group"];
}

@end


@implementation EmoticonGroup

//自定义属性的映射关系（attribute ：json key）
+(NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"groupID" :     @"id",
             @"nameCN" :      @"group_name_cn",
             @"nameEN" :      @"group_name_en",
             @"nameTW" :      @"group_name_tw",
             @"displayOnly" : @"display_only",
             @"groupType" :   @"group_type"
             };
}

//容器里对象映射
+(NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"emoticons" : [EmoticonModel class]};
}

-(void)modelCustomTransformFromDictionary:(NSDictionary *)dic {
    [_emoticons enumerateObjectsUsingBlock:^(EmoticonModel *emoticon, NSUInteger idx, BOOL *stop) {
        emoticon.group = self;
    }];
}

@end
