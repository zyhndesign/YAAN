//
//  DBUtils.m
//  JiangHomeStyle
//
//  Created by 工业设计中意（湖南） on 13-9-5.
//  Copyright (c) 2013年 cidesign. All rights reserved.
//

#import "DBUtils.h"
#import "../libs/FMDB/FMDatabase.h"
#import "../VarUtils.h"
#import "../Constants.h"

@implementation DBUtils

NSString* path = nil;

-(id) init
{
    if (!(self = [super init]))
    {
        return nil;
    }
    
    NSLog(@"init databse.....");
    
    path = [PATH_OF_DOCUMENT stringByAppendingPathComponent:@"NewTD.db"];
    
    [self createArticleTable];
    [self createMusicTable];
    return self;
    
}

- (BOOL) createArticleTable
{
    NSFileManager* fileManager = [NSFileManager defaultManager];
        
    if ([fileManager fileExistsAtPath:PATH_OF_DOCUMENT] == YES)
    {
        FMDatabase *db = [FMDatabase databaseWithPath:path];
        if ([db open])
        {
            NSString* sql = @"CREATE TABLE IF NOT EXISTS 'contentlist' ('serverID' VARCHAR(40) PRIMARY KEY NOT NULL,'size' INTEGER,'url' text,'timestamp' VARCHAR(20),'md5' VARCHAR(40),'insertDate' VARCHAR(25),'title' TEXT,'profile_path' TEXT,'post_date' VARCHAR(15),'author' VARCHAR(30),'description' TEXT,'category' INTEGER,'main_file_path' TEXT,'max_bg_img' TEXT,'isHeadline' INTEGER,'operation' VARCHAR(1),'hasVideo' INTEGER, 'isDownload' INTEGER)";
            
            BOOL res = [db executeUpdate:sql];
            if (!res)
            {
                [db close];
                return NO;
            }
            else
            {
                [db close];
                return YES;
            }
        }
        else
        {
            return NO;
        }
    }
    return NO;
}

- (BOOL) createMusicTable
{
    NSFileManager* fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:PATH_OF_DOCUMENT] == YES)
    {
        FMDatabase *db = [FMDatabase databaseWithPath:path];
        if ([db open])
        {
            NSString* sql = @"CREATE TABLE IF NOT EXISTS 'musiclist' ('musicID' INTEGER PRIMARY KEY NOT NULL,'musicName' VARCHAR(50),'musicAuthor' VARCHAR(35),'musicTitle' VARCHAR(50),'musicPath' text)";
            
            BOOL res = [db executeUpdate:sql];
            if (!res)
            {
                [db close];
                return NO;
            }
            else
            {
                [db close];
                return YES;
            }
        }
        else
        {
            return NO;
        }
    }
    return NO;
}

//写入新的纪录
- (BOOL) insertData:(NSMutableDictionary *) nsDict
{
    FMDatabase* db = [FMDatabase databaseWithPath:path];
    
    if ([db open])
    {
        NSString *sql = @"insert into contentlist (serverID,size,url,timestamp,md5,insertDate,title,profile_path,post_date,author,description,category,main_file_path,max_bg_img,isHeadline,operation,hasVideo,isDownload) values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
        BOOL res = [db executeUpdate:sql,
                    [nsDict objectForKey:@"serverID"],
                    [nsDict objectForKey:@"size"],
                    [nsDict objectForKey:@"url"],
                    [nsDict objectForKey:@"timestamp"],
                    [nsDict objectForKey:@"md5"],
                    [nsDict objectForKey:@"insertDate"],
                    [nsDict objectForKey:@"title"],
                    [nsDict objectForKey:@"profile_path"],
                    [nsDict objectForKey:@"post_date"],
                    [nsDict objectForKey:@"author"],
                    [nsDict objectForKey:@"description"],
                    [nsDict objectForKey:@"category"],
                    [nsDict objectForKey:@"main_file_path"],
                    [nsDict objectForKey:@"max_bg_img"],
                    [nsDict objectForKey:@"isHeadline"],
                    [nsDict objectForKey:@"operation"],
                    [nsDict objectForKey:@"hasVideo"],
                    [nsDict objectForKey:@"isDownload"]];
        
        
        if (res)
        {
            [db close];
            return YES;
        }
        else
        {
            NSLog(@"%@",[db lastErrorMessage]);
            [db close];
            return NO;
        }
    }
    return NO;
}

//根据serverID 查询详细数据
- (NSMutableDictionary *) queryByServerID:(NSString*) serverId
{
    FMDatabase* db = [FMDatabase databaseWithPath:path];
    NSMutableDictionary *nsDict= [NSMutableDictionary new];
    if ([db open])
    {
        NSString* sql = [[@"select * from contentlist where serverID = '" stringByAppendingString:serverId] stringByAppendingString:@"'"];
        FMResultSet *rs = [db executeQuery:sql];
        if ([rs next])
        {            
            [nsDict setValue:[rs stringForColumn:@"serverID"] forKey:@"serverID"];
            [nsDict setValue:[NSNumber numberWithInt:[rs intForColumn:@"size"]] forKey:@"size"];
            [nsDict setValue:[rs stringForColumn:@"url"] forKey:@"url"];
            [nsDict setValue:[rs stringForColumn:@"timestamp"] forKey:@"timestamp"];
            [nsDict setValue:[rs stringForColumn:@"md5"] forKey:@"md5"];
            [nsDict setValue:[rs stringForColumn:@"insertDate"] forKey:@"insertDate"];
            [nsDict setValue:[rs stringForColumn:@"title"] forKey:@"title"];
            [nsDict setValue:[rs stringForColumn:@"profile_path"] forKey:@"profile_path"];
            [nsDict setValue:[rs stringForColumn:@"post_date"] forKey:@"post_date"];
            [nsDict setValue:[rs stringForColumn:@"author"] forKey:@"author"];
            [nsDict setValue:[rs stringForColumn:@"description"] forKey:@"description"];
            [nsDict setValue:[NSNumber numberWithInt:[rs intForColumn:@"category"]] forKey:@"category"];
            [nsDict setValue:[rs stringForColumn:@"main_file_path"] forKey:@"main_file_path"];
            [nsDict setValue:[rs stringForColumn:@"max_bg_img"] forKey:@"max_bg_img"];
            [nsDict setValue:[NSNumber numberWithInt:[rs intForColumn:@"isHeadline"]] forKey:@"isHeadline"];
            [nsDict setValue:[rs stringForColumn:@"operation"] forKey:@"operation"];
            [nsDict setValue:[NSNumber numberWithInt:[rs intForColumn:@"hasVideo"]] forKey:@"hasVideo"];
            [nsDict setValue:[NSNumber numberWithInt:[rs intForColumn:@"isDownload"]] forKey:@"isDownload"];
        }
        [db close];
        return nsDict;        
    }
    return nil;
}

-(NSString *) getDownUrlByServerId:(NSString *) serverId
{
    FMDatabase* db = [FMDatabase databaseWithPath:path];
    NSString *str = nil;
    if ([db open])
    {
        NSString* sql = [[@"select url from contentlist where serverID = '" stringByAppendingString:serverId] stringByAppendingString:@"'"];
        FMResultSet *rs = [db executeQuery:sql];
        if ([rs next])
        {
            str = [rs stringForColumn:@"url"];
        }
        [db close];
        return str;
    }
    return nil;
}

//根据类别获取该类别下所有数据，并且以发布时间降序排列
- (NSMutableArray*) queryByCategory:(int) category
{
    FMDatabase* db = [FMDatabase databaseWithPath:path];
    NSMutableArray *array = [NSMutableArray new];
    NSMutableDictionary *nsDict = nil;
    if ([db open])
    {
        NSString* sql = [[@"select * from contentlist where category = " stringByAppendingFormat:@"%d", category] stringByAppendingString:@" order by post_date desc"];
        FMResultSet *rs = [db executeQuery:sql];
        while ([rs next])
        {
            nsDict = [NSMutableDictionary new];
            [nsDict setValue:[rs stringForColumn:@"serverID"] forKey:@"serverID"];
            [nsDict setValue:[rs stringForColumn:@"url"] forKey:@"url"];
            [nsDict setValue:[rs stringForColumn:@"timestamp"] forKey:@"timestamp"];
            [nsDict setValue:[rs stringForColumn:@"title"] forKey:@"title"];
            [nsDict setValue:[rs stringForColumn:@"profile_path"] forKey:@"profile_path"];
            [nsDict setValue:[rs stringForColumn:@"post_date"] forKey:@"post_date"];
            [nsDict setValue:[rs stringForColumn:@"author"] forKey:@"author"];
            [nsDict setValue:[rs stringForColumn:@"description"] forKey:@"description"];
            [nsDict setValue:[rs stringForColumn:@"main_file_path"] forKey:@"main_file_path"];
            [nsDict setValue:[rs stringForColumn:@"max_bg_img"] forKey:@"max_bg_img"];
            [nsDict setValue:[NSNumber numberWithInt:[rs intForColumn:@"hasVideo"]] forKey:@"hasVideo"];
            [nsDict setValue:[NSNumber numberWithInt:[rs intForColumn:@"isDownload"]] forKey:@"isDownload"];
            [array addObject:nsDict];
        }
        [db close];
    }
    return array;
}

//根据类别获取该类别下所有下载数据
- (NSMutableArray*) queryDownloadDataByCategory:(int) category
{
    FMDatabase* db = [FMDatabase databaseWithPath:path];
    NSMutableArray *array = [NSMutableArray new];
    NSMutableDictionary *nsDict = nil;
    if ([db open])
    {
        NSString* sql = [@"select serverID,url,hasVideo,size from contentlist where isDownload = 0 and category = " stringByAppendingFormat:@"%d", category];
                FMResultSet *rs = [db executeQuery:sql];
        while ([rs next])
        {
            nsDict = [NSMutableDictionary new];
            [nsDict setValue:[rs stringForColumn:@"serverID"] forKey:@"serverID"];
            [nsDict setValue:[rs stringForColumn:@"url"] forKey:@"url"];
            [nsDict setValue:[NSNumber numberWithInt:[rs intForColumn:@"hasVideo"]] forKey:@"hasVideo"];
            [nsDict setValue:[NSNumber numberWithInt:[rs intForColumn:@"size"]] forKey:@"size"];
            [array addObject:nsDict];
        }
        [db close];
    }
    return array;
}

//获取头条文章数据 （按照时间降序排列取前面4条）
- (NSMutableArray*) queryHeadline
{
    FMDatabase* db = [FMDatabase databaseWithPath:path];
    NSMutableArray *array = [NSMutableArray new];
    NSMutableDictionary *nsDict = nil;
    if ([db open])
    {
        NSString* sql = @"select * from contentlist where isHeadline = 1 order by post_date desc limit 3";
        FMResultSet *rs = [db executeQuery:sql];
        while ([rs next])
        {
            nsDict = [NSMutableDictionary new];
            [nsDict setValue:[rs stringForColumn:@"serverID"] forKey:@"serverID"];
            [nsDict setValue:[rs stringForColumn:@"url"] forKey:@"url"];
            [nsDict setValue:[rs stringForColumn:@"timestamp"] forKey:@"timestamp"];
            [nsDict setValue:[rs stringForColumn:@"title"] forKey:@"title"];
            [nsDict setValue:[rs stringForColumn:@"profile_path"] forKey:@"profile_path"];
            [nsDict setValue:[rs stringForColumn:@"post_date"] forKey:@"post_date"];
            [nsDict setValue:[rs stringForColumn:@"author"] forKey:@"author"];
            [nsDict setValue:[rs stringForColumn:@"description"] forKey:@"description"];
            [nsDict setValue:[rs stringForColumn:@"main_file_path"] forKey:@"main_file_path"];
            [nsDict setValue:[rs stringForColumn:@"max_bg_img"] forKey:@"max_bg_img"];
            [nsDict setValue:[NSNumber numberWithInt:[rs intForColumn:@"hasVideo"]] forKey:@"hasVideo"];
            [nsDict setValue:[NSNumber numberWithInt:[rs intForColumn:@"isDownload"]] forKey:@"isDownload"];
            [array addObject:nsDict];
        }
        [db close];
    }
    return array;
}

//判断数据库contentlist表中是否有数据
-(BOOL) countArticlesIsEmpty
{
    FMDatabase* db = [FMDatabase databaseWithPath:path];
    if ([db open])
    {
        NSString* sql = @"select * from contentlist";
        FMResultSet *rs = [db executeQuery:sql];
        if ([rs next])
        {
            NSLog(@"has data in database");
            [db close];
            return NO;
        }
        else
        {
            NSLog(@"not has data in database");
            [db close];
            return YES;
        }
    }
    return YES;
}

//根据serverId删除数据
-(BOOL) deleteDataByServerId:(NSString *)serverId
{
    FMDatabase* db = [FMDatabase databaseWithPath:path];
    if ([db open])
    {
        NSString* sql = [[@"delete from contentlist where serverID = '" stringByAppendingString:serverId] stringByAppendingString:@"'"];
        
        BOOL res = [db executeUpdate:sql];
        if (res)
        {
            [db close];
            return YES;
        }
        else
        {
            [db close];
            return NO;
        }
    }
    return NO;
}

//按照serverId更新数据
-(BOOL) updateDataByServerId:(NSString *)serverId withDict:(NSMutableDictionary *) muDict
{
    if ([[self queryByServerID:serverId] count] > 0)
    {
        NSLog(@"update data");
        FMDatabase* db = [FMDatabase databaseWithPath:path];
        if ([db open])
        {
            NSString* sql = [[@"update contentlist set size=?,url=?,timestamp=?,md5=?,insertDate=?,title=?,profile_path=?,post_date=?,author=?,description=?,category=?,main_file_path=?,max_bg_img=?,isHeadline=?,operation=?,hasVideo=?,isDownload=? where serverID ='" stringByAppendingString:serverId] stringByAppendingString:@"'"];
            BOOL res = [db executeUpdate:sql, [muDict objectForKey:@"size"],
                        [muDict objectForKey:@"url"],
                        [muDict objectForKey:@"timestamp"],
                        [muDict objectForKey:@"md5"],
                        [muDict objectForKey:@"insertDate"],
                        [muDict objectForKey:@"title"],
                        [muDict objectForKey:@"profile_path"],
                        [muDict objectForKey:@"post_date"],
                        [muDict objectForKey:@"author"],
                        [muDict objectForKey:@"description"],
                        [muDict objectForKey:@"category"],
                        [muDict objectForKey:@"main_file_path"],
                        [muDict objectForKey:@"max_bg_img"],
                        [muDict objectForKey:@"isHeadline"],
                        [muDict objectForKey:@"operation"],
                        [muDict objectForKey:@"hasVideo"],
                        [muDict objectForKey:@"isDownload"]];
            if (res)
            {
                [db close];
                return YES;
            }
            else
            {
                [db close];
                return NO;
            }
        }
        else
        {
            return NO;
        }
    }
    else
    {
        NSLog(@"insert data");
        return [self insertData:muDict];
    }
    
    return NO;
}

//按照页码获取风景分类数据
-(NSMutableArray *) getLandscapeDataByPage:(int)currentPage
{
    int offsetNum = currentPage * LANDSCAPE_PAGE_INSIDE_NUM;
    NSString *sql = [[[[[@"select serverID,title,timestamp,description,profile_path,hasVideo from contentlist where category = " stringByAppendingFormat:@"%d", LANDSCAPE_CATEGORY] stringByAppendingString:@" order by post_date desc limit " ] stringByAppendingFormat:@"%d", LANDSCAPE_PAGE_INSIDE_NUM ] stringByAppendingString:@" Offset " ] stringByAppendingFormat:@"%d",offsetNum] ;
        
    FMDatabase* db = [FMDatabase databaseWithPath:path];
    NSMutableArray* muArray = [NSMutableArray new];
    if ([db open])
    {
        FMResultSet *rs = [db executeQuery:sql];
        NSMutableDictionary *muDict = nil;
        while ([rs next])
        {
            muDict = [NSMutableDictionary new];
            [muDict setValue:[rs stringForColumn:@"serverID"] forKey:@"serverID"];
            [muDict setValue:[rs stringForColumn:@"description"] forKey:@"description"];
            [muDict setValue:[rs stringForColumn:@"timestamp"] forKey:@"timestamp"];
            [muDict setValue:[rs stringForColumn:@"title"] forKey:@"title"];
            [muDict setValue:[rs stringForColumn:@"profile_path"] forKey:@"profile_path"];
            [muDict setValue:[NSNumber numberWithInt:[rs intForColumn:@"hasVideo"]] forKey:@"hasVideo"];
            [muArray addObject:muDict];
        }
        [db close];
        return muArray;
    }
    return nil;
}

//按照页码获取人文分类数据
-(NSMutableArray *) getHumanityDataByPage:(int)currentPage
{
    int offsetNum = currentPage * HUMANITY_PAGE_INSIDE_NUM;
    NSString *sql = [[[[[@"select serverID,title,timestamp,description,profile_path,hasVideo from contentlist where category = " stringByAppendingFormat:@"%d", HUMANITY_CATEGORY] stringByAppendingString:@" order by post_date desc limit " ] stringByAppendingFormat:@"%d", HUMANITY_PAGE_INSIDE_NUM ] stringByAppendingString:@" Offset " ] stringByAppendingFormat:@"%d",offsetNum] ;
    FMDatabase* db = [FMDatabase databaseWithPath:path];
    NSMutableArray* muArray = [NSMutableArray new];
    if ([db open])
    {
        FMResultSet *rs = [db executeQuery:sql];
        NSMutableDictionary *muDict = nil;
        while ([rs next])
        {
            muDict = [NSMutableDictionary new];
            [muDict setValue:[rs stringForColumn:@"serverID"] forKey:@"serverID"];
            [muDict setValue:[rs stringForColumn:@"description"] forKey:@"description"];
            [muDict setValue:[rs stringForColumn:@"timestamp"] forKey:@"timestamp"];
            [muDict setValue:[rs stringForColumn:@"title"] forKey:@"title"];
            [muDict setValue:[rs stringForColumn:@"profile_path"] forKey:@"profile_path"];
            [muDict setValue:[NSNumber numberWithInt:[rs intForColumn:@"hasVideo"]] forKey:@"hasVideo"];
            [muArray addObject:muDict];
        }
        [db close];
        return muArray;
    }

    return nil;
}

//按照页码获取物语分类数据
-(NSMutableArray *) getStoryDataByPage:(int)currentPage
{
    int offsetNum = currentPage * STORY_PAGE_INSIDE_NUM;
    NSString *sql = [[[[[@"select serverID,title,profile_path,hasVideo,description from contentlist where category = " stringByAppendingFormat:@"%d", STORY_CATEGORY] stringByAppendingString:@" order by post_date desc limit " ] stringByAppendingFormat:@"%d", STORY_PAGE_INSIDE_NUM ] stringByAppendingString:@" Offset " ] stringByAppendingFormat:@"%d",offsetNum] ;
    FMDatabase* db = [FMDatabase databaseWithPath:path];
    NSMutableArray* muArray = [NSMutableArray new];
    if ([db open])
    {
        FMResultSet *rs = [db executeQuery:sql];
        NSMutableDictionary *muDict = nil;
        while ([rs next])
        {
            muDict = [NSMutableDictionary new];
            [muDict setValue:[rs stringForColumn:@"serverID"] forKey:@"serverID"];
            [muDict setValue:[rs stringForColumn:@"title"] forKey:@"title"];
            [muDict setValue:[rs stringForColumn:@"description"] forKey:@"description"];
            [muDict setValue:[rs stringForColumn:@"profile_path"] forKey:@"profile_path"];
            [muDict setValue:[NSNumber numberWithInt:[rs intForColumn:@"hasVideo"]] forKey:@"hasVideo"];
            [muArray addObject:muDict];
        }
        [db close];
        return muArray;
    }

    return nil;
}

//按照页码获取社区分类数据
-(NSMutableArray *) getCommunityDataByPage:(int)currentPage
{
    int offsetNum = currentPage * COMMUNITY_INSIDE_NUM;
    NSString *sql = [[[[[@"select serverID,title,timestamp,description,profile_path,hasVideo from contentlist where category = " stringByAppendingFormat:@"%d", COMMUNITY_CATEGORY] stringByAppendingString:@" order by post_date desc  limit " ] stringByAppendingFormat:@"%d", COMMUNITY_INSIDE_NUM ] stringByAppendingString:@" Offset " ] stringByAppendingFormat:@"%d",offsetNum] ;
    FMDatabase* db = [FMDatabase databaseWithPath:path];
    NSMutableArray* muArray = [NSMutableArray new];
    if ([db open])
    {
        FMResultSet *rs = [db executeQuery:sql];
        NSMutableDictionary *muDict = nil;
        while ([rs next])
        {
            muDict = [NSMutableDictionary new];
            [muDict setValue:[rs stringForColumn:@"serverID"] forKey:@"serverID"];
            [muDict setValue:[rs stringForColumn:@"description"] forKey:@"description"];
            [muDict setValue:[rs stringForColumn:@"timestamp"] forKey:@"timestamp"];
            [muDict setValue:[rs stringForColumn:@"title"] forKey:@"title"];
            [muDict setValue:[rs stringForColumn:@"profile_path"] forKey:@"profile_path"];
            [muDict setValue:[NSNumber numberWithInt:[rs intForColumn:@"hasVideo"]] forKey:@"hasVideo"];
            [muArray addObject:muDict];
        }
        [db close];
        return muArray;
    }

    return nil;
}

//按照类别获取第一条新的数据的背景图
-(NSDictionary *) getLatestDataByCategory:(int) category
{
    NSString *sql = [[@"select max_bg_img from contentlist where category = " stringByAppendingFormat:@"%d", category ] stringByAppendingString:@" order by post_date desc limit 1"];
    FMDatabase* db = [FMDatabase databaseWithPath:path];
    if ([db open])
    {
        FMResultSet *rs = [db executeQuery:sql];
        NSMutableDictionary *muDict = nil;
        while ([rs next])
        {
            muDict = [NSMutableDictionary new];
            [muDict setValue:[rs stringForColumn:@"max_bg_img"] forKey:@"max_bg_img"];
        }
        [db close];
        return muDict;
    }

    return nil;
}

//按照类别统计所属类别的总数
-(int)countByCategory:(int)category
{
    NSString *sql = [@"select count(*) as countNum from contentlist where category = " stringByAppendingFormat:@"%d", category];
    FMDatabase* db = [FMDatabase databaseWithPath:path];
    int count = 0;
    if ([db open])
    {        
        FMResultSet *rs = [db executeQuery:sql];
        
        if ([rs next])
        {
            count = [rs intForColumn:@"countNum"];
        }
        [db close];
    }
    
    return count;
}

//写入音乐基本数据
-(BOOL) insertMusicData:(NSMutableDictionary *) nsDict
{
    FMDatabase* db = [FMDatabase databaseWithPath:path];
    
    if ([db open])
    {
        NSString *sql = @"insert into musiclist (musicID,musicName,musicAuthor,musicTitle,musicPath) values (?,?,?,?,?)";
        BOOL res = [db executeUpdate:sql,
                    [nsDict objectForKey:@"musicID"],
                    [nsDict objectForKey:@"musicName"],
                    [nsDict objectForKey:@"musicAuthor"],
                    [nsDict objectForKey:@"musicTitle"],
                    [nsDict objectForKey:@"musicPath"]
                    ];
        
        if (res)
        {
            NSLog(@"%@",@"insert music data success.......");
            [db close];
            return YES;
        }
        else
        {
            NSLog(@"%@",[db lastErrorMessage]);
            [db close];
            return NO;
        }
    }
    return NO;
}

//读取所有音乐数据
-(NSMutableArray*) queryMusicData
{
    FMDatabase* db = [FMDatabase databaseWithPath:path];
    NSMutableDictionary *nsDict= nil;
    NSMutableArray *nsMuArray = [NSMutableArray new];
    if ([db open])
    {
        NSString* sql = @"select musicID,musicName,musicAuthor,musicTitle,musicPath from musiclist ";
        FMResultSet *rs = [db executeQuery:sql];
        while ([rs next])
        {
            nsDict= [NSMutableDictionary new];
            [nsDict setValue:[rs stringForColumn:@"musicID"] forKey:@"musicID"];
            [nsDict setValue:[rs stringForColumn:@"musicName"] forKey:@"musicName"];
            [nsDict setValue:[rs stringForColumn:@"musicAuthor"] forKey:@"musicAuthor"];
            [nsDict setValue:[rs stringForColumn:@"musicTitle"] forKey:@"musicTitle"];
            [nsDict setValue:[rs stringForColumn:@"musicPath"] forKey:@"musicPath"];
            [nsMuArray addObject:nsDict];
        }
        [db close];
       
    }
     return nsMuArray;
}

//根据serverId更新下载标志
-(BOOL) updateSignByServerId:(NSString *)serverId
{
    if ([[self queryByServerID:serverId] count] > 0)
    {
        NSLog(@"update data");
        FMDatabase* db = [FMDatabase databaseWithPath:path];
        if ([db open])
        {
            NSString* sql = [[@"update contentlist set isDownload=1 where serverID ='" stringByAppendingString:serverId] stringByAppendingString:@"'"];
            BOOL res = [db executeUpdate:sql];
            if (res)
            {
                [db close];
                return YES;
            }
            else
            {
                [db close];
                return NO;
            }
        }
        else
        {
            return NO;
        }
    }
    return NO;
}

//读取需要下载视频的数据
-(NSMutableArray *)getVideoData
{
    FMDatabase* db = [FMDatabase databaseWithPath:path];
    NSMutableDictionary *nsDict = nil;
    NSMutableArray *nsMuArray = [NSMutableArray new];
    if ([db open])
    {
        NSString* sql = @"select serverID from contentlist where hasVideo = 1";
        FMResultSet *rs = [db executeQuery:sql];
        while ([rs next])
        {
            nsDict= [NSMutableDictionary new];
            [nsDict setValue:[rs stringForColumn:@"serverID"] forKey:@"serverID"];
            [nsMuArray addObject:nsDict];
        }
        [db close];
        
    }
    return nsMuArray;
}

@end
