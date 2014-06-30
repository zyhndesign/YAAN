//
//  ViewController.m
//  yaan
//
//  Created by 工业设计中意（湖南） on 14-6-30.
//  Copyright (c) 2014年 中意工业设计（湖南）有限责任公司. All rights reserved.
//

#import "ViewController.h"
#import "libs/googleAnalytics/GAI.h"
#import "libs/googleAnalytics/GAIDictionaryBuilder.h"
#import "controllers/HomeViewController.h"
#import "controllers/LandscapeViewController.h"
#import "controllers/HumanityViewController.h"
#import "controllers/StoryViewController.h"
#import "controllers/FooterViewController.h"
#import "controllers/CommunityViewController.h"
#import "controllers/MusicViewController.h"

@interface ViewController ()

@end

@implementation ViewController

@synthesize mainScrollView, musicBtn, menuPanel, menuViewBtn;
@synthesize recommendBtn, landscapeBtn, humanityBtn, storyBtn, communityBtn;


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    // Do any additional setup after loading the view, typically from a nib.
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    [[GAI sharedInstance].defaultTracker set:@"main view"
                                       value:@"ViewController Screen"];
    
    // Send the screen view.
    [[GAI sharedInstance].defaultTracker send:[[GAIDictionaryBuilder createAppView] build]];
    
    mainScrollView.backgroundColor = [UIColor blackColor];
    
    CGRect screenBounds = [[UIScreen mainScreen]bounds];
    
    NSBundle* mainBundle = [NSBundle mainBundle];
    
    CGFloat originHeight = 0.0;
    
    homeViewController = [[HomeViewController new] initWithNibName:@"HomeBoard" bundle:mainBundle];
    CGSize homeCGSize = homeViewController.view.frame.size;
    [mainScrollView addSubview:homeViewController.view];
    [self addChildViewController:homeViewController];
    
    
    landscapeViewController = [[LandscapeViewController new] initWithNibName:@"LandscapeBoard" bundle:mainBundle];
    CGSize landscapeCGSize = landscapeViewController.view.frame.size;
    originHeight = originHeight + homeCGSize.height;
    landscapeViewController.view.frame = CGRectMake(0, originHeight,landscapeCGSize.width,landscapeCGSize.height);
    landscapeYValue = originHeight;
    [mainScrollView addSubview:landscapeViewController.view];
    [self addChildViewController:landscapeViewController];
    
    humanityViewController = [[HumanityViewController new] initWithNibName:@"HumanityBoard" bundle:mainBundle];
    CGSize humanityCGSize = humanityViewController.view.frame.size;
    
    originHeight = originHeight + landscapeCGSize.height;
    humanityViewController.view.frame = CGRectMake(0, originHeight,humanityCGSize.width,humanityCGSize.height);
    humanityYValue = originHeight;
    [mainScrollView addSubview:humanityViewController.view];
    [self addChildViewController:humanityViewController];
    
    storyViewController = [[StoryViewController new] initWithNibName:@"StoryBoard" bundle:mainBundle];
    CGSize storyCGSize = storyViewController.view.frame.size;
    
    originHeight = originHeight + humanityCGSize.height;
    storyViewController.view.frame = CGRectMake(0, originHeight,storyCGSize.width,storyCGSize.height);
    storyYValue = originHeight;
    [mainScrollView addSubview:storyViewController.view];
    [self addChildViewController:storyViewController];
    
    communityViewController = [[CommunityViewController new] initWithNibName:@"CommunityBoard" bundle:mainBundle];
    CGSize communityCGSize = communityViewController.view.frame.size;
    
    originHeight = originHeight + storyCGSize.height;
    communityViewController.view.frame = CGRectMake(0, originHeight,communityCGSize.width,communityCGSize.height);
    communityYValue = originHeight;
    [mainScrollView addSubview:communityViewController.view];
    [self addChildViewController:communityViewController];
    
    //NSArray *nibFooterView = [mainBundle loadNibNamed:@"Footer" owner:self options:nil];
    //UIView *footerView = [nibFooterView objectAtIndex:0];
    
    footerViewController = [[FooterViewController new] initWithNibName:@"Footer" bundle:mainBundle];
    CGSize footerCGSize = footerViewController.view.frame.size;
    
    originHeight = originHeight + communityCGSize.height;
    footerViewController.view.frame = CGRectMake(0, originHeight,footerCGSize.width,footerCGSize.height);
    [mainScrollView addSubview:footerViewController.view];
    [self addChildViewController:footerViewController];
    
    CGFloat contentSizeHeight = homeCGSize.height +  landscapeCGSize.height + humanityCGSize.height +  storyCGSize.height + communityCGSize.height + footerCGSize.height;
    
    mainScrollView.contentSize = CGSizeMake(screenBounds.size.width, contentSizeHeight);
    //mainScrollView.bounces = NO;
    mainScrollView.delegate = self;
    
    musicViewController = [[MusicViewController new] initWithNibName:@"MusicPlayerView" bundle:mainBundle];
    [musicViewController.view setFrame:CGRectMake(musicBtn.frame.origin.x - musicViewController.view.frame.size.width, musicBtn.frame.origin.y, musicViewController.view.frame.size.width, musicViewController.view.frame.size.height)];
    musicViewController.view.hidden = YES;
    [self.view addSubview:musicViewController.view];
    
    musicBtn.userInteractionEnabled = YES;
    UITapGestureRecognizer *sigTab = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(musicBtnClick)];
    [musicBtn addGestureRecognizer:sigTab];
    
    menuViewBtn.userInteractionEnabled = YES;
    UITapGestureRecognizer *menuTab = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(menuBtnClick)];
    [menuViewBtn addGestureRecognizer:menuTab];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) musicBtnClick
{
    if (musicViewController.view.hidden)
    {
        musicViewController.view.hidden = NO;
        menuPanel.hidden = YES;
    }
    else
    {
        musicViewController.view.hidden = YES;
    }
}

-(void)menuBtnClick
{
    [self.view bringSubviewToFront:menuViewBtn];
    
    if (menuPanel.hidden)
    {
        musicViewController.view.hidden = YES;
        menuPanel.hidden = NO;
    }
    else
    {
        menuPanel.hidden = YES;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)_scrollView
{
    
    CGFloat offsetY = _scrollView.contentOffset.y;
    
    if (offsetY >= landscapeYValue && offsetY < humanityYValue)
    {
        [landscapeBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [humanityBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [storyBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [communityBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [recommendBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [landscapeViewController rootscrollViewDidScrollToPointY: (offsetY - landscapeYValue)];
    }
    else if (offsetY >= humanityYValue && offsetY < storyYValue)
    {
        [humanityBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [storyBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [landscapeBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [communityBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [recommendBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [humanityViewController rootscrollViewDidScrollToPointY:(offsetY - humanityYValue)];
    }
    else if (offsetY >= storyYValue && offsetY < communityYValue)
    {
        [storyBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [humanityBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [landscapeBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [communityBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [recommendBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [storyViewController rootscrollViewDidScrollToPointY:(offsetY - storyYValue)];
    }
    else if (offsetY >= communityYValue)
    {
        [communityBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [humanityBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [storyBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [landscapeBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [recommendBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [communityViewController rootscrollViewDidScrollToPointY:(offsetY - communityYValue)];
    }
    else if (offsetY < landscapeYValue)
    {
        [landscapeBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [humanityBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [storyBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [communityBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [recommendBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        [homeViewController rootscrollViewDidScrollToPointY:offsetY];
    }
    
}

- (IBAction)recommandBtnClick:(id)sender
{
    [mainScrollView setContentOffset:CGPointMake(mainScrollView.frame.origin.x, 768) animated:YES];
    [landscapeBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [humanityBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [storyBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [communityBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [recommendBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
}

- (IBAction)landscapeBtnClick:(id)sender
{
    [mainScrollView setContentOffset:CGPointMake(mainScrollView.frame.origin.x, landscapeYValue) animated:YES];
    [landscapeBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [humanityBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [storyBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [communityBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [recommendBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    
}

- (IBAction)humanityBtnClick:(id)sender
{
    [mainScrollView setContentOffset:CGPointMake(mainScrollView.frame.origin.x, humanityYValue) animated:YES];
    [humanityBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [storyBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [landscapeBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [communityBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [recommendBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
}

- (IBAction)storyBtnClick:(id)sender
{
    [mainScrollView setContentOffset:CGPointMake(mainScrollView.frame.origin.x, storyYValue) animated:YES];
    [storyBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [humanityBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [landscapeBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [communityBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [recommendBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
}

- (IBAction)communityBtnClick:(id)sender
{
    [mainScrollView setContentOffset:CGPointMake(mainScrollView.frame.origin.x, communityYValue) animated:YES];
    [communityBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [humanityBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [storyBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [landscapeBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [recommendBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
}

@end
