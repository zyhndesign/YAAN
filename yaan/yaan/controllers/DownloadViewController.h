//
//  DownloadViewController.h
//  JiangHomeStyle
//
//  Created by 工业设计中意（湖南） on 13-12-9.
//  Copyright (c) 2013年 cidesign. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DownloadProtocol <NSObject>

- (void) closeButtonClicked;

@end

@interface DownloadViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
{
    IBOutlet UITableView *downLoadTableView;
    
    NSMutableArray *musicArray;
    NSMutableDictionary* muDict;
    
    NSString *showUrl;
    NSString *videoUrl;
    NSString *fileSize;
    
    NSOperationQueue *musicQueue;
    NSOperationQueue *landscapeQueue;
    NSOperationQueue *humanityQueue;
    NSOperationQueue *storyQueue;
    NSOperationQueue *communityQueue;
    NSOperationQueue *videoQueue;
    
    NSArray *downloadArray;
    NSMutableArray *refreshArray;
    
    BOOL isCancelDownloadTask;
}

@property (nonatomic, strong) IBOutlet UITableView *downLoadTableView;

@property (strong, nonatomic) id delegate;

- (IBAction)closeWin:(id)sender;

//异步加载需要下载的音乐数据
-(void) loadMusicData;

/**
 *  队列顺序异步下载音乐数据
 *
 *  @param dataArray 音乐存储列表
 */
-(void) downloadMusicFile:(NSArray *)dataArray;

/**
 *  获取需要下载的类别数据，队列顺序异步进行下载
 *
 *  @param category 下载所属文章类别
 */
-(void) downloadDataByCategory:(int) category;

/**
 *  下载数据刷新TableView进行显示
 *
 *  @param category        类别
 *  @param successNum      成功数
 *  @param failureNum      失败数
 *  @param downloadPercent 下载百分比
 */
-(void) refreshTableViewByCategory:(int)category
                        successNum:(int)successNum
                        failureNum:(int)failureNum
                   downloadPercent:(float)downloadPercent;

/**
 *  从下载URL中获取下载文件的文件名
 *
 *  @param url URL链接地址
 *
 *  @return 文件名
 */
-(NSString *)getFileNameFromUrl:(NSString *)url;

/**
 *  按照类别更新该类别是否下载完毕
 *
 *  @param category 类别编号 （风景：0，人文：1， 物语：2， 社区：3）
 */
-(void) updateDownLoadSing:(int)category;

/**
 *  启动四类文章同时下载
 *
 *  （风景，人文， 物语， 社区）
 */
-(void) downloadArticles;

/**
 *  启动视频文件下载
 */
-(void)launchDownloadVideo;
@end

