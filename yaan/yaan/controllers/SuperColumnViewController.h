//
//  SuperColumnViewController.h
//  NewTD
//
//  Created by 工业设计中意（湖南） on 14-5-12.
//  Copyright (c) 2014年 中意工业设计（湖南）有限责任公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PopupDetailViewController.h"

@class GAITrackedViewController;

@interface SuperColumnViewController : GAITrackedViewController<MJPopupDelegate>
{
    /**
     *  应用启动后，缩略图 图片下载 队列，同一时刻有2个thread来执行任务
     */
    NSOperationQueue *thumbDownQueue;
    
    int animationBeginYValue;
}

/**
 *  异步加载ScrollView页面中的缩略图
 *
 *  @param muDict 文件路径（网络／本地
 *  @param uiImg  需要加载的UIImageView控件
 *
 *  @return NSOperation Queue
 */
-(NSOperation *) loadingImageOperation:(NSMutableDictionary*) muDict andImageView:(UIImageView*) uiImg;

/**
 *  给指定的UIView对象加载该篇文章是否有视频的标示
 *
 *  @param view UIView对象
 */
-(void) addVideoImage:(UIView *)view;

/**
 *  ScrollView中文章点击查看详情事件
 *
 *  @param sender <#sender description#>
 */
- (void)panelClick:(id)sender;

/**
 *  关闭详情界面事件
 */
- (void) closeButtonClicked;

/**
 *  接收动画事件
 *
 *  @param pointY ScrollView  Y value
 */
- (void)rootscrollViewDidScrollToPointY:(int)pointY;
@end
