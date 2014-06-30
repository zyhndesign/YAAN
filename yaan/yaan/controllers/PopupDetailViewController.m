//
//  PopupDetailViewController.m
//  NewTD
//
//  Created by 工业设计中意（湖南） on 14-5-12.
//  Copyright (c) 2014年 中意工业设计（湖南）有限责任公司. All rights reserved.
//

#import "PopupDetailViewController.h"
#import "../libs/Reachability/Reachability.h"
#import "../classes/FileUtils.h"
#import "VarUtils.h"
#import "DBUtils.h"
#import "../libs/googleAnalytics/GAI.h"
#import "../libs/googleAnalytics/GAIDictionaryBuilder.h"
#import "../classes/UIImageView+RotationAnimation.h"
#import "../libs/GDataXml/GDataXMLNode.h"
#import <MediaPlayer/MPMoviePlayerController.h>
#import "../libs/MJPopup/UIViewController+MJPopupViewController.h"
#import "VideoViewController.h"

@interface PopupDetailViewController ()<UIWebViewDelegate,UIAlertViewDelegate,MJPopupDelegate>

@end

@implementation PopupDetailViewController

@synthesize webView, delegate;
@synthesize backBtn;
@synthesize serverID;

extern FileUtils *fileUtils;
extern DBUtils *db;
VideoViewController *videoViewController = nil;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andParams:(NSString *)_serverID
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    self.serverID = _serverID;
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // This screen name value will remain set on the tracker and sent with
    // hits until it is set to a new value or to nil.
    webView.alpha = 1;
    self.screenName = @"查看内容详情界面";
    self.view.backgroundColor = [UIColor clearColor];
    [[GAI sharedInstance].defaultTracker set:self.screenName
                                       value:@"Pop Screen"];
    
    // Send the screen view.
    [[GAI sharedInstance].defaultTracker send:[[GAIDictionaryBuilder createAppView] build]];
  
	// Do any additional setup after loading the view.
    [backBtn setBackgroundImage:[UIImage imageNamed:@"backNormalBtn"] forState:UIControlStateNormal];
    [backBtn setBackgroundImage:[UIImage imageNamed:@"backPressedBtn"] forState:UIControlStateSelected];
    
    [backBtn addTarget:self action:@selector(BtnCloseClick) forControlEvents:UIControlEventTouchUpInside];
    backBtn.alpha = 1;
    //[NSURL fileURLWithPath:]
    NSLog(@"get article id is :%@",self.serverID);
    downloadProgress.progress = 0;
    [downloadPercentlabel setText:@"0%"];
    
    
    if (nil != self.serverID)
    {
        
        NSString *filePath = [[[[PATH_OF_DOCUMENT stringByAppendingPathComponent:@"articles"] stringByAppendingPathComponent:self.serverID] stringByAppendingPathComponent:@"doc"] stringByAppendingPathComponent:@"main.html"];
        
        [webView.scrollView setAlwaysBounceHorizontal:YES];
        [webView.scrollView setAlwaysBounceVertical:NO];
        
        [webView.scrollView setShowsVerticalScrollIndicator:NO];
        //[webView.scrollView setShowsHorizontalScrollIndicator:YES];
        webView.delegate = self;
        
        if ([fileUtils fileISExist:filePath])
        {
            NSLog(@"loading local file...");
            
            NSURL * url = [NSURL fileURLWithPath:filePath];
            NSURLRequest *request = [NSURLRequest requestWithURL:url];
            [webView loadRequest:request];
            downloadProgress.progress = 1;
            downloadProgress.hidden = YES;
            [downloadPercentlabel setText:@"100%"];
        }
        else
        {
            NSLog(@"loading remote file...");
            //获取文件大小
            NSDictionary *dict = [db queryByServerID:serverID];
            
            //UIAlertView *downloadTips = [[UIAlertView alloc] initWithTitle:@"下载文件" message:@"正在加载中..." delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
            UIAlertView *articleTips = [[UIAlertView alloc] initWithTitle:@"提醒" message:@"该文件没有离线保存，需要打开网络下载" delegate:self cancelButtonTitle:@"确认" otherButtonTitles:nil];
            NSString *url = [db getDownUrlByServerId:serverID];
            NSLog(@"download zip file path is :%@", url);
            Reachability *reacheNet = [Reachability reachabilityWithHostname:@"www.baidu.com"];
            switch ([reacheNet currentReachabilityStatus]) {
                case NotReachable: //not network reach
                    [articleTips show];
                    break;
                case ReachableViaWWAN: //use 3g network
                    NSLog(@"3g network....");
                    [fileUtils downloadZipFile:url andArticleId:self.serverID andTipsAnim:webView andFileSize:[[dict objectForKey:@"size"] longLongValue]];
                    break;
                case ReachableViaWiFi: //use wifi network
                    NSLog(@"wifi network....");
                    [fileUtils downloadZipFile:url andArticleId:self.serverID andTipsAnim:webView andFileSize:[[dict objectForKey:@"size"] longLongValue]];
                    break;
                default:
                    
                    break;
            }
        }
        
        //解析doc.xml文件，获取showUrl地址，videoUrl
        NSString *docFilePath   =  [[[PATH_OF_DOCUMENT stringByAppendingPathComponent:@"articles"] stringByAppendingPathComponent:self.serverID]  stringByAppendingPathComponent:@"doc.xml"];
        //NSString *jsonString  =   [NSString stringWithContentsOfFile:docFilePath encoding:NSUTF8StringEncoding error:nil];
        NSData *xmlData = [[NSData alloc] initWithContentsOfFile:docFilePath];
        
        //使用NSData对象初始化
        GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData  options:0 error:nil];
        
        //获取根节点（doc）
        GDataXMLElement *rootElement = [doc rootElement];
        
        //获取根节点下的节点（videoItems）
        NSArray *videoItems = [rootElement elementsForName:@"videoItems"];
        
        videoArray = [NSMutableArray new];
        
        if ([videoItems count] > 0)
        {
            for (GDataXMLElement *videoItem in videoItems)
            {
                NSArray *videoItemData = [videoItem elementsForName:@"videoItem"];
                
                for (GDataXMLElement *video in videoItemData) {
                    urlDict = [NSMutableDictionary new];
                    //获取showUrl节点的值
                    GDataXMLElement *nameElement = [[video elementsForName:@"showUrl"] objectAtIndex:0];
                    showUrl = [nameElement stringValue];
                    NSLog(@"showUrl is:%@",showUrl);
                    
                    //获取videoUrl节点的值
                    GDataXMLElement *ageElement = [[video elementsForName:@"videoUrl"] objectAtIndex:0];
                    videoUrl = [ageElement stringValue];
                    NSLog(@"videoUrl is:%@",videoUrl);
                    
                    [urlDict setValue:videoUrl forKey:@"videoUrl"];
                    [urlDict setValue:showUrl forKey:@"showUrl"];
                    
                    [videoArray addObject:urlDict];
                }
            }
        }
    }
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(stopMovePlayer) name:@"STOP_MOVE_PLAYER" object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)stopMovePlayer
{
    if (videoViewController != nil)
    {
        videoViewController = nil;
        //[[NSNotificationCenter defaultCenter] postNotificationName:@"PAUSE_MUSIC_PLAYING" object:nil];
    }
}

- (void)BtnCloseClick
{
    if ([webView canGoBack])
    {
        [webView goBack];
    }
    else
    {
        if (self.delegate && [self.delegate respondsToSelector:@selector(closeButtonClicked)])
        {
            NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
            
            [center postNotificationName:@"HOME_PAGE_VIDEO" object:nil];
            [self.delegate closeButtonClicked];
        }
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSURL *url = [request URL];
    
    //判断url是否为视频地址，如果为视频地址则进行拦截播放
    for (NSMutableDictionary *dict in videoArray)
    {
        if ([[dict objectForKey:@"showUrl"]isEqualToString:[url description]])
        {
            //判断指定路径是否有视频，没有则进行下载，下载后调用原生播放器进行播放
            NSString *path =[[PATH_OF_DOCUMENT stringByAppendingPathComponent:@"video"] stringByAppendingPathComponent:[self getFileNameFromUrl:[urlDict objectForKey:@"videoUrl"]]];
            if ([fileUtils fileISExist:path])
            {
                if (videoViewController == nil)
                {
                    videoViewController = [[VideoViewController alloc] initWithNibName:@"VideoPlay" bundle:nil andUrl:path];
                    //videoViewController.delegate = self;
                    //[self presentPopupViewController:videoViewController animationType:MJPopupViewAnimationSlideRightLeft];
                    [self presentViewController:videoViewController animated:YES completion:nil];
                }
            }
            return NO;
        }
        else
        {
            return YES;
        }
    }
    return YES;
}

-(void)webView:(UIWebView *)_webView didFailLoadWithError:(NSError *)error
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"404" ofType:@"html"];
    NSURL *url = [NSURL URLWithString:filePath relativeToURL:[NSURL fileURLWithPath:[filePath stringByDeletingLastPathComponent] isDirectory:YES]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [_webView loadRequest:request];
}

-(void)webViewDidStartLoad:(UIWebView *)_webView
{
    downloadPercentlabel.hidden = NO;
    downloadProgress.hidden = NO;
}

-(void)webViewDidFinishLoad:(UIWebView *)_webView
{
    downloadPercentlabel.hidden = YES;
    downloadProgress.hidden = YES;
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        if (self.delegate && [self.delegate respondsToSelector:@selector(closeButtonClicked)])
        {
            NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
            [center postNotificationName:@"HOME_PAGE_VIDEO" object:nil];
            [self.delegate closeButtonClicked];
        }
    }
    
    if (buttonIndex == 1)
    {
        
    }
}

-(NSString *)getFileNameFromUrl:(NSString *)url
{
    NSArray *array = [url componentsSeparatedByString:@"/"];
    
    return [array objectAtIndex:([array count] - 1)];
}

-(void) releasePopResource
{
    videoViewController = nil;
}

-(void) dealloc
{
    NSLog(@"webview delegate set nil.....");
    webView.delegate = nil;
}
@end
