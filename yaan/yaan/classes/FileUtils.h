//
//  FileUtils.h
//  JiangHomeStyle
//
//  Created by 工业设计中意（湖南） on 13-9-6.
//  Copyright (c) 2013年 cidesign. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileUtils : NSObject

//创建离线文件目录顶级，包括文章和缩略图
-(void) createAppFilesDir;

//创建指定文章的保存目录，文件夹名以severId命名
-(void) createArticleDir:(NSString*) serverId;

//创建缩略图的保存目录，文件夹名以severId命名
-(void) createThumbDir:(NSString *)serverId;

//判断文件目录是否存在
-(BOOL) fileISExist:(NSString *)fileString;

//判断文件夹目录是否存在
-(BOOL) archiveIsExist:(NSString *)dirString;

//删除指定文件夹
-(BOOL) deleteDir:(NSString *)dirString;

/**
 *  下载zip包解压到指定目录
 *
 *  @param downUrl   文件地址
 *  @param articleId 文章ID
 *  @param webView
 *  @param fileSize 文件大小
 */
-(void) downloadZipFile:(NSString *) downUrl
           andArticleId:(NSString *) articleId
            andTipsAnim:(UIWebView *) webView
            andFileSize:(long long)fileSize;

//禁止备份到icloud
- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL;

//获取指定目录下的所有文件名称
-(NSArray *)getFileListByDir:(NSString *)dir;

//删除指定目录下文件
-(void)removeAtPath:(NSString*)path;
@end
