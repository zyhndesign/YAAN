//
//  MusicViewController.m
//  NewTD
//
//  Created by 工业设计中意（湖南） on 14-5-15.
//  Copyright (c) 2014年 中意工业设计（湖南）有限责任公司. All rights reserved.
//

#import "MusicViewController.h"
#import "../classes/DBUtils.h"
#import "../classes/TimeUtil.h"
#import "Constants.h"
#import "VarUtils.h"
#import "../libs/AFNetworking/AFHTTPClient.h"
#import "../libs/AFNetworking/AFHTTPRequestOperation.h"
#import "../libs/AFNetworking/AFJSONRequestOperation.h"
#import <AVFoundation/AVAudioPlayer.h>
#import <AVFoundation/AVAudioSession.h>
#import "../libs/AudioStream/AudioStreamer.h"
#import "../libs/Reachability/Reachability.h"
#import "../libs/JSONKit/JSONKit.h"

@interface MusicViewController ()

@end

@implementation MusicViewController

@synthesize musicNextBtn, musicPlayOrPauseBtn;

@synthesize musicPreviousBtn, musicProgressView,musicNameLabel;

int musicLocalOrNet = 0;

extern DBUtils *db;

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
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
    
    [musicPreviousBtn setBackgroundImage:[UIImage imageNamed:@"musicLastDefault"] forState:UIControlStateNormal];
    [musicPreviousBtn setBackgroundImage:[UIImage imageNamed:@"musicLastActivied"] forState:UIControlStateSelected];
    
    [musicPlayOrPauseBtn setBackgroundImage:[UIImage imageNamed:@"musicPlayDefault"] forState:UIControlStateNormal];
    [musicPlayOrPauseBtn setBackgroundImage:[UIImage imageNamed:@"musicPlayActivied"] forState:UIControlStateSelected];
    
    [musicNextBtn setBackgroundImage:[UIImage imageNamed:@"musicNextDefault"] forState:UIControlStateNormal];
    [musicNextBtn setBackgroundImage:[UIImage imageNamed:@"musicNextActivied"] forState:UIControlStateSelected];
        
    musicProgressView.progress = 0;
    
    musicArray = [NSMutableArray new];
    [self loadMusicPlayMusic];
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    //注册音乐监听广播，用于视频播放时，暂时停止音乐播放
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(pauseMusic) name:@"PAUSE_MUSIC_PAUSE" object:nil];
    [center addObserver:self selector:@selector(playingMusic) name:@"PAUSE_MUSIC_PLAYING" object:nil];
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

- (IBAction)musicPreviousBtnClick:(id)sender
{
    [self previous];
}

- (IBAction)musicPlayOrPauseBtnClick:(id)sender
{
    [self play];
}

- (IBAction)musicNextBtnClick:(id)sender;
{
    [self next];
}

-(void) loadMusicPlayMusic
{
    //加载本地音乐
    NSMutableArray* musicData = [db queryMusicData];
    
    if ([musicData count] > 0)
    {
        musicLocalOrNet = 1;
        
        NSMutableDictionary* muDict = nil;
        
        for (int i = 0; i < musicData.count; i++)
        {
            muDict = [NSMutableDictionary new];
            NSDictionary *article = [musicData objectAtIndex:i];
            [muDict setObject:[article objectForKey:@"musicTitle"] forKey:@"music_title"];
            [muDict setObject:[article objectForKey:@"musicAuthor"] forKey:@"music_author"];
            [muDict setObject:[article objectForKey:@"musicPath"] forKey:@"music_path"];
            [musicArray addObject:muDict];
        }
    }
    else
    {
        NSString *visitPath = [INTERNET_VISIT_PREFIX stringByAppendingString:@"/travel/wp-admin/admin-ajax.php?action=zy_get_music&programId=13"];
        
        AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:INTERNET_VISIT_PREFIX]];
        NSMutableURLRequest *request = [httpClient requestWithMethod:@"GET" path:visitPath parameters:nil];
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        [httpClient registerHTTPOperationClass:[AFHTTPRequestOperation class]];
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSString *nsStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            NSData* jsonData = [nsStr dataUsingEncoding:NSUTF8StringEncoding];
            
            NSDictionary *nsDict = [jsonData objectFromJSONData];
            NSArray *array = [nsDict objectForKey:@"data"];
            NSMutableDictionary* muDict = nil;
            
            for (int i = 0; i < array.count; i++)
            {
                muDict = [NSMutableDictionary new];
                NSDictionary *article = [array objectAtIndex:i];
                [muDict setObject:[article objectForKey:@"music_title"] forKey:@"music_title"];
                [muDict setObject:[article objectForKey:@"music_author"] forKey:@"music_author"];
                [muDict setObject:[article objectForKey:@"music_path"] forKey:@"music_path"];
                [musicArray addObject:muDict];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
        }];
        [operation start];
    }
    
}

-(void) play
{
    if (nil != musicArray && [musicArray count] != 0)
    {
        NSDictionary *nsDict = [musicArray objectAtIndex:0];
        //[musicAuthor setText:[@"Directed By " stringByAppendingString:[nsDict objectForKey:@"music_author"]]];
        [musicNameLabel setText:[nsDict objectForKey:@"music_title"]];
        
        // set up display updater
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:
                                    [self methodSignatureForSelector:@selector(updateProgress)]];
        [invocation setSelector:@selector(updateProgress)];
        [invocation setTarget:self];
        
        timer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                             invocation:invocation
                                                repeats:YES];
        
        currentMusicNum = 0;
        //使用AVAudioPlayer进行播放
        if (musicLocalOrNet == 1)
        {
            if (!audioPlayer) {
                //把音频文件转换成url格式
                NSURL *musicUrl = [NSURL fileURLWithPath:[nsDict objectForKey:@"music_path"]];
                audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:musicUrl error:nil];
            }
            
            if ([audioPlayer isPlaying])
            {
                [audioPlayer pause];
                [self setBtnPause];
                isVideoToMusicPause = 0;
            }
            else
            {
                [audioPlayer play];
                [self setBtnPlay];
            }
        }
        else //使用AudioStreamer进行播放
        {
            if (!streamer)
            {
                streamer = [[AudioStreamer alloc] initWithURL:[NSURL URLWithString:[nsDict objectForKey:@"music_path"]]];
            }
            
            if ([streamer isPlaying])
            {
                [streamer pause];
                [self setBtnPause];
            }
            else
            {
                [streamer start];
                
                [self setBtnPlay];
            }
        }
        
        
    }
    else  //播放本地音乐
    {
        [self showPlayMusicTips];
    }
}

-(void) stop
{
    // release streamer
    if (musicLocalOrNet == 1)
    {
        if (audioPlayer != nil)
        {
            [audioPlayer stop];
        }
    }
    else
    {
        if (streamer)
        {
            [streamer stop];
        }
    }
}

-(void) next
{
    if (nil != musicArray && [musicArray count] > 0)
    {
        ++currentMusicNum;
        if (currentMusicNum < [musicArray count])
        {
            if (musicLocalOrNet == 1)
            {
                if (audioPlayer)
                {
                    [audioPlayer stop];
                }
            }
            else
            {
                if (streamer)
                {
                    [streamer stop];
                }
            }
            musicProgressView.progress = 0;
            [self playNextMusic:currentMusicNum];
        }
        else
        {
            if (musicLocalOrNet == 1)
            {
                if (audioPlayer)
                {
                    [audioPlayer stop];
                }
            }
            else
            {
                if (streamer)
                {
                    [streamer stop];
                }
            }
            
            if (nil != musicArray)
            {
                currentMusicNum = 0;
                musicProgressView.progress = 0;
                [self playNextMusic:currentMusicNum];
            }
        }
    }
    else
    {
        [self showPlayMusicTips];
    }
}

-(void) previous
{
    if (nil != musicArray && [musicArray count] > 0)
    {
        --currentMusicNum;
        if (currentMusicNum > 0)
        {
            if (musicLocalOrNet == 1)
            {
                if (audioPlayer)
                {
                    [audioPlayer stop];
                }
            }
            else
            {
                if (streamer)
                {
                    [streamer stop];
                }
            }
            musicProgressView.progress = 0;
            [self playNextMusic:currentMusicNum];
        }
        else
        {
            if (musicLocalOrNet == 1)
            {
                if (audioPlayer)
                {
                    [audioPlayer stop];
                }
            }
            else
            {
                if (streamer)
                {
                    [streamer stop];
                }
            }
            
            if (nil != musicArray)
            {
                currentMusicNum = 0;
                musicProgressView.progress = 0;
                [self playNextMusic:currentMusicNum];
            }
        }
    }
    else
    {
        [self showPlayMusicTips];
    }
}

-(void) playNextMusic:(int) _currentMusicNum
{
    NSDictionary *nsDict = [musicArray objectAtIndex:_currentMusicNum];
    if (musicLocalOrNet == 1)
    {
        NSURL *musicUrl = [NSURL fileURLWithPath:[nsDict objectForKey:@"music_path"]];
        audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:musicUrl error:nil];
    }
    else
    {
        streamer = [[AudioStreamer alloc] initWithURL:[NSURL URLWithString:[nsDict objectForKey:@"music_path"]]];
    }
    //[musicAuthor setText:[@"Directed By " stringByAppendingString:[nsDict objectForKey:@"music_author"]]];
    [musicNameLabel setText:[nsDict objectForKey:@"music_title"]];
    
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:
                                [self methodSignatureForSelector:@selector(updateProgress)]];
    [invocation setSelector:@selector(updateProgress)];
    [invocation setTarget:self];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                         invocation:invocation
                                            repeats:YES];
    
    if (musicLocalOrNet == 1)
    {
        if (audioPlayer != nil)
        {
            [audioPlayer play];
            [self setBtnPlay];
        }
    }
    else
    {
        if (nil != streamer)
        {
            [streamer start];
            [self setBtnPlay];
        }
    }
    
}

- (void)updateProgress
{
    if (musicLocalOrNet == 1)
    {
        if(audioPlayer.currentTime < audioPlayer.duration)
        {
            musicProgressView.progress = audioPlayer.currentTime/audioPlayer.duration;
        }
        else
        {
            musicProgressView.progress = 0;
            
            if([timer isValid])
            {
                [timer invalidate];
            }
        }
    }
    else
    {
        if (streamer.progress != 0.0)
        {
            if ((int)streamer.progress < (int)streamer.duration)
            {
                musicProgressView.progress = streamer.progress/streamer.duration;
            }
            else
            {
                musicProgressView.progress = 0;
                if ([streamer isFinishing])
                {
                    if([timer isValid])
                    {
                        [timer invalidate];
                    }
                }
            }
        }
    }
}

-(void) setBtnPause
{
    [musicPlayOrPauseBtn setBackgroundImage:[UIImage imageNamed:@"musicPlayDefault"] forState:UIControlStateNormal];
    [musicPlayOrPauseBtn setBackgroundImage:[UIImage imageNamed:@"musicPlayActivied"] forState:UIControlStateSelected];
    
}

-(void) setBtnPlay
{
    [musicPlayOrPauseBtn setBackgroundImage:[UIImage imageNamed:@"musicPurposeDefault"] forState:UIControlStateNormal];
    [musicPlayOrPauseBtn setBackgroundImage:[UIImage imageNamed:@"musicPurposeActivied"] forState:UIControlStateSelected];
}

-(void)pauseMusic
{
    if (streamer != nil && [streamer isPlaying])
    {
        [streamer pause];
        [self setBtnPause];
    }
    else if (audioPlayer != nil && [audioPlayer isPlaying])
    {
        [audioPlayer pause];
        [self setBtnPause];
        isVideoToMusicPause = 1;
    }
}

-(void)playingMusic
{
    if (streamer != nil && [streamer isPaused])
    {
        [streamer start];
    }
    else if (audioPlayer != nil && isVideoToMusicPause == 1)
    {
        [audioPlayer play];
    }
    
}

-(void) showPlayMusicTips
{
    Reachability *reacheNet = [Reachability reachabilityWithHostname:@"www.baidu.com"];
    switch ([reacheNet currentReachabilityStatus]) {
        case NotReachable: //not network reach
        {
            UIAlertView *musicTips = [[UIAlertView alloc] initWithTitle:@"提醒" message:@"播放音乐，请连接网络！" delegate:self cancelButtonTitle:@"确认" otherButtonTitles:nil];
            [musicTips show];
        }
            break;
        case ReachableViaWWAN: //use 3g network
            NSLog(@"3g network....");
            [self loadMusicPlayMusic];
            
            break;
        case ReachableViaWiFi: //use wifi network
            NSLog(@"wifi network....");
            [self loadMusicPlayMusic];
            break;
        default:
            break;
    }
}
@end
