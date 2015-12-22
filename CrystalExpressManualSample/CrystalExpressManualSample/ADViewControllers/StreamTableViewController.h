//
//  StreamTableViewController.h
//  crystalexpress
//
//  Created by roylo on 2015/3/20.
//  Copyright (c) 2015年 intowow. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StreamTableViewController : UITableViewController <UITableViewDelegate>
- (instancetype)initWithPlacementName:(NSString *)placementName;
- (instancetype)initWithAdTagName:(NSString *)tagName;
@end