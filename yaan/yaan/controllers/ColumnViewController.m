//
//  ColumnViewController.m
//  NewTD
//
//  Created by 工业设计中意（湖南） on 14-5-12.
//  Copyright (c) 2014年 中意工业设计（湖南）有限责任公司. All rights reserved.
//

#import "ColumnViewController.h"

@interface ColumnViewController ()

@end

@implementation ColumnViewController

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
}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (!pageControlBeingUsed)
    {
        CGFloat pageWidth = columnScrollView.frame.size.width;
        currentPage = floor((columnScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
        pageControl.currentPage = currentPage;
    }
    
}

- (void) scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self addNewModelInScrollView:currentPage];
    pageControlBeingUsed = NO;
}

- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self removeOldModelInScrollView:currentPage];
    pageControlBeingUsed = NO;
}

-(void) addNewModelInScrollView:(int) pageNum
{
    if (nil != columnScrollView)
    {
        UIView* subview1 = [muDistionary objectForKey:[NSNumber numberWithInt:(pageNum + 1)]];
        if (nil == subview1 && (pageNum + 1 < countPage))
        {
            [self assemblePanel:(pageNum + 1)];
        }
        
        UIView* subview2 = [muDistionary objectForKey:[NSNumber numberWithInt:(pageNum - 1)]];
        if (nil == subview2 && (pageNum - 1 >= 0))
        {
            [self assemblePanel:(pageNum - 1)];
        }
    }
}

-(void) removeOldModelInScrollView:(int)pageNum
{
    UIView* subview1 = [muDistionary objectForKey:[NSNumber numberWithInt:(pageNum + 2)]];
    if (nil != subview1 && (pageNum + 2) < countPage)
    {
        [subview1 removeFromSuperview];
        [muDistionary removeObjectForKey:[NSNumber numberWithInt:(pageNum + 2)]];
    }
    
    UIView* subview2 = [muDistionary objectForKey:[NSNumber numberWithInt:(pageNum - 2)]];
    if (nil != subview2 && (pageNum - 2 >= 0))
    {
        [subview2 removeFromSuperview];
        [muDistionary removeObjectForKey:[NSNumber numberWithInt:(pageNum - 2)]];
    }
}

/**
 *  该方法交给继承类去实现
 *
 *  @param pageNum 页码编号
 */
-(void) assemblePanel:(int) pageNum
{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

@end
