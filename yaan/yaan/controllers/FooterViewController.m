//
//  FooterViewController.m
//  NewTD
//
//  Created by 工业设计中意（湖南） on 14-5-13.
//  Copyright (c) 2014年 中意工业设计（湖南）有限责任公司. All rights reserved.
//

#import "FooterViewController.h"
#import "DownloadViewController.h"
#import "../libs/MJPopup/UIViewController+MJPopupViewController.h"
#import "PopupDetailViewController.h"
#import "../libs/Reachability/Reachability.h"
#import "../classes/UILabel+VerticalAlign.h"

@interface FooterViewController ()<MJPopupDelegate>

@end

@implementation FooterViewController

@synthesize downloadImageView,bgTextlabel;

DownloadViewController *downloadViewController;

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
    
    downloadImageView.userInteractionEnabled = YES;
    [bgTextlabel setText:NSLocalizedString(@"projectBg", nil)];
    [bgTextlabel alignTop];
    UITapGestureRecognizer *sigTab = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(downLoadFiles)];
    [downloadImageView addGestureRecognizer:sigTab];
    
}

- (void)downLoadFiles
{
    //弹出下载面板
    if (downloadViewController == nil)
    {
        Reachability *reacheNet = [Reachability reachabilityWithHostname:@"www.baidu.com"];
        switch ([reacheNet currentReachabilityStatus]) {
            case NotReachable: //not network reach
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Remind", nil) message:NSLocalizedString(@"NetworkUnreachable", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"Confirm", nil) otherButtonTitles:nil, nil];
                [alert show];
                break;
            }
            case ReachableViaWWAN: //use 3g network
            {
                NSLog(@"3g network....");
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Remind", nil) message:NSLocalizedString(@"3gwarn", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"Confirm", nil) otherButtonTitles:nil, nil];
                [alert show];
                break;
            }
            case ReachableViaWiFi: //use wifi network
            {
                downloadViewController = [[DownloadViewController alloc] initWithNibName:@"DownloadWin" bundle:nil];
                downloadViewController.delegate = self;
                [[[self parentViewController] view] addSubview:downloadViewController.view];
                [downloadViewController.view setFrame:CGRectMake(0, 768, downloadViewController.view.frame.size.width, downloadViewController.view.frame.size.height)];
                
                [UIView animateWithDuration:1.0 animations:^{
                    NSLog(@"Animation start....");
                    [downloadViewController.view setFrame:CGRectMake(0, 0, downloadViewController.view.frame.size.width, downloadViewController.view.frame.size.height)];
                } completion:^(BOOL finished) {
                    NSLog(@"Animation done....");
                }];
                
                break;
            }
            default:
                break;
        }
        
    }
    
}

- (void) closeButtonClicked
{
    if (downloadViewController != nil)
    {
        [UIView animateWithDuration:1.0 animations:^{
            NSLog(@"remove Animation start....");
            [downloadViewController.view setFrame:CGRectMake(0, 768, downloadViewController.view.frame.size.width, downloadViewController.view.frame.size.height)];
        } completion:^(BOOL finished) {
            NSLog(@"remove Animation done....");
        }];
        [downloadViewController removeFromParentViewController];
        downloadViewController = nil;
    }
    
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
