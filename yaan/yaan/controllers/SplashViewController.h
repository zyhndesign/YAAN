//
//  SplashViewController.h
//  NewTD
//
//  Created by 工业设计中意（湖南） on 14-5-12.
//  Copyright (c) 2014年 中意工业设计（湖南）有限责任公司. All rights reserved.
//

#import "GAITrackedViewController.h"

@interface SplashViewController : GAITrackedViewController
{
    IBOutlet UIActivityIndicatorView *loadActivityIndicator;
}

@property (nonatomic,strong) UIActivityIndicatorView *loadActivityIndicator;

@end
