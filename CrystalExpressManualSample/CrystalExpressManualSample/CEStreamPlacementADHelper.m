//
//  CEStreamPlacementADHelper.m
//  crystalexpress
//
//  Created by roylo on 2015/10/15.
//  Copyright © 2015年 intowow. All rights reserved.
//

#import "CEStreamPlacementADHelper.h"
#import "I2WAPI.h"

@interface CEStreamPlacementADHelper ()
@property (nonatomic, strong) NSString *placement;
@end

@implementation CEStreamPlacementADHelper

- (instancetype)initWithPlacement:(NSString *)placement delegate:(id<CEStreamAdHelperDelegate>)delegate
{
    self = [super initWithAdTag:@"" delegate:delegate];
    if (self) {
        if (placement) {
            _placement = placement;
            self.positionMgr =
            [[CEStreamPositionManager alloc] initWithPlacement:placement
                                                        minPos:[I2WAPI getStreamADServingMinPositionWithPlacement:placement]
                                                        maxPos:[I2WAPI getStreamADServingMaxPositionWithPlacement:placement]];
            self.channelPlacements = @[placement];

            long long now = [[NSDate date] timeIntervalSince1970] * 1000L;
            // Used to distinguish ad requests from different streams
            self.key = [NSString stringWithFormat:@"%@_%lld", _placement, now];
        }
    }
    return self;
}

//overwrite
- (NSString *)getPlacement:(int)index
{
    if (index >= self.positionMgr.minPos - 1 && index < self.positionMgr.maxPos){
        return _placement;
    }
    return nil;
}

- (void)reset
{
    self.positionMgr =
    [[CEStreamPositionManager alloc] initWithPlacement:_placement
                                                minPos:[I2WAPI getStreamADServingMinPositionWithPlacement:_placement]
                                                maxPos:[I2WAPI getStreamADServingMaxPositionWithPlacement:_placement]];
    self.channelPlacements = @[_placement];

    long long now = [[NSDate date] timeIntervalSince1970] * 1000L;
    // Used to distinguish ad requests from different streams
    self.key = [NSString stringWithFormat:@"%@_%lld", _placement, now];
}

@end
