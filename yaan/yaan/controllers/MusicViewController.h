//
//  MusicViewController.h
//  NewTD
//
//  Created by 工业设计中意（湖南） on 14-5-15.
//  Copyright (c) 2014年 中意工业设计（湖南）有限责任公司. All rights reserved.
//

#import "ViewController.h"

@class AudioStreamer;
@class AVAudioPlayer;

@interface MusicViewController : UIViewController
{
    IBOutlet UIButton *musicPreviousBtn;
    IBOutlet UIButton *musicPlayOrPauseBtn;
    IBOutlet UIButton *musicNextBtn;
    
    IBOutlet UIProgressView *musicProgressView;
    
    IBOutlet UILabel *musicNameLabel;
    
    NSMutableArray *musicArray;
    
    AudioStreamer *streamer;
    AVAudioPlayer *audioPlayer;
    
    NSURL *url;
    NSTimer *timer;
    int currentMusicNum;
    
    int isVideoToMusicPause; //纪录是否是因为视频播放引起暂停
}

@property (strong, nonatomic) IBOutlet UIButton *musicPreviousBtn;
@property (strong, nonatomic) IBOutlet UIButton *musicPlayOrPauseBtn;
@property (strong, nonatomic) IBOutlet UIButton *musicNextBtn;
@property (strong, nonatomic) IBOutlet UILabel *musicNameLabel;

@property (strong, nonatomic) IBOutlet UIProgressView *musicProgressView;

- (IBAction)musicPreviousBtnClick:(id)sender;

- (IBAction)musicPlayOrPauseBtnClick:(id)sender;

- (IBAction)musicNextBtnClick:(id)sender;

//========================================================================================
/* 音乐播放模块核心部分使用的是AudioPlayer和AudioStreamer库来完成，当播放已经离线的音乐是采用AudioPlayer
 * 来完成，播放在线的网络音乐则使用AudioStreamer来实现。在线播放主要解决可以边播放边缓冲。
 */

/**
 *  暂停播放音乐， 分别判断在streamer 和 audioPlayer 播放模式下，音乐是否在播放，如果在播放则完成暂停处理
 */
-(void)pauseMusic;

/**
 *  播放音乐，分别判断在streamer 和 audioPlayer 播放模式下进行启动
 */
-(void)playingMusic;

/**
 *  音乐播放时候的网络状态提醒，如果本地没有离线缓存音乐，则只能使用网路播放
 */
-(void) showPlayMusicTips;

/**
 *  设置播放按钮状态为暂停，加载暂停的图片
 */
-(void) setBtnPause;

/**
 *  设置播放按钮当前为播放状态，加载播放图片
 */
-(void) setBtnPlay;

/**
 *  更新播放进度条的值
 */
-(void)updateProgress;

/**
 *  播放下一首音乐
 *
 *  @param _currentMusicNum 播放序号
 */
-(void) playNextMusic:(int) _currentMusicNum;

/**
 *  播放音乐
 */
-(void)play;

/**
 *  停止播放
 */
-(void)stop;

/**
 *  播放下一首
 */
-(void) next;

/**
 *  从网络或者本地加载音乐数据
 */
-(void) loadMusicPlayMusic;
@end
