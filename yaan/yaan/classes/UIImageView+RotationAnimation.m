//
//  UIImageView+RotationAnimation.m
//  JiangHomeStyle
//
//  Created by 工业设计中意（湖南） on 13-10-10.
//  Copyright (c) 2013年 cidesign. All rights reserved.
//

#import "UIImageView+RotationAnimation.h"

@implementation UIImageView (RotationAnimation)

-(void) addRotationClockWise:(int)duration andAngle:(double) angle andRepeat:(int) repeatCount
{
    CABasicAnimation* rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * angle ];
    rotationAnimation.duration = duration;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = repeatCount;
    [self.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

-(void) addRotationAntiClockWise:(int)duration andAngle:(double) angle andRepeat:(int) repeatCount
{
    CABasicAnimation* rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * angle * -1];
    rotationAnimation.duration = duration;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = repeatCount;
    [self.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}
@end
