//
//  ViewController.h
//  yaan
//
//  Created by 工业设计中意（湖南） on 14-6-30.
//  Copyright (c) 2014年 中意工业设计（湖南）有限责任公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SuperColumnViewController;
@class FooterViewController;
@class MusicViewController;

@interface ViewController : UIViewController<UIScrollViewDelegate>
{
    IBOutlet UIScrollView *mainScrollView;
    
    SuperColumnViewController *homeViewController;
    SuperColumnViewController *landscapeViewController;
    SuperColumnViewController *humanityViewController;
    SuperColumnViewController *storyViewController;
    SuperColumnViewController *communityViewController;
    FooterViewController *footerViewController;
    
    MusicViewController *musicViewController;
    
    IBOutlet UIImageView *menuViewBtn;
    IBOutlet UIImageView *musicBtn;
    IBOutlet UIView *menuPanel;
    /**
     *  在ScrollView 中各个栏目Y坐标值
     */
    int landscapeYValue;
    int humanityYValue;
    int storyYValue;
    int communityYValue;
    
    IBOutlet UIButton *recommendBtn;
    IBOutlet UIButton *landscapeBtn;
    IBOutlet UIButton *humanityBtn;
    IBOutlet UIButton *storyBtn;
    IBOutlet UIButton *communityBtn;
    
}
@property (strong, nonatomic) IBOutlet UIScrollView *mainScrollView;
@property (strong, nonatomic) IBOutlet UIImageView *menuViewBtn;
@property (strong, nonatomic) IBOutlet UIView *menuPanel;
@property (strong, nonatomic) IBOutlet UIImageView *musicBtn;

@property (strong, nonatomic) IBOutlet UIButton *recommendBtn;
@property (strong, nonatomic) IBOutlet UIButton *landscapeBtn;
@property (strong, nonatomic) IBOutlet UIButton *humanityBtn;
@property (strong, nonatomic) IBOutlet UIButton *storyBtn;
@property (strong, nonatomic) IBOutlet UIButton *communityBtn;


- (IBAction)recommandBtnClick:(id)sender;
- (IBAction)landscapeBtnClick:(id)sender;
- (IBAction)humanityBtnClick:(id)sender;
- (IBAction)storyBtnClick:(id)sender;
- (IBAction)communityBtnClick:(id)sender;
@end
