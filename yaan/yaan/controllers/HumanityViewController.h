//
//  HumanityViewController.h
//  NewTD
//
//  Created by 工业设计中意（湖南） on 14-5-13.
//  Copyright (c) 2014年 中意工业设计（湖南）有限责任公司. All rights reserved.
//

#import "ColumnViewController.h"

@interface HumanityViewController : ColumnViewController
{
    IBOutlet UIImageView *animationLeftImg;
    IBOutlet UIImageView *animationBottomImg;
    IBOutlet UIImageView *animationTopImg;
}

@property (nonatomic, strong) IBOutlet UIImageView *animationLeftImg;
@property (nonatomic, strong) IBOutlet UIImageView *animationBottomImg;
@property (nonatomic, strong) IBOutlet UIImageView *animationTopImg;

- (IBAction)pageChange:(id)sender;
@end
