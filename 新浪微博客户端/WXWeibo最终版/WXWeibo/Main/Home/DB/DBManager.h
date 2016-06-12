//
//  DBManager.h
//  WXWeibo
//
//  Created by liuwei on 15/12/3.
//  Copyright © 2015年 JayWon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DBManager : NSObject
+ (instancetype)shareManager;

- (void)statusesWithParams:(NSDictionary *)params success:(void (^)(NSArray *results))successBlock;

- (void)saveStatuses:(NSArray *)statuses;

@end
