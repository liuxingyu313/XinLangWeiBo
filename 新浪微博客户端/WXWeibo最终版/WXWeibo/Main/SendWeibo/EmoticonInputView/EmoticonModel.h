//
//  EmoticonModel.h
//  WXWeibo
//
//  Created by JayWon on 15/11/25.
//  Copyright © 2015年 JayWon. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, EmoticonType) {
    EmoticonTypeImage = 0,    // 图片表情
    EmoticonTypeEmoji = 1,    // Emoji表情
};

//一个表情对象
@class EmoticonGroup;
@interface EmoticonModel : NSObject

@property (nonatomic, strong) NSString *chs;        // [吃惊]
@property (nonatomic, strong) NSString *cht;        // [吃驚]
@property (nonatomic, strong) NSString *gif;        // d_chijing.gif
@property (nonatomic, strong) NSString *png;        // d_chijing.png
@property (nonatomic, strong) NSString *code;       // 0x1f60d
@property (nonatomic, assign) EmoticonType type;
@property (nonatomic, weak) EmoticonGroup *group;   // 所在分组

@end


//表情组.对应分组表情包里面的info.plist
@interface EmoticonGroup : NSObject

@property (nonatomic, strong) NSString  *groupID;       // com.apple.emoji
@property (nonatomic, assign) NSInteger version;
@property (nonatomic, strong) NSString  *nameCN;
@property (nonatomic, strong) NSString  *nameEN;
@property (nonatomic, strong) NSString  *nameTW;
@property (nonatomic, assign) NSInteger displayOnly;
@property (nonatomic, assign) NSInteger groupType;
@property (nonatomic, strong) NSArray   *emoticons;     // Array<EmoticonModel>

@end
