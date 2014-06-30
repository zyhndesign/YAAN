//
//  DownloadViewController.m
//  JiangHomeStyle
//
//  Created by 工业设计中意（湖南） on 13-12-9.
//  Copyright (c) 2013年 cidesign. All rights reserved.
//

#import "DownloadViewController.h"
#import "../libs/AFNetworking/AFHTTPRequestOperation.h"
#import "../libs/Reachability/Reachability.h"
#import "../Constants.h"
#import "../VarUtils.h"
#import "../libs/AFNetworking/AFJSONRequestOperation.h"
#import "../libs/AFNetworking/AFNetworking.h"
#import "../libs/JSONKit/JSONKit.h"
#import "../classes/FileUtils.h"
#import "../classes/DBUtils.h"
#import "../libs/ZipArchive/ZipArchive.h"
#import "../libs/GDataXml/GDataXMLNode.h"
#import "../classes/DownloadTableViewCell.h"

@interface DownloadViewController ()

@end

extern DBUtils *db;
extern FileUtils *fileUtils;

@implementation DownloadViewController

@synthesize downLoadTableView;

int landscapeDownSign = 0;
int humanityDownSign = 0;
int storyDownSign = 0;
int communityDownSign = 0;

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
    
    isCancelDownloadTask = false;
    
	// Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor clearColor];
    
    musicQueue = [NSOperationQueue new];
    [musicQueue setMaxConcurrentOperationCount:1];
    landscapeQueue = [NSOperationQueue new];
    [landscapeQueue setMaxConcurrentOperationCount:1];
    humanityQueue = [NSOperationQueue new];
    [humanityQueue setMaxConcurrentOperationCount:1];
    storyQueue = [NSOperationQueue new];
    [storyQueue setMaxConcurrentOperationCount:1];
    communityQueue = [NSOperationQueue new];
    [communityQueue setMaxConcurrentOperationCount:1];
    videoQueue = [NSOperationQueue new];
    [videoQueue setMaxConcurrentOperationCount:1];
    
    //异步获取音乐列表并进行下载
    musicArray = [NSMutableArray new];
    
    [self loadMusicData];
    
    NSBundle *bundle = [NSBundle mainBundle];
    NSURL *plistURL = [bundle URLForResource:@"download_zh" withExtension:@"plist"];
    //NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfURL:plistURL];
    downloadArray = [NSArray arrayWithContentsOfURL:plistURL];
    refreshArray = [NSMutableArray new];
    
    for (NSDictionary *dic in downloadArray)
    {
        muDict = [NSMutableDictionary new];
        
        [muDict setObject:[dic objectForKey:@"downLoadName"] forKey:@"downLoadName"];
        [muDict setObject:@"" forKey:@"downloadResult"];
        [muDict setObject:@"" forKey:@"downProgress"];
        [refreshArray addObject:muDict];
    }
   
    
    downLoadTableView.delegate = self;
    downLoadTableView.dataSource = self;
    
    downLoadTableView.tableHeaderView.hidden = YES;
    downLoadTableView.tableFooterView.hidden = YES;
    
    //hidden separate line
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    [downLoadTableView setTableFooterView:v];
    
    //ios7 set separator insets is zoro 
    if ([downLoadTableView respondsToSelector:@selector(setSeparatorInset:)])
    {
        downLoadTableView.separatorInset = UIEdgeInsetsZero;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = 0;
    if (downloadArray != nil)
    {
        count = [downloadArray count];
        if (count == 0)
        {
            downLoadTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        }
        else
        {
            downLoadTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        }
        return count;
    }
    return count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"DownloadCell";
    DownloadTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"DownloadTableViewCell" owner:self options:nil];
        cell = (DownloadTableViewCell *)[nib objectAtIndex:0];
    }
        
    NSMutableDictionary *rowData = [refreshArray objectAtIndex:[indexPath row]];
    
    cell.downLoadName.text = [rowData objectForKey:@"downLoadName"];
    cell.downloadResult.text = [rowData objectForKey:@"downloadResult"];
    cell.downProgress.text = [rowData objectForKey:@"downProgress"];
    
    return cell;
}

//异步加载需要下载的音乐数据
-(void) loadMusicData
{
    NSString *visitPath = [INTERNET_VISIT_PREFIX stringByAppendingString:@"/travel/wp-admin/admin-ajax.php?action=zy_get_music&programId=6"];
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:INTERNET_VISIT_PREFIX]];
    NSMutableURLRequest *request = [httpClient requestWithMethod:@"GET" path:visitPath parameters:nil];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [httpClient registerHTTPOperationClass:[AFHTTPRequestOperation class]];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *nsStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSData* jsonData = [nsStr dataUsingEncoding:NSUTF8StringEncoding];
        
        NSDictionary *nsDict = [jsonData objectFromJSONData];
        NSArray *array = [nsDict objectForKey:@"data"];
        
        //读取music文件夹下的所有音乐文件
        NSArray *musicNameArray = [fileUtils getFileListByDir:[PATH_OF_DOCUMENT stringByAppendingPathComponent:@"music"]];
        
        for (int i = 0; i < array.count; i++)
        {
            muDict = [NSMutableDictionary new];
            NSDictionary *article = [array objectAtIndex:i];
            //和音乐文件夹下的文件进行比较，查看是否已经下载，如果存在则不进行重复下载
            
            if (![musicNameArray containsObject:[[NSString stringWithFormat:@"%@",[article objectForKey:@"music_id"]] stringByAppendingString:@".mp3"]])
            {
                [muDict setObject:[article objectForKey:@"music_title"] forKey:@"musicTitle"];
                [muDict setObject:[article objectForKey:@"music_author"] forKey:@"musicAuthor"];
                [muDict setObject:[article objectForKey:@"music_path"] forKey:@"musicPath"];
                [muDict setObject:[article objectForKey:@"music_name"] forKey:@"musicName"];
                [muDict setObject:[article objectForKey:@"music_id"] forKey:@"musicID"];
                [muDict setObject:[article objectForKey:@"music_size"] forKey:@"musicSize"];
                [musicArray addObject:muDict];
            }
        }
        
        if ([musicArray count] > 0)
        {
            [self downloadMusicFile:musicArray];
        }
        else
        {
            [self downloadIsComplete:0];
            
            [self downloadArticles];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
    [operation start];
}

-(void) downloadMusicFile:(NSArray *)dataArray
{
    __block int successNum = 0;
    __block int failureNum = 0;
    __block long long totalFileSize = 0;
    __block long long alreadyDownSize = 0;
    
    for(NSMutableDictionary *obj in dataArray)
    {
        NSString *path = [obj objectForKey:@"musicPath"];
        NSString *musicName = [[NSString stringWithFormat:@"%@",[obj objectForKey:@"musicID"]] stringByAppendingString:@".mp3"];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
        NSString *savePath = [[PATH_OF_DOCUMENT stringByAppendingPathComponent:@"music"] stringByAppendingPathComponent:musicName];
        
        NSString* fileSizeStr = [obj objectForKey:@"musicSize"];
        totalFileSize = totalFileSize + [fileSizeStr longLongValue];
        
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        operation.outputStream = [NSOutputStream outputStreamToFileAtPath:savePath append:NO];
        
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            alreadyDownSize = alreadyDownSize + [fileSizeStr longLongValue];
            ++successNum;
            //往数据库中写入下载完成纪录
            [obj setObject:savePath forKey:@"musicPath"];
            [db insertMusicData:obj];
            //如果所有文件下载完毕
            if (alreadyDownSize == totalFileSize)
            {
                //如果任务没有取消
                if (!isCancelDownloadTask)
                {
                    [self downloadArticles];
                }
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            alreadyDownSize = alreadyDownSize + [fileSizeStr longLongValue];
            ++failureNum;
            
            if (alreadyDownSize == totalFileSize)
            {
                if (!isCancelDownloadTask)
                {
                    [self downloadArticles];
                }
            }
        }];
        [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
            
            float percent = ((float)totalBytesRead + alreadyDownSize)/(float)totalFileSize * 100;
            [self refreshTableViewByCategory:0 successNum:successNum failureNum:failureNum downloadPercent:percent];
            
        }];
        [musicQueue addOperation:operation];
    }
}

//获取需要下载的类别数据，队列顺序异步进行下载
-(void) downloadDataByCategory:(int) category
{
    
    NSMutableArray* categoryDataArray = [db queryDownloadDataByCategory:category];
   
    __block long long totalFileSize = 0;
    __block long long alreadyDownSize = 0;
    __block int successNum = 0;
    __block int failureNum = 0;
    
    
    if ([categoryDataArray count] > 0)
    {
        for (NSMutableDictionary *nsDict in categoryDataArray)
        {
            NSString *filePath = [[[[PATH_OF_DOCUMENT stringByAppendingPathComponent:@"articles"] stringByAppendingPathComponent:[nsDict objectForKey:@"serverID"]] stringByAppendingPathComponent:@"doc"] stringByAppendingPathComponent:@"main.html"];
       
            if (![fileUtils fileISExist:filePath])
            {
                NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[nsDict objectForKey:@"url"]]];
                NSString* archivePath = [[[PATH_OF_DOCUMENT stringByAppendingPathComponent:@"temp"] stringByAppendingPathComponent:[nsDict objectForKey:@"serverID"]] stringByAppendingString:@".zip"];
                NSString *articlesPath = [PATH_OF_DOCUMENT stringByAppendingPathComponent:@"articles"];
                NSString* fileSizeStr = [nsDict objectForKey:@"size"];
                totalFileSize = totalFileSize + [fileSizeStr longLongValue];
                
                AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
                operation.outputStream = [NSOutputStream outputStreamToFileAtPath:archivePath append:NO];
                [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                    NSLog(@"loading zip is success");
                        
                    //解压文件 ,
                    BOOL result = FALSE;
                    ZipArchive *zip = [ZipArchive new];
                    if ([zip UnzipOpenFile:archivePath])
                    {
                        result = [zip UnzipFileTo:articlesPath overWrite:YES];
                    }
                    else
                    {
                        NSLog(@"there is no zip file");
                    }
                        
                    [db updateSignByServerId:[nsDict objectForKey:@"serverID"]];
                        
                    if (result)
                    {
                        NSLog(@"unzip file is success and delete the zip file");
                        [fileUtils removeAtPath:archivePath];
                    }
                    else
                    {
                        NSLog(@"unzip file is failure");
                    }
                    alreadyDownSize = alreadyDownSize + [fileSizeStr longLongValue];
                    if (alreadyDownSize == totalFileSize)
                    {
                        //下载完毕
                        [self updateDownLoadSing:category];
                        
                        [self launchDownloadVideo];
                    }
                    ++successNum;
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    NSLog(@"loading zip is failure %@",[error description]);
                    alreadyDownSize = alreadyDownSize + [fileSizeStr longLongValue];
                    if (alreadyDownSize == totalFileSize)
                    {
                        //下载完毕
                        [self updateDownLoadSing:category];
                    }
                    ++failureNum;
                    [self launchDownloadVideo];
                }];
                [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
                    float percent = ((float)totalBytesRead + alreadyDownSize)/(float)totalFileSize * 100;
                    
                    if (category == LANDSCAPE_CATEGORY)
                    {
                        [self refreshTableViewByCategory:1 successNum:successNum failureNum:failureNum downloadPercent:percent];
                    }
                    else if (category == HUMANITY_CATEGORY)
                    {
                        [self refreshTableViewByCategory:2 successNum:successNum failureNum:failureNum downloadPercent:percent];
                    }
                    else if (category == STORY_CATEGORY)
                    {
                        [self refreshTableViewByCategory:3 successNum:successNum failureNum:failureNum downloadPercent:percent];

                    }
                    else if (category == COMMUNITY_CATEGORY)
                    {
                        [self refreshTableViewByCategory:4 successNum:successNum failureNum:failureNum downloadPercent:percent];
                    }
                    
                    [downLoadTableView reloadData];
                }];
                
                if (category == LANDSCAPE_CATEGORY)
                {
                    [landscapeQueue addOperation:operation];
                }
                else if (category == HUMANITY_CATEGORY)
                {
                    [humanityQueue addOperation:operation];
                }
                else if (category == STORY_CATEGORY)
                {
                    [storyQueue addOperation:operation];
                }
                else if (category == COMMUNITY_CATEGORY)
                {
                    [communityQueue addOperation:operation];
                }
            }
            else
            {
                [db updateSignByServerId:[nsDict objectForKey:@"serverID"]];
            }
        }
        
    }
    else
    {
        if (category == LANDSCAPE_CATEGORY)
        {
            [self downloadIsComplete:1];
        }
        else if (category == HUMANITY_CATEGORY)
        {
            [self downloadIsComplete:2];
        }
        else if (category == STORY_CATEGORY)
        {
            [self downloadIsComplete:3];
        }
        else if (category == COMMUNITY_CATEGORY)
        {
            [self downloadIsComplete:4];
        }
        
        [self updateDownLoadSing:category];
        
        [self launchDownloadVideo];
    }
}

-(void) downloadVideo
{
    
    NSMutableArray *videoArray = [db getVideoData];
    NSMutableArray *videoDownArray = [NSMutableArray new];
    NSMutableDictionary *urlDict;
    
    long long totalFileSize = 0;
    __block long long alreadyDownSize = 0;
    __block int successNum = 0;
    __block int failureNum = 0;
    
    for (NSMutableDictionary *nsDict in videoArray)
    {
        //解析doc.xml文件，获取showUrl地址，videoUrl
        NSString *docFilePath   =  [[[PATH_OF_DOCUMENT stringByAppendingPathComponent:@"articles"] stringByAppendingPathComponent:[nsDict objectForKey:@"serverID"]]  stringByAppendingPathComponent:@"doc.xml"];
        
        
        //NSString *jsonString  =   [NSString stringWithContentsOfFile:docFilePath encoding:NSUTF8StringEncoding error:nil];
        NSData *xmlData = [[NSData alloc] initWithContentsOfFile:docFilePath];
        
        //使用NSData对象初始化
        GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData  options:0 error:nil];
        
        //获取根节点（doc）
        GDataXMLElement *rootElement = [doc rootElement];
        
        
        //获取根节点下的节点（videoItems）
        NSArray *videoItems = [rootElement elementsForName:@"videoItems"];
        
        
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
                    //NSLog(@"showUrl is:%@",showUrl);
                    
                    //获取videoUrl节点的值
                    GDataXMLElement *ageElement = [[video elementsForName:@"videoUrl"] objectAtIndex:0];
                    videoUrl = [ageElement stringValue];
                    //NSLog(@"videoUrl is:%@",videoUrl);
                    
                    //
                    GDataXMLElement *sizeElement = [[video elementsForName:@"size"] objectAtIndex:0];
                    //fileSize = [[sizeElement stringValue] longLongValue];
                    fileSize = [sizeElement stringValue];
                    //NSLog(@"fileSize is:%@",fileSize);
                    
                    [urlDict setValue:videoUrl forKey:@"videoUrl"];
                    [urlDict setValue:showUrl forKey:@"showUrl"];
                    [urlDict setValue:fileSize forKey:@"fileSize"];
                    [videoDownArray addObject:urlDict];
                }
            }
        }
    }
    
    if ([videoDownArray count] > 0)
    {
        //读取video文件夹下的所有视频文件
        NSArray *videoIsDownArray = [fileUtils getFileListByDir:[PATH_OF_DOCUMENT stringByAppendingPathComponent:@"video"]];
        
        int countDown = 0;
        
        for (NSMutableDictionary *nsDict in videoDownArray)
        {
            if (![videoIsDownArray containsObject:[self getFileNameFromUrl:[nsDict objectForKey:@"videoUrl"]]])
            {
                countDown++;
                totalFileSize = totalFileSize + [[nsDict objectForKey:@"fileSize"] longLongValue];
            }
        }
        for (NSMutableDictionary *nsDict in videoDownArray)
        {
            if (![videoIsDownArray containsObject:[self getFileNameFromUrl:[nsDict objectForKey:@"videoUrl"]]])
            {
                NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[[nsDict objectForKey:@"videoUrl"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
                NSString* archivePath = [[PATH_OF_DOCUMENT stringByAppendingPathComponent:@"video"] stringByAppendingPathComponent:[self getFileNameFromUrl:[nsDict objectForKey:@"videoUrl"]]];
                NSString* fileSizeStr = [nsDict objectForKey:@"fileSize"];
                AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
                operation.outputStream = [NSOutputStream outputStreamToFileAtPath:archivePath append:NO];
                [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                       alreadyDownSize = alreadyDownSize + [fileSizeStr longLongValue];
                        NSLog(@"download success");
                        ++successNum;
                    
                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                       alreadyDownSize = alreadyDownSize + [fileSizeStr longLongValue];
                        NSLog(@"download failure");
                        ++failureNum;
                    }];
                    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
                     
                        float percent = ((float)totalBytesRead + alreadyDownSize)/(float)totalFileSize * 100;
                        [self refreshTableViewByCategory:5 successNum:successNum failureNum:failureNum downloadPercent:percent];
                    }];
                
                [videoQueue addOperation:operation];
            }
        }
    }
    
    if ([videoQueue operationCount] == 0)
    {
        [self downloadIsComplete:5];
    }
}

-(void) downloadArticles
{
    [self downloadDataByCategory:0];
    [self downloadDataByCategory:1];
    [self downloadDataByCategory:2];
    [self downloadDataByCategory:3];
}

-(void) updateDownLoadSing:(int)category
{
    if (category == LANDSCAPE_CATEGORY)
    {
        landscapeDownSign = 1;
    }
    else if (category == HUMANITY_CATEGORY)
    {
        humanityDownSign = 1;
    }
    else if (category == STORY_CATEGORY)
    {
        storyDownSign = 1;
    }
    else if (category == COMMUNITY_CATEGORY)
    {
        communityDownSign = 1;
    }
}

-(void) refreshTableViewByCategory:(int)category
                        successNum:(int)successNum
                        failureNum:(int)failureNum
                   downloadPercent:(float)downloadPercent
{
    NSDictionary *item = [downloadArray objectAtIndex:category];
    NSDictionary *refreshItem = [refreshArray objectAtIndex:category];
    NSMutableDictionary *mutableItem = [NSMutableDictionary dictionaryWithDictionary:refreshItem];
    
    [mutableItem setValue:[item objectForKey:@"downloadName"] forKey:@"downloadName"];
    [mutableItem setValue:[NSString stringWithFormat:[item objectForKey:@"downloadResult"], successNum, failureNum] forKey:@"downloadResult"];
    [mutableItem setValue:[NSString stringWithFormat:[item objectForKey:@"downProgress"], downloadPercent] forKey:@"downProgress"];
    
    [refreshArray setObject:mutableItem atIndexedSubscript:category];
    
    [downLoadTableView reloadData];
}

-(void) downloadIsComplete:(int)category
{
    NSDictionary *item = [downloadArray objectAtIndex:category];
    NSDictionary *refreshItem = [refreshArray objectAtIndex:category];
    NSMutableDictionary *mutableItem = [NSMutableDictionary dictionaryWithDictionary:refreshItem];
    [mutableItem setValue:[item objectForKey:@"downloadName"] forKey:@"downloadName"];
    [mutableItem setValue:@"当前栏目下载完毕" forKey:@"downloadResult"];
    [mutableItem setValue:[NSString stringWithFormat:[item objectForKey:@"downProgress"], 100.00] forKey:@"downProgress"];
    [refreshArray setObject:mutableItem atIndexedSubscript:category];
    [downLoadTableView reloadData];
}

-(void)launchDownloadVideo
{
    if (landscapeDownSign == 1 && humanityDownSign == 1 && storyDownSign == 1 && communityDownSign == 1)
    {
        //如果任务没有取消，则启动视频下载
        if (!isCancelDownloadTask)
        {
             [self downloadVideo];
        }
    }
}

-(NSString *)getFileNameFromUrl:(NSString *)url
{
    NSArray *array = [url componentsSeparatedByString:@"/"];
    
    return [array objectAtIndex:([array count] - 1)];
}

- (IBAction)closeWin:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(closeButtonClicked)])
    {
        isCancelDownloadTask = true;
        
        [musicQueue cancelAllOperations];
        [landscapeQueue cancelAllOperations];
        [humanityQueue cancelAllOperations];
        [storyQueue cancelAllOperations];
        [communityQueue cancelAllOperations];
        [videoQueue cancelAllOperations];
        
        [self.delegate closeButtonClicked];
    }
}
@end
