//
//  BannerADHelper.m
//  Pods
//
//  Created by roylo on 2014/10/31.
//
//

#import "CEBannerADHelper.h"
#import "CEADView.h"
#import "I2WAPI.h"

#define RETRY_CNT 5

@interface CEBannerADHelper()
@property (nonatomic, strong) NSString *placement;
@property (nonatomic, assign) BOOL isProcessing;
@property (nonatomic, strong) ADView *currentBannerAD;
@property (nonatomic, assign) int retryCount;

@end

@implementation CEBannerADHelper
- (instancetype)initWithPlacement:(NSString *)placement
{
    self = [super init];
    if (self) {
        _placement = placement;
        _isProcessing = NO;
        _currentBannerAD = nil;
        _retryCount = 0;
    }
    
    return self;
}

- (void)requestADonReady:(void (^)(UIView *))ready onFailure:(void (^)(NSError *))failure
{
    if (_isProcessing) {
        return;
    }
    
    _isProcessing = YES;
    [I2WAPI getBannerADWithPlacement:_placement onReady:^(ADView *adView) {
        _currentBannerAD = adView;
        _isProcessing = NO;
        _retryCount = 0;
        ready(adView);
    } onFailure:^(NSError *error) {
        _currentBannerAD = nil;
        _isProcessing = NO;
        _retryCount++;
        failure(error);
        if (_retryCount < RETRY_CNT) {
            [self requestADonReady:ready onFailure:failure];
        } else {
            NSLog(@"failed to load bannerAD");
        }
    }];
}

- (void)onStop
{
    if (_currentBannerAD) {
        [_currentBannerAD onStop];
    }
    _retryCount = 0;
}

- (void)onStart
{
    if (_currentBannerAD) {
        [_currentBannerAD onStart];
    }
}
@end
