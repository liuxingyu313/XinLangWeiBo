//
//  WeiboHelper.h
//  WXWeibo
//
//  Created by JayWon on 15/11/10.
//  Copyright © 2015年 JayWon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WeiboHelper : NSObject

+(NSBundle *)resourceBundle;
+(NSBundle *)ringtoneBundle;
+(NSBundle *)emoticonBundle;

+(NSString *)shortedNumberDesc:(NSUInteger)number;
+(NSString *)parseDateStr:(NSString *)dateStr;
+(NSString *)parseWeoboSource:(NSString *)sourceStr;

#pragma mark - HUD
+(void)showSuccessHUD:(NSString *)title withDelayHideTime:(NSTimeInterval)delay;
+(void)showFailHUD:(NSString *)title withDelayHideTime:(NSTimeInterval)delay withView:(UIView *)view;

@end
