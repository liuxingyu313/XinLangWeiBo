//
//  WeiboAnnotation.m
//  WXWeibo
//
//  Created by JayWon on 15/11/2.
//  Copyright (c) 2015年 JayWon. All rights reserved.
//

#import "WeiboAnnotation.h"

@implementation WeiboAnnotation

-(void)setWeiboModel:(WeiboModel *)weiboModel
{
    if (_weiboModel != weiboModel) {
        _weiboModel = weiboModel;
        
        //把WeiboModel里面的经纬度赋值给WeiboAnnotation对象
        NSArray *coordinateArr = weiboModel.geo[@"coordinates"];
        if (coordinateArr.count == 2) {
            float lat = [coordinateArr[0] floatValue];
            float lon = [coordinateArr[1] floatValue];
            
            self.coordinate = CLLocationCoordinate2DMake(lat, lon);
        }
        
    }
}

@end
