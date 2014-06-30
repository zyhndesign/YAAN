//
//  SplashViewController.m
//  NewTD
//
//  Created by 工业设计中意（湖南） on 14-5-12.
//  Copyright (c) 2014年 中意工业设计（湖南）有限责任公司. All rights reserved.
//

#import "SplashViewController.h"
#import "../libs/Reachability/Reachability.h"
#import "../classes/DBUtils.h"
#import "VarUtils.h"
#import "Constants.h"
#import "../libs/AFNetworking/AFJSONRequestOperation.h"
#import "../classes/FileUtils.h"
#import "../libs/googleAnalytics/GAIDictionaryBuilder.h"
#import "../libs/googleAnalytics/GAI.h"

@interface SplashViewController ()

@end

@implementation SplashViewController

@synthesize loadActivityIndicator;

NSString *rootPath = nil;
DBUtils *db = nil;
NSUserDefaults *baseInfo = nil;

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
    
    // Do any additional setup after loading the view.
    self.screenName = @"启动界面";
    
    [[GAI sharedInstance].defaultTracker set:self.screenName
                                       value:@"SplashController Screen"];
    
    // Send the screen view.
    [[GAI sharedInstance].defaultTracker send:[[GAIDictionaryBuilder createAppView] build]];
    
    //set full screen
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    [loadActivityIndicator startAnimating];
    
    
    db = [[DBUtils alloc] init];
    baseInfo = [NSUserDefaults standardUserDefaults];
    
    Reachability *reacheNet = [Reachability reachabilityWithHostname:@"www.baidu.com"];
    switch ([reacheNet currentReachabilityStatus]) {
        case NotReachable: //not network reach
            if ([db countArticlesIsEmpty])
            {
                //请连接网络再进行使用
                NSLog(@"必须连接网络初始化数据");
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提醒" message:@"请设置好网络连接" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alert show];
            }
            else
            {
                //进入阅读
                NSLog(@"阅读离线数据数据");
                [self startApp];
            }
            break;
        case ReachableViaWWAN: //use 3g network
            NSLog(@"3g network....");
            [self checkUpdateData];
            break;
        case ReachableViaWiFi: //use wifi network
            NSLog(@"wifi network....");
            [self checkUpdateData];
            break;
        default:
            [self startApp];
    
    }
}


//检查是否有数据进行更新
- (void) checkUpdateData
{
    rootPath = INTERNET_VISIT_PREFIX;
    NSString* getDataTime = [baseInfo objectForKey:@"timestamp"];
    
    if(nil == getDataTime)
    {
        getDataTime = @"0";
    }
    
    NSURL *visitPath = [NSURL URLWithString:[[[rootPath stringByAppendingString:@"/travel/dataUpdate.json?lastUpdateDate="] stringByAppendingString:getDataTime ] stringByAppendingString: @"&category=6"]];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:visitPath];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSArray *array = JSON;
        
        NSMutableDictionary* muDict = nil;
        
        NSDate* currDate = [NSDate date];
        NSDateFormatter* formater = [NSDateFormatter new];
        [formater setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString* currTime = [formater stringFromDate:currDate];
        
        for (int i = 0; i < array.count; i++)
        {
            muDict = [NSMutableDictionary new];
            NSDictionary *article = [array objectAtIndex:i];
            
            if ([[article objectForKey:@"op"] isEqual:@"u"])
            {
                [muDict setObject:[article objectForKey:@"id"] forKey:@"serverID"];
                [muDict setObject:[article objectForKey:@"name"] forKey:@"title"];
                [muDict setObject:[article objectForKey:@"size"] forKey:@"size"];
                [muDict setObject:[article objectForKey:@"url"] forKey:@"url"];
                [muDict setObject:[article objectForKey:@"timestamp"] forKey:@"timestamp"];
                [muDict setObject:[article objectForKey:@"md5"] forKey:@"md5"];
                [muDict setObject:[article objectForKey:@"op"] forKey:@"operation"];
                NSDictionary *info = (NSDictionary *)[article objectForKey:@"info"];
                [muDict setObject:[info objectForKey:@"profile"] forKey:@"profile_path"];
                [muDict setObject:[info objectForKey:@"postDate"] forKey:@"post_date"];
                [muDict setObject:[info objectForKey:@"author"] forKey:@"author"];
                [muDict setObject:[info objectForKey:@"description"] forKey:@"description"];
                
                [muDict setObject:[info objectForKey:@"background"] forKey:@"max_bg_img"];
                
                if ([[info objectForKey:@"category"] isEqual:@"6/10"])
                {
                    [muDict setObject:[NSNumber numberWithInt:LANDSCAPE_CATEGORY] forKey:@"category"];
                }
                else if ([[info objectForKey:@"category"] isEqual:@"6/7"])
                {
                    [muDict setObject:[NSNumber numberWithInt:HUMANITY_CATEGORY] forKey:@"category"];
                }
                else if ([[info objectForKey:@"category"] isEqual:@"6/8"])
                {
                    [muDict setObject:[NSNumber numberWithInt:STORY_CATEGORY] forKey:@"category"];
                }
                else if ([[info objectForKey:@"category"] isEqual:@"6/9"])
                {
                    [muDict setObject:[NSNumber numberWithInt:COMMUNITY_CATEGORY] forKey:@"category"];
                }
                
                if ([[info objectForKey:@"headline"] isEqual:@"true"])
                {
                    [muDict setObject:[NSNumber numberWithInt:1] forKey:@"isHeadline"];
                }
                else
                {
                    [muDict setObject:[NSNumber numberWithInt:0] forKey:@"isHeadline"];
                }
                
                if ([[info objectForKey:@"hasVideo"] isEqual:@"true"])
                {
                    [muDict setObject:[NSNumber numberWithInt:1] forKey:@"hasVideo"];
                }
                else
                {
                    [muDict setObject:[NSNumber numberWithInt:0] forKey:@"hasVideo"];
                }
                
                [muDict setObject:currTime forKey:@"insertDate"];
                [muDict setObject:@" " forKey:@"main_file_path"];
                [muDict setObject:[NSNumber numberWithInt:0] forKey:@"isDownload"];
                [db updateDataByServerId:[article objectForKey:@"id"] withDict:muDict];
            }
            else
            {
                //删除数据库中数据
                BOOL result = [db deleteDataByServerId:[article objectForKey:@"id"]];
                NSLog(@"%i",result);
            }
            //删除文件夹中的数据
            FileUtils *fileUtils = [FileUtils new];
            NSString *path = [[PATH_OF_DOCUMENT stringByAppendingPathComponent:@"articles"] stringByAppendingPathComponent:[article objectForKey:@"id"]];
            if([fileUtils archiveIsExist:path])
            {
                [fileUtils deleteDir:path];
            }
            
            if (i == (array.count - 1))
            {
                [baseInfo setValue:[article objectForKey:@"timestamp"] forKey:@"timestamp"];
                [baseInfo synchronize];
            }
        }
        
        [self startApp];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"failure");
        [self startApp];
    }];
    [operation start];
}

//启动进入主界面，判断是iphone 还是iPad
-(void) startApp
{
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController *viewController =  [storyBoard instantiateViewControllerWithIdentifier:@"mainView"];
        //[self setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
       [self presentViewController:viewController animated:YES completion:nil];
    });
    
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
