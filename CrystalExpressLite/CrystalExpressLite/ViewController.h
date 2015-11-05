//
//  ViewController.h
//  crystalexpress-lite
//
//  Created by roylo on 2015/10/20.
//  Copyright © 2015年 intowow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CEMediaView.h"

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIView *adUIView;
@property (weak, nonatomic) IBOutlet CEMediaView *adMediaCoverView;
@property (weak, nonatomic) IBOutlet UIImageView *adIconImageView;
@property (weak, nonatomic) IBOutlet UILabel *adTitle;
@property (weak, nonatomic) IBOutlet UILabel *adBody;
@property (weak, nonatomic) IBOutlet UIButton *callToActionBtn;
@property (weak, nonatomic) IBOutlet UIView *callToActionWrapper;
@property (weak, nonatomic) IBOutlet UILabel *eventLog;

- (IBAction)loadNativeAd:(id)sender;
@end

