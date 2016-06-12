//
//  EmoticonInputView.h
//  WXWeibo
//
//  Created by JayWon on 15/11/25.
//  Copyright © 2015年 JayWon. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kEmoticonInputViewBgColor [UIColor colorWithRed:249/255.0 green:249/255.0 blue:249/255.0 alpha:1.0]
#define kSeparatorColor [UIColor colorWithRed:191/255.0 green:191/255.0 blue:191/255.0 alpha:1.0]

#define kEmoticonViewHeight 216     //表情键盘的高度
#define kToolbarHeight      37      //SegmentedControl高度

@protocol EmoticonInputDelegate <NSObject>
@optional
-(void)emoticonInputDidTapText:(NSString *)text;
-(void)emoticonInputDidTapBackspace;
@end

@interface EmoticonInputView : UIView
@property (nonatomic, weak) id<EmoticonInputDelegate> delegate;
@end
