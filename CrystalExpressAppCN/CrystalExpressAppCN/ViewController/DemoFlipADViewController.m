//
//  DemoFlipADViewController.m
//  crystalexpress
//
//  Created by roylo on 2015/3/31.
//  Copyright (c) 2015年 intowow. All rights reserved.
//

#import "DemoFlipADViewController.h"

@interface DemoFlipADViewController ()

@end

@implementation DemoFlipADViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[self view] setBackgroundColor:[UIColor blackColor]];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

#pragma mark - public method
- (void)setFlipAD:(UIView *)adView
{
    [adView setCenter:CGPointMake(self.view.bounds.size.width/2.0, self.view.bounds.size.height/2.0)];
    [[self view] addSubview:adView];
}
@end
