//
//  CECardADHelper.m
//  crystalexpress
//
//  Created by roylo on 2015/8/11.
//  Copyright (c) 2015年 intowow. All rights reserved.
//

#import "CECardADHelper.h"
#import "I2WAPI.h"

@interface CECardADHelper ()
@property (nonatomic, strong) NSString *placement;
@property (nonatomic, strong) NSString *helperKey;
@property (nonatomic, assign) int place;
@property (nonatomic, assign) BOOL isProcessing;
@end

@implementation CECardADHelper
- (instancetype)initWithPlacement:(NSString *)placement
{
    self = [super init];
    if (self) {
        _placement = placement;
        long long now = [[NSDate date] timeIntervalSince1970] * 1000L;
        _helperKey = [NSString stringWithFormat:@"%@_%lld", placement, now];
        _place = 1;
        _isProcessing = NO;
        
    }
    return self;
}

- (void)requestADonReady:(void (^)(ADView *))ready
               onFailure:(void (^)(NSError *))failure
{
    // if not specify adWidth, use SDK default value
    [self requestADWithAdWidth:-1 onReady:ready onFailure:failure];
}

- (void)requestADWithAdWidth:(CGFloat)adWidth
                     onReady:(void (^)(ADView *))ready
                   onFailure:(void (^)(NSError *))failure
{
    if (_isProcessing) {
        NSMutableDictionary* details = [NSMutableDictionary dictionary];
        [details setValue:@"Cancel request because is still processing previous request" forKey:NSLocalizedDescriptionKey];
        NSError *error = [NSError errorWithDomain:@"crystalexpress" code:1 userInfo:details];
        failure(error);
        return;
    }
    
    [I2WAPI setActivePlacement:_placement];
    [I2WAPI getStreamADWithPlacement:_placement helperKey:_helperKey place:_place adWidth:adWidth onReady:^(ADView *adView) {
        _place++;
        ready(adView);
        _isProcessing = NO;
    } onFailure:^(NSError *error) {
        failure(error);
        _isProcessing = NO;
    } onPullDownAnimation:^(UIView *view) {
        
    }];
}

@end
