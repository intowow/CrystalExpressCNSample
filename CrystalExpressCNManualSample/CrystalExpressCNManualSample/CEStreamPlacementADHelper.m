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
    self = [super initWithDelegate:delegate];
    if (self) {
        if (placement) {
            _placement = placement;
            self.positionMgr = 
            [[CEStreamPositionManager alloc] initWithPlacement:placement
                                                        minPos:[I2WAPI getStreamADServingMinPositionWithPlacement:placement]
                                                        maxPos:[I2WAPI getStreamADServingMaxPositionWithPlacement:placement]];
            self.lastAddedPosition = self.positionMgr.minPos - self.positionMgr.servingFreq - 2;
            self.channelPlacements = @[placement];
        
            long long now = [[NSDate date] timeIntervalSince1970] * 1000L;
            // Used to distinguish ad requests from different streams
            self.key = [NSString stringWithFormat:@"%@_%lld", _placement, now];
        }
    }
    return self;
}

// override
- (void)prerollWithVisibleCounts:(int)visibleCounts
{
    if (visibleCounts <= 0) {
        visibleCounts = DEFAULT_INIT_VISIBLE_COUNTS;
    }
   
    if (self.positionMgr.minPos <= visibleCounts) {
        self.isProcessing = YES;
        [self requestAdWithPlacement:_placement];
    }
}

- (UIView *)loadAdAtIndexPath:(NSIndexPath *)indexPath
{
    int posIndex = [self.delegate indexPathToPosition:indexPath];
    if (self.isProcessing == NO) {
        [self checkShouldLoadAdWithPosition:posIndex];
    }
    
    if ([self.adHolders objectForKey:@(posIndex)] != nil) {
        CEADHolder *holder = [self.adHolders objectForKey:@(posIndex)];
        return (UIView *)[holder adView];
    }
    
    return nil;
}

- (void)checkShouldLoadAdWithPosition:(int)posIndex
{
    NSString *desirePlacement = nil;
    int targetInsertPosIndex = posIndex + 1;
    if (self.desiredPositions.count > 0 && self.desiredPositions.count <= self.adHolders.count) {
        return;
    }
    
    if ((posIndex >= self.lastAddedPosition + self.positionMgr.servingFreq)
        && (targetInsertPosIndex < self.positionMgr.maxPos)
        && (self.lastAddedPosition + self.positionMgr.servingFreq <= self.positionMgr.maxPos)) {
        desirePlacement = _placement;
        self.positionMgr.nextPos = targetInsertPosIndex;
    }
    
    // [IMPORTANT] Cannot remove dispatch_async to main thread, or tableview might appear unexpect result
    dispatch_async(dispatch_get_main_queue(), ^{
        if (desirePlacement != nil) {
            self.isProcessing = YES;
            [self requestAdWithPlacement:desirePlacement];
        }
    });
}

- (BOOL)isInAcceptanceRangesWithTargetPositionIndex:(int)posIndex
{
    return (posIndex >= self.positionMgr.minPos -1 && posIndex < self.positionMgr.maxPos);
}

- (void)reset
{
    self.positionMgr =
    [[CEStreamPositionManager alloc] initWithPlacement:_placement
                                                minPos:[I2WAPI getStreamADServingMinPositionWithPlacement:_placement]
                                                maxPos:[I2WAPI getStreamADServingMaxPositionWithPlacement:_placement]];
    self.lastAddedPosition = self.positionMgr.minPos - self.positionMgr.servingFreq - 2;
    self.channelPlacements = @[_placement];
    
    long long now = [[NSDate date] timeIntervalSince1970] * 1000L;
    // Used to distinguish ad requests from different streams
    self.key = [NSString stringWithFormat:@"%@_%lld", _placement, now];
}

@end
