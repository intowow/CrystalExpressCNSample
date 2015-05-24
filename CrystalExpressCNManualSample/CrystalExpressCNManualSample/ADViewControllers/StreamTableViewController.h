//
//  StreamTableViewController.h
//  crystalexpress
//
//  Created by roylo on 2015/3/20.
//  Copyright (c) 2015年 intowow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StreamADHelper.h"

@interface StreamTableViewController : UITableViewController <UITableViewDelegate, StreamADHelperDelegate>
- (instancetype)initWithPlacementName:(NSString *)placementName;
@end