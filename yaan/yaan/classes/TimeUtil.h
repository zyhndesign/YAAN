//
//  TimeUtil.h
//  JiangHomeStyle
//
//  Created by 工业设计中意（湖南） on 13-9-6.
//  Copyright (c) 2013年 cidesign. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TimeUtil : NSObject
//将1970后的毫秒值转为年月日
+(NSString*) convertTimeFormat:(NSString *)data;
@end
