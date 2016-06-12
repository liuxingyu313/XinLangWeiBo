//
//  WeiboHelper.m
//  WXWeibo
//
//  Created by JayWon on 15/11/10.
//  Copyright © 2015年 JayWon. All rights reserved.
//

#import "WeiboHelper.h"
#import "MBProgressHUD.h"
#import "NSDate+TimeAgo.h"

@implementation WeiboHelper

+(NSBundle *)resourceBundle
{
    static NSBundle *bundle;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *path = [[NSBundle mainBundle] pathForResource:@"Resource" ofType:@"bundle"];
        bundle = [NSBundle bundleWithPath:path];
    });
    return bundle;
}

+(NSBundle *)ringtoneBundle
{
    static NSBundle *bundle;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *path = [[NSBundle mainBundle] pathForResource:@"Ringtone" ofType:@"bundle"];
        bundle = [NSBundle bundleWithPath:path];
    });
    return bundle;
}

+(NSBundle *)emoticonBundle
{
    static NSBundle *bundle;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"EmoticonWeibo" ofType:@"bundle"];
        bundle = [NSBundle bundleWithPath:bundlePath];
    });
    return bundle;
}

+(NSString *)shortedNumberDesc:(NSUInteger)number
{
    if (number <= 9999)
        return [NSString stringWithFormat:@"%d", (int)number];
    if (number <= 9999999)
        return [NSString stringWithFormat:@"%d万", (int)(number / 10000)];
    return [NSString stringWithFormat:@"%d千万", (int)(number / 10000000)];
}

//Sat Oct 24 14:40:05 +0800 2015
+(NSString *)parseDateStr:(NSString *)dateStr
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSString *format = @"E M d HH:mm:ss Z yyyy";
    [formatter setDateFormat:format];
    
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [formatter setLocale:locale];
    
    NSDate *date = [formatter dateFromString:dateStr];
    return [date timeAgo];
}

//<a href="http://app.weibo.com/t/feed/21gIP7" rel="nofollow">华为 Ascend Mate</a>
+(NSString *)parseWeoboSource:(NSString *)sourceStr
{
    NSUInteger start = [sourceStr rangeOfString:@">"].location;
    NSUInteger end = [sourceStr rangeOfString:@"<" options:NSBackwardsSearch].location;
    
    if (start != NSNotFound && end != NSNotFound) {
        return [sourceStr substringWithRange:NSMakeRange(start+1, end-start-1)];
    }else{
        return sourceStr;
    }
}

#pragma mark - HUD
+(void)showSuccessHUD:(NSString *)title withDelayHideTime:(NSTimeInterval)delay
{
    MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    HUD.labelText = title;
    HUD.mode = MBProgressHUDModeCustomView;
    HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark"]];
    [HUD hide:YES afterDelay:delay];
}

+(void)showFailHUD:(NSString *)title withDelayHideTime:(NSTimeInterval)delay withView:(UIView *)view
{
    MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:view animated:YES];
    HUD.labelText = title;
    HUD.mode = MBProgressHUDModeText;
    [HUD hide:YES afterDelay:delay];
}

@end
