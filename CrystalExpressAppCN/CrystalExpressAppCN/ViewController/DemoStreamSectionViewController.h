//
//  DemoStreamSectionViewController.h
//  crystalexpress
//
//  Created by roylo on 2015/3/26.
//  Copyright (c) 2015年 intowow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DemoSectionMenuScrollView.h"

@protocol DemoStreamSectionViewControllderDelegate <NSObject>
- (void)requestInterstitialSplashAD;
@end

@interface DemoStreamSectionViewController : UIViewController <DemoSectionMenuDelegate, DemoStreamSectionViewControllderDelegate>

@end
