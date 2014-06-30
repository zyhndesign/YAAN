//
//  FooterViewController.h
//  NewTD
//
//  Created by 工业设计中意（湖南） on 14-5-13.
//  Copyright (c) 2014年 中意工业设计（湖南）有限责任公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FooterViewController : UIViewController
{
    IBOutlet UIImageView *downloadImageView;
    IBOutlet UILabel *bgTextlabel;
}
@property (strong, nonatomic) IBOutlet UIImageView *downloadImageView;
@property (strong, nonatomic) IBOutlet UILabel *bgTextlabel;
@end
