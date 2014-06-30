//
//  TimeUtil.m
//  JiangHomeStyle
//
//  Created by 工业设计中意（湖南） on 13-9-6.
//  Copyright (c) 2013年 cidesign. All rights reserved.
//

#import "TimeUtil.h"

@implementation TimeUtil
+(NSString*) convertTimeFormat:(NSString *)data
{
    NSDateFormatter* dateFormat = [NSDateFormatter new];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:([data longLongValue] / 1000)];
    return [dateFormat stringFromDate:date];
}
@end
