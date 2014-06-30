//
//  PopupDetailViewController.h
//  NewTD
//
//  Created by 工业设计中意（湖南） on 14-5-12.
//  Copyright (c) 2014年 中意工业设计（湖南）有限责任公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "../libs/googleAnalytics/GAI.h"

@protocol MJPopupDelegate;

@interface PopupDetailViewController : GAITrackedViewController
{
    NSString *serverID;
  
    NSString *showUrl;
    NSString *videoUrl;
    NSMutableDictionary *urlDict;
    NSMutableArray *videoArray;
    
    IBOutlet UIWebView *webView;
    IBOutlet UIButton *backBtn;
    IBOutlet UILabel *downloadPercentlabel;
    IBOutlet UIProgressView *downloadProgress;
}
@property (weak, nonatomic) id<MJPopupDelegate> delegate;
@property (strong,nonatomic) NSString *serverID;
@property (strong,nonatomic) IBOutlet UIWebView *webView;
@property (strong,nonatomic) IBOutlet UIButton *backBtn;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andParams:(NSString *)_serverID;

@end

@protocol MJPopupDelegate <NSObject>

@optional
- (void)closeButtonClicked;

@end