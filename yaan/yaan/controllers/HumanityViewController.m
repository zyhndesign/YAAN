//
//  HumanityViewController.m
//  NewTD
//
//  Created by 工业设计中意（湖南） on 14-5-13.
//  Copyright (c) 2014年 中意工业设计（湖南）有限责任公司. All rights reserved.
//

#import "HumanityViewController.h"
#import "../classes/DBUtils.h"
#import "../classes/TimeUtil.h"
#import "Constants.h"
#import "VarUtils.h"
#import "../classes/UILabel+VerticalAlign.h"

@interface HumanityViewController ()
{
    int animationLeftImgY;
    int animationBottomImgY;
    int animationTopImgY;
}
@end

@implementation HumanityViewController

@synthesize animationLeftImg, animationBottomImg, animationTopImg;

extern DBUtils *db;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    int countArticle = [db countByCategory:HUMANITY_CATEGORY];
    countPage = (countArticle / HUMANITY_PAGE_INSIDE_NUM);
    if ((countArticle % HUMANITY_PAGE_INSIDE_NUM) > 0)
    {
        countPage = countPage + 1;
    }
    
    columnScrollView = (UIScrollView *)[self.view viewWithTag:150];
    pageControl = (UIPageControl *)[self.view viewWithTag:151];
    
    columnScrollView.contentSize = CGSizeMake(columnScrollView.frame.size.width * countPage, columnScrollView.frame.size.height);
    columnScrollView.delegate = self;
    columnScrollView.backgroundColor = [UIColor clearColor];
    
    pageControl.currentPage = 0;
    pageControl.numberOfPages = countPage;
    
    pageControlBeingUsed = NO;
    
    
    muDistionary = [NSMutableDictionary dictionaryWithCapacity:4];
    currentPage = 0;
    
    thumbDownQueue = [NSOperationQueue new];
    [thumbDownQueue setMaxConcurrentOperationCount:2];
    
    for (int i = 0; i < 2; i++)
    {
        if (i <= countPage)
        {
            [self assemblePanel:i];
        }
    }
    
    animationLeftImgY = animationLeftImg.frame.origin.y;
    animationBottomImgY = animationBottomImg.frame.origin.y;
    animationTopImgY = animationTopImg.frame.origin.y;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) assemblePanel:(int) pageNum
{
    NSBundle *bundle = [NSBundle mainBundle];
    NSMutableArray * muArray = [db getHumanityDataByPage:pageNum];
    
    CGRect frame;
    UIView *subview = [[bundle loadNibNamed:@"HumanityContentPanel" owner:self options:nil] lastObject];
    
    frame.origin.x = columnScrollView.frame.size.width * (pageNum);
    frame.origin.y = 15;
    frame.size.width = columnScrollView.frame.size.width;
    frame.size.height = subview.frame.size.height;
    
    NSOperation *downOperation = nil;
    
    if (subview != nil && muArray != nil)
    {
        subview.backgroundColor = [UIColor clearColor];
        
        UIControl *firstPanel = (UIControl*)[subview viewWithTag:201];
        UIControl *secondPanel = (UIControl*)[subview viewWithTag:206];
        UIControl *thirdPanel = (UIControl*)[subview viewWithTag:211];
        UIControl *fourPanel = (UIControl*)[subview viewWithTag:216];
        
        firstPanel.backgroundColor = [UIColor clearColor];
        secondPanel.backgroundColor = [UIColor clearColor];
        thirdPanel.backgroundColor = [UIColor clearColor];
        fourPanel.backgroundColor = [UIColor clearColor];
        
        UIView *lineOneView = (UIView *)[subview viewWithTag:230];
        UIView *lineTwoView = (UIView *)[subview viewWithTag:231];
        UIView *lineThreeView = (UIView *)[subview viewWithTag:232];
        
        subview.frame = frame;
        
        //根据数据加载subview
        if (muArray.count >= 1 && [muArray objectAtIndex:0])
        {
            NSMutableDictionary *muDict = [muArray objectAtIndex:0];
            
            UIImageView *firstImg = (UIImageView*)[subview viewWithTag:202];
            //异步加载图片
            downOperation = [self loadingImageOperation:muDict andImageView:firstImg];
            if (downOperation != nil)
            {
                [thumbDownQueue addOperation:downOperation];
            }
            
            UILabel* firstLabelTitle = (UILabel*)[subview viewWithTag:203];
            [firstLabelTitle setText:[muDict objectForKey:@"title"]];
            UILabel* firstLabelTime = (UILabel*)[subview viewWithTag:204];
            [firstLabelTime setText:[TimeUtil convertTimeFormat:[muDict objectForKey:@"timestamp"]]];
            UILabel* firstLabelDesc = (UILabel*)[subview viewWithTag:205];
            
            [firstLabelDesc setText:[muDict objectForKey:@"description"]];
            [firstLabelDesc alignTop];
            
            firstLabelDesc.lineBreakMode = NSLineBreakByTruncatingTail;
            
            //[homeTopTitle setValue:[muDict objectForKey:@"serverID"] forUndefinedKey:@"serverID"];
            firstPanel.accessibilityLabel = [muDict objectForKey:@"serverID"];
            [firstPanel addTarget:self action:@selector(panelClick:) forControlEvents:UIControlEventTouchUpInside];
            
            if ([[muDict objectForKey:@"hasVideo"] intValue] == 1)
            {
                [self addVideoImage:firstImg];
            }
        }
        else
        {
            firstPanel.hidden = YES;
            lineOneView.hidden = YES;
        }
        
        if (muArray.count >= 2 && [muArray objectAtIndex:1])
        {
            NSMutableDictionary *muDict = [muArray objectAtIndex:1];
            UIImageView *secondImg = (UIImageView*)[subview viewWithTag:207];
            //异步加载图片
            downOperation = [self loadingImageOperation:muDict andImageView:secondImg];
            if (downOperation != nil)
            {
                [thumbDownQueue addOperation:downOperation];
            }
            
            UILabel* secondLabelTitle = (UILabel*)[subview viewWithTag:208];
            [secondLabelTitle setText:[muDict objectForKey:@"title"]];
            
            UILabel* secondLabelTime = (UILabel*)[subview viewWithTag:209];
            [secondLabelTime setText:[TimeUtil convertTimeFormat:[muDict objectForKey:@"timestamp"]]];
            
            UILabel* secondLabelDesc = (UILabel*)[subview viewWithTag:210];
            [secondLabelDesc setText:[muDict objectForKey:@"description"]];
            [secondLabelDesc alignTop];
            secondLabelDesc.lineBreakMode = NSLineBreakByTruncatingTail;
            
            secondPanel.accessibilityLabel = [muDict objectForKey:@"serverID"];
            [secondPanel addTarget:self action:@selector(panelClick:) forControlEvents:UIControlEventTouchUpInside];
            if ([[muDict objectForKey:@"hasVideo"] intValue] == 1)
            {
                [self addVideoImage:secondImg];
            }
        }
        else
        {
            secondPanel.hidden = YES;
            lineTwoView.hidden = YES;
        }
        
        if (muArray.count >= 3 && [muArray objectAtIndex:2])
        {
            NSMutableDictionary *muDict = [muArray objectAtIndex:2];
            UIImageView *thirdImg = (UIImageView*)[subview viewWithTag:212];
            //异步加载图片
            downOperation = [self loadingImageOperation:muDict andImageView:thirdImg];
            if (downOperation != nil)
            {
                [thumbDownQueue addOperation:downOperation];
            }
            
            UILabel* thirdLabelTitle = (UILabel*)[subview viewWithTag:213];
            [thirdLabelTitle setText:[muDict objectForKey:@"title"]];
            
            UILabel* thirdLabelTime = (UILabel*)[subview viewWithTag:214];
            [thirdLabelTime setText:[TimeUtil convertTimeFormat:[muDict objectForKey:@"timestamp"]]];
            UILabel* thirdLabelDesc = (UILabel*)[subview viewWithTag:215];
            [thirdLabelDesc setText:[muDict objectForKey:@"description"]];
            [thirdLabelDesc alignTop];
            thirdLabelDesc.lineBreakMode = NSLineBreakByTruncatingTail;
            
            thirdPanel.accessibilityLabel = [muDict objectForKey:@"serverID"];
            [thirdPanel addTarget:self action:@selector(panelClick:) forControlEvents:UIControlEventTouchUpInside];
            
            if ([[muDict objectForKey:@"hasVideo"] intValue] == 1)
            {
                [self addVideoImage:thirdImg];
            }
        }
        else
        {
            thirdPanel.hidden = YES;
            lineThreeView.hidden = YES;
        }
        
        if (muArray.count >= 4 && [muArray objectAtIndex:3])
        {
            NSMutableDictionary *muDict = [muArray objectAtIndex:3];
            UIImageView *fourImg = (UIImageView*)[subview viewWithTag:217];
            //异步加载图片
            downOperation = [self loadingImageOperation:muDict andImageView:fourImg];
            if (downOperation != nil)
            {
                [thumbDownQueue addOperation:downOperation];
            }
            
            UILabel* fourLabelTitle = (UILabel*)[subview viewWithTag:218];
            [fourLabelTitle setText:[muDict objectForKey:@"title"]];
            UILabel* fourLabelTime = (UILabel*)[subview viewWithTag:219];
            [fourLabelTime setText:[TimeUtil convertTimeFormat:[muDict objectForKey:@"timestamp"]]];
            UILabel* fourLabelDesc = (UILabel*)[subview viewWithTag:220];
            [fourLabelDesc setText:[muDict objectForKey:@"description"]];
            [fourLabelDesc alignTop];
            fourLabelDesc.lineBreakMode = NSLineBreakByTruncatingTail;
            
            fourPanel.accessibilityLabel = [muDict objectForKey:@"serverID"];
            [fourPanel addTarget:self action:@selector(panelClick:) forControlEvents:UIControlEventTouchUpInside];
            
            if ([[muDict objectForKey:@"hasVideo"] intValue] == 1)
            {
                [self addVideoImage:fourImg];
            }
        }
        else
        {
            fourPanel.hidden = YES;
        }
        
        [columnScrollView addSubview:subview];
        
        [muDistionary setObject:subview forKey:[NSNumber  numberWithInt:(pageNum)]];
    }
}

#define HeighTopOne 450
#define HeighTopTwo 100
#define HeighTopThr 1200

- (void)rootscrollViewDidScrollToPointY:(int)pointY
{
    
    if (pointY > 100)
    {
        int positionYOne = animationTopImgY - (pointY - 10)/5;
        positionYOne = positionYOne < HeighTopOne ? HeighTopOne:positionYOne;
        [animationTopImg setFrame:CGRectMake(animationTopImg.frame.origin.x, positionYOne, animationTopImg.frame.size.width, animationTopImg.frame.size.height)];
        
    }
    
    if (pointY > 100)
    {
        int positionYTwo = animationLeftImgY - (pointY - 10)/3;
        positionYTwo = positionYTwo < HeighTopTwo ? HeighTopTwo:positionYTwo;
        [animationLeftImg setFrame:CGRectMake(animationLeftImg.frame.origin.x, positionYTwo, animationLeftImg.frame.size.width, animationLeftImg.frame.size.height)];
    }
    
    if (pointY > 500)
    {
        int positionYThr = animationBottomImgY - (pointY - 450)/5;
        positionYThr = positionYThr < HeighTopThr ? HeighTopThr:positionYThr;
        [animationBottomImg setFrame:CGRectMake(animationBottomImg.frame.origin.x, positionYThr, animationBottomImg.frame.size.width, animationBottomImg.frame.size.height)];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)pageChange:(id)sender
{
     pageControlBeingUsed = YES;
}
@end
