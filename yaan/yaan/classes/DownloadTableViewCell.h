//
//  DownloadTableViewCell.h
//  NewTD
//
//  Created by 工业设计中意（湖南） on 14-5-12.
//  Copyright (c) 2014年 中意工业设计（湖南）有限责任公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DownloadTableViewCell : UITableViewCell
{
    IBOutlet UILabel *downLoadName;
    IBOutlet UILabel *downloadResult;
    IBOutlet UILabel *downProgress;
}

@property (strong, nonatomic) IBOutlet UILabel *downLoadName;
@property (strong, nonatomic) IBOutlet UILabel *downloadResult;
@property (strong, nonatomic) IBOutlet UILabel *downProgress;
@end
