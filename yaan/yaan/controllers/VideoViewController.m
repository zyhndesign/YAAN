//
//  VideoViewController.m
//  JiangHomeStyle
//
//  Created by 工业设计中意（湖南） on 13-12-16.
//  Copyright (c) 2013年 cidesign. All rights reserved.
//

#import "VideoViewController.h"
#import <MediaPlayer/MPMoviePlayerController.h>
#import "PopupDetailViewController.h"
#import <AVFoundation/AVAudioSession.h>

@interface VideoViewController ()

@end

@implementation VideoViewController

@synthesize url;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andUrl:(NSString *)_url
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    self.url = _url;
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    
	// Do any additional setup after loading the view.
    
    NSURL* fileURl = [NSURL fileURLWithPath:url];
        
    mp = [[MPMoviePlayerViewController alloc] initWithContentURL:fileURl];
    //mp.view.frame = CGRectMake(0, 0, 1024, 768);
    [mp.view setFrame:self.view.bounds];
    [self.view addSubview:mp.view];
    player = [mp moviePlayer];
    //[player setRepeatMode:MPMovieRepeatModeOne];
    //mp.view.userInteractionEnabled = NO;
    player.shouldAutoplay = YES;
    player.controlStyle = MPMovieControlStyleFullscreen;
    player.scalingMode = MPMovieScalingModeAspectFill;
    
    //[player setFullscreen:YES];
    [player play];

    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(playingPauseVideo) name:@"PLAYING_PAUSE_VIDEO" object:nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PAUSE_MUSIC_PAUSE" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(myMovieFinishedCallback:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:player];
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
}

-(void)myMovieFinishedCallback:(NSNotification*)notify
{
    [player stop];
    [self dismissViewControllerAnimated:YES completion:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"STOP_MOVE_PLAYER" object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)playingPauseVideo
{
    if (nil != player && mp != nil)
    {
        [player play];
    }
}

-(void) dealloc
{
    NSLog(@"release resources .....");
    [player stop];
    player = nil;
    mp = nil;
    NSLog(@"dealloc exec .....");
}

@end
