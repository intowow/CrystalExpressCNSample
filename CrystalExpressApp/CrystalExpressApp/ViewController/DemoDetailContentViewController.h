//
//  DemoDetailContentViewController.h
//  crystalexpress
//
//  Created by roylo on 2015/3/28.
//  Copyright (c) 2015年 intowow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DemoStreamSectionViewController.h"

@interface DemoDetailContentViewController : UIViewController
@property (nonatomic, weak) id<DemoStreamSectionViewControllderDelegate> delegate;

- (instancetype)initWithIndex:(NSUInteger)index;
@end
