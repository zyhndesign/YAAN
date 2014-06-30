//
//  UIImageView+RotationAnimation.h
//  JiangHomeStyle
//
//  Created by 工业设计中意（湖南） on 13-10-10.
//  Copyright (c) 2013年 cidesign. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (RotationAnimation)
-(void) addRotationClockWise:(int)duration andAngle:(double) angle andRepeat:(int) repeatCount;

-(void) addRotationAntiClockWise:(int)duration andAngle:(double) angle andRepeat:(int) repeatCount;
@end
