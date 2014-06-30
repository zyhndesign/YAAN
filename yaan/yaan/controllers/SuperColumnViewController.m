//
//  SuperColumnViewController.m
//  NewTD
//
//  Created by 工业设计中意（湖南） on 14-5-12.
//  Copyright (c) 2014年 中意工业设计（湖南）有限责任公司. All rights reserved.
//

#import "SuperColumnViewController.h"
#import "../classes/FileUtils.h"
#import "../libs/AFNetworking/AFNetworking.h"
#import "../libs/MJPopup/UIViewController+MJPopupViewController.h"
#import "PopupDetailViewController.h"
#import "VarUtils.h"
#import "../libs/AFNetworking/UIImageView+AFNetworking.h"

@interface SuperColumnViewController ()

@end

@implementation SuperColumnViewController


extern FileUtils *fileUtils;
extern PopupDetailViewController* detailViewController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    animationBeginYValue = 200;
    if (self) {
        // Custom initialization
       
    }
    return self;
}

- (void)panelClick:(id)sender
{
    if (detailViewController != nil)
    {
        detailViewController = nil;
    }
    
    if (detailViewController == nil)
    {
        NSString *articleId = [sender accessibilityLabel];
        if ([sender isKindOfClass:[UITapGestureRecognizer class]] && (articleId == nil))
        {
            articleId = ((UITapGestureRecognizer *)sender).view.accessibilityLabel;
        }
        
        detailViewController = [[PopupDetailViewController alloc] initWithNibName:@"PopDetailView" bundle:nil andParams:articleId];
        detailViewController.delegate = self;
        [self presentPopupViewController:detailViewController animationType:MJPopupViewAnimationSlideRightLeft];
    }
}

- (void) closeButtonClicked
{
    detailViewController = nil;
    [self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationSlideLeftRight];
}


-(NSOperation *) loadingImageOperation:(NSMutableDictionary*) muDict andImageView:(UIImageView*) uiImg
{
    NSString *path = [[PATH_OF_DOCUMENT stringByAppendingPathComponent:@"thumb"] stringByAppendingPathComponent:[muDict objectForKey:@"serverID"]];
    if ([fileUtils fileISExist:path])
    {
        //加载本地文件
        [uiImg setImageWithURL:[NSURL fileURLWithPath:path]];
    }
    else //加载网络文件，并下载到本地
    {
        NSMutableString *muString = [muDict objectForKey:@"profile_path"];
        
        NSString *suffixString = [[[muString substringToIndex:[muString length] - 4] stringByAppendingString:@"-300x300"] stringByAppendingString:[muString substringFromIndex:[muString length] - 4]];
       
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[suffixString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
        
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        operation.outputStream = [NSOutputStream outputStreamToFileAtPath:path append:NO];
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            [uiImg setImageWithURL:[NSURL fileURLWithPath:path]];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"loading image is failure %@",[error description]);
        }];
        return operation;
    }
    return nil;
}

-(void) addVideoImage:(UIView *)view
{
    UIImage *videoImage = [UIImage imageNamed:@"video"];
    UIImageView *videoImgView = [[UIImageView alloc] initWithImage:videoImage];
    videoImgView.contentMode = UIViewContentModeScaleAspectFit;
    videoImgView.frame = CGRectMake(0, 0, 40, 35);
    [view addSubview:videoImgView];
}

/**
 *  留给子类实现
 *
 *  @param pointY
 */
- (void)rootscrollViewDidScrollToPointY:(int)pointY
{

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
