//
//  ViewController.m
//  crystalexpress-lite
//
//  Created by roylo on 2015/10/20.
//  Copyright © 2015年 intowow. All rights reserved.
//

#import "ViewController.h"
#import "CENativeAd.h"

@interface ViewController () <CENativeAdDelegate>
@property (nonatomic, strong) CENativeAd *nativeAd;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _adUIView.layer.cornerRadius = 5.0f;

    _callToActionWrapper.layer.borderColor = [UIColor whiteColor].CGColor;
    _callToActionWrapper.layer.borderWidth = 1.0f;
    _callToActionWrapper.backgroundColor = [UIColor clearColor];
    
    [_callToActionBtn.titleLabel setFont:[UIFont systemFontOfSize:9]];
    
    [_adTitle setFont:[UIFont systemFontOfSize:13]];

    [_adBody setFont:[UIFont systemFontOfSize:11]];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (_adMediaCoverView) {
        [_adMediaCoverView play];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    if (_adMediaCoverView) {
        [_adMediaCoverView stop];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)loadNativeAd:(id)sender {
    CENativeAd *nativeAd = [[CENativeAd alloc] initWithPlacement:@"NATIVE_AD"];
    nativeAd.delegate = self;
    
    [nativeAd loadAd];
}

- (IBAction)startNativeAd:(id)sender {
    if (self.adMediaCoverView) {
        [self.adMediaCoverView play];
    }
}

- (IBAction)stopNativeAd:(id)sender {
    if (self.adMediaCoverView) {
        [self.adMediaCoverView stop];
    }
}

#pragma mark - CENativeAdDelegate
- (void)nativeAdDidLoad:(CENativeAd *)nativeAd
{
    NSString *log = @"Native ad was loaded\n";
    _eventLog.text = log;
    NSLog(@"%@", log);
    
    _nativeAd = nativeAd;
    
    __weak typeof(self) weakSelf = self;
    [self.nativeAd.icon loadImageAsyncWithBlock:^(UIImage *image) {
        __strong typeof(self) strongSelf = weakSelf;
        strongSelf.adIconImageView.image = image;
    }];

    [self.adMediaCoverView setNativeAd:nativeAd];
    self.adTitle.text = nativeAd.title;
    self.adBody.text = nativeAd.body;
    [self.callToActionBtn setTitle:nativeAd.callToAction forState:UIControlStateNormal];
    
//    [nativeAd registerViewForInteraction:self.adUIView
//                      withViewController:self];
    
//    You can replace to use the following method to specify the clicable area
//    
    NSArray *clickableViews = @[
                                self.callToActionBtn,
                                self.adBody,
                                ];
    [nativeAd registerViewForInteraction:self.adUIView
                      withViewController:self
                      withClickableViews:clickableViews];

}

- (void)nativeAd:(CENativeAd *)nativeAd didFailWithError:(NSError *)error
{
    NSString *log = [NSString stringWithFormat:@"load native ad fail: %@", error];
    _eventLog.text = log;
    NSLog(@"%@", log);
}

- (void)nativeAdDidClick:(CENativeAd *)nativeAd
{
    NSString *log = @"Native ad was clicked.\n";
    _eventLog.text = [_eventLog.text stringByAppendingString:log];
    NSLog(@"%@", log);
}

- (void)nativeAdDidFinishHandlingClick:(CENativeAd *)nativeAd
{
    NSString *log = @"Native ad did finish click handling.\n";
    _eventLog.text = [_eventLog.text stringByAppendingString:log];
    [self.adMediaCoverView mute];
    NSLog(@"%@", log);
}

- (void)nativeAdWillTrackImpression:(CENativeAd *)nativeAd
{
    NSString *log = @"Native ad impression is being captured.\n";
    _eventLog.text = [_eventLog.text stringByAppendingString:log];
    NSLog(@"%@", log);
}

@end
