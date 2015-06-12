//
//  DemoStreamTableViewController.h
//  crystalexpress
//
//  Created by roylo on 2015/3/26.
//  Copyright (c) 2015年 intowow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StreamADHelper.h"
#import "DemoStreamSectionViewController.h"

@interface DemoStreamTableViewController : UITableViewController <StreamADHelperDelegate>
@property (nonatomic, strong) NSString *sectionName;
@property (nonatomic, strong) StreamADHelper *streamHelper;
@property (nonatomic, weak) id<DemoStreamSectionViewControllderDelegate> delegate;
@end
