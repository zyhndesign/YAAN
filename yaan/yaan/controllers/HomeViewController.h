//
//  HomeViewController.h
//  NewTD
//
//  Created by 工业设计中意（湖南） on 14-5-13.
//  Copyright (c) 2014年 中意工业设计（湖南）有限责任公司. All rights reserved.
//

#import "SuperColumnViewController.h"

@interface HomeViewController : SuperColumnViewController
{
    
    IBOutlet UIImageView *homeTopBackground;
    
    IBOutlet UIControl *secondViewPanel;
    IBOutlet UIImageView *secondArticleThumb;
    IBOutlet UILabel *secondArticleTitleLabel;
    IBOutlet UILabel *secondArticleSummaryLabel;
    
    IBOutlet UIControl *threeViewPanel;
    IBOutlet UIImageView *threeArticleThumb;
    IBOutlet UILabel *threeArticleTitleLabel;
    IBOutlet UILabel *threeArticleSummaryLabel;
    
    IBOutlet UIControl *fourViewPanel;
    IBOutlet UIImageView *fourArticleThumb;
    IBOutlet UILabel *fourArticleTitleLabel;
    IBOutlet UILabel *fourArticleSummaryLabel;
    
    IBOutlet UIImageView *animationLeftImg;    
    IBOutlet UIImageView *animationRightImg;
}
@property (nonatomic, strong) IBOutlet UIImageView *homeTopBackground;

@property (nonatomic, strong) IBOutlet UIView *secondViewPanel;
@property (nonatomic, strong) IBOutlet UIImageView *secondArticleThumb;
@property (nonatomic, strong) IBOutlet UILabel *secondArticleTitleLabel;
@property (nonatomic, strong) IBOutlet UILabel *secondArticleSummaryLabel;

@property (nonatomic, strong) IBOutlet UIView *threeViewPanel;
@property (nonatomic, strong) IBOutlet UIImageView *threeArticleThumb;
@property (nonatomic, strong) IBOutlet UILabel *threeArticleTitleLabel;
@property (nonatomic, strong) IBOutlet UILabel *threeArticleSummaryLabel;

@property (nonatomic, strong) IBOutlet UIView *fourViewPanel;
@property (nonatomic, strong) IBOutlet UIImageView *fourArticleThumb;
@property (nonatomic, strong) IBOutlet UILabel *fourArticleTitleLabel;
@property (nonatomic, strong) IBOutlet UILabel *fourArticleSummaryLabel;

@property (nonatomic, strong) IBOutlet UIImageView *animationLeftImg;
@property (nonatomic, strong) IBOutlet UIImageView *animationRightImg;

@end
