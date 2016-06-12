//
//  DBManager.m
//  WXWeibo
//
//  Created by liuwei on 15/12/3.
//  Copyright © 2015年 JayWon. All rights reserved.
//

#import "DBManager.h"
#import "FMDB.h"
static DBManager* instance = nil;

@implementation DBManager {
  FMDatabaseQueue* _queue;
}

+ (instancetype)shareManager {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    instance = [[self alloc] init];
    [instance setupDB];
  });
  return instance;
}

//打开数据库,创建表
- (void)setupDB {
  _queue = [FMDatabaseQueue
      databaseQueueWithPath:[[NSSearchPathForDirectoriesInDomains(
                                NSDocumentDirectory, NSUserDomainMask, YES)
                                lastObject]
                                stringByAppendingPathComponent:@"status.db"]];
  [_queue inDatabase:^(FMDatabase* db) {
    //创表
    BOOL isSuccess = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS t_statuses "
                                       @"(id integer PRIMARY KEY,status blob "
                                       @"NOT NULL, idstr text NOT NULL);"];
    if (!isSuccess) {
      NSLog(@"创表失败");
    }
  }];
}

//读取微博数据
- (void)statusesWithParams:(NSDictionary*)params
                   success:(void (^)(NSArray* results))successBlock {
  dispatch_async(
      dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [_queue inDatabase:^(FMDatabase* db) {

          NSString* sql = nil;
          if ([params[@"since_id"] integerValue] != 0) {
            sql = [NSString stringWithFormat:@"SELECT *FROM t_statuses WHERE "
                                             @"idstr > %@ ORDER BY idstr "
                                             @"LIMIT 20",
                                             params[@"since_id"]];
          } else if ([params[@"max_id"] integerValue] != 0) {
            sql = [NSString stringWithFormat:@"SELECT *FROM t_statuses WHERE "
                                             @"idstr <= %@ ORDER BY idstr "
                                             @"DESC LIMIT 20",
                                             params[@"max_id"]];
          } else {
            sql = [NSString
                stringWithFormat:
                    @"SELECT *FROM t_statuses ORDER BY idstr DESC LIMIT 20"];
          }

          FMResultSet* set = [db executeQuery:sql];
          NSMutableArray* statuses = [NSMutableArray array];
          while (set.next) {
            NSData* statusData = [set objectForColumnName:@"status"];
            NSDictionary* status =
                [NSKeyedUnarchiver unarchiveObjectWithData:statusData];
            [statuses addObject:status];
          }

          dispatch_async(dispatch_get_main_queue(), ^{

            successBlock(statuses);
          });
        }];
      });
}
//存入微博数据
- (void)saveStatuses:(NSArray*)statuses {
  dispatch_async(
      dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        for (NSDictionary* status in statuses) {
            
            //归档
          NSData* statusData =
              [NSKeyedArchiver archivedDataWithRootObject:status];

          [_queue inDatabase:^(FMDatabase* db) {

            BOOL isSuccess =
                [db executeUpdateWithFormat:
                        @"INSERT INTO t_statuses(status,idstr) VALUES (%@,%@)",
                        statusData, status[@"idstr"]];
            if (isSuccess) {
              //NSLog(@"保存成功");
            }
          }];
        }
      });
}
@end
