//
//  DemoContentViewController.h
//  crystalexpress
//
//  Created by roylo on 2015/3/27.
//  Copyright (c) 2015年 intowow. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ContentADHelper;
@interface DemoContentViewController : UIViewController

-(instancetype)initWithADHelper:(ContentADHelper *)helper;
- (void)loadContentWithId:(NSString *)articleId;
- (void)onPullDownAnimationWithAD:(UIView *)adView;
@end
