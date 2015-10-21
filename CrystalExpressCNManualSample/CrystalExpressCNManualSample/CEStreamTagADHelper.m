//
//  CEStreamTagADHelper.m
//  crystalexpress
//
//  Created by roylo on 2015/10/15.
//  Copyright © 2015年 intowow. All rights reserved.
//

#import "CEStreamTagADHelper.h"
#import "I2WAPI.h"

@interface CEStreamTagADHelper ()
@property (nonatomic, strong) NSString *adTag;
@property (nonatomic, strong) NSString *curPlacement;
@property (nonatomic, strong) NSArray *acceptanceRanges;
@end

@implementation CEStreamTagADHelper
- (instancetype)initWithAdTag:(NSString *)adTag delegate:(id<CEStreamAdHelperDelegate>)delegate
{
    self = [super initWithDelegate:delegate];
    if (self) {
        if (adTag) {
            _adTag = adTag;
            
            NSDictionary *streamPlacementsInfo = [I2WAPI getStreamPlacementsInfoWithTagName:adTag];
            int minPos = ([streamPlacementsInfo objectForKey:@"minPos"] == nil) ? -1 : [[streamPlacementsInfo objectForKey:@"minPos"] intValue];
            int maxPos = ([streamPlacementsInfo objectForKey:@"maxPos"] == nil) ? -1 : [[streamPlacementsInfo objectForKey:@"maxPos"] intValue];
            NSArray *streamPlacements = [streamPlacementsInfo objectForKey:@"placements"];
            
            self.positionMgr =
            [[CEStreamPositionManager alloc] initWithTag:adTag
                                                  minPos:minPos
                                                  maxPos:maxPos];
            self.lastAddedPosition = self.positionMgr.minPos - self.positionMgr.servingFreq - 2;
            
            if (streamPlacements) {
                self.channelPlacements = streamPlacements;
            }
            
            _acceptanceRanges = nil;
            
            long long now = [[NSDate date] timeIntervalSince1970] * 1000L;
            // Used to distinguish ad requests from different streams
            self.key = [NSString stringWithFormat:@"%@_%lld", _adTag, now];
        }
    }
    return self;
}

- (void)prerollWithVisibleCounts:(int)visibleCounts
{
    if (visibleCounts <= 0) {
        visibleCounts = DEFAULT_INIT_VISIBLE_COUNTS;
    }
    
    if (self.positionMgr.minPos <= visibleCounts) {
        NSString *placement = [I2WAPI getPlacementWithAdTag:_adTag posIndex:self.positionMgr.minPos -1];
        if (placement) {
            _curPlacement = placement;
            NSDictionary *streamServingDict = [I2WAPI getPositionLimitationWithTagName:_adTag placement:placement];
            _acceptanceRanges = [streamServingDict objectForKey:@"acceptanceRanges"];
            
            self.isProcessing = YES;
            [self requestAdWithPlacement:placement];
        }
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
    
    if (targetInsertPosIndex < self.positionMgr.minPos -1
        || targetInsertPosIndex <= self.lastAddedPosition
        || targetInsertPosIndex > self.positionMgr.maxPos) {
        return;
    }
    
    BOOL needRequestAd = NO;
    NSString *newAdTagPlacement = [I2WAPI getPlacementWithAdTag:_adTag posIndex:targetInsertPosIndex];
    
    if (newAdTagPlacement) {
        BOOL isPlacementBlocking = [I2WAPI isPlacementBlocking:newAdTagPlacement];
        if (isPlacementBlocking == YES || _curPlacement != newAdTagPlacement) {
            needRequestAd = YES;
            self.positionMgr.nextPos = targetInsertPosIndex;
        } else if (targetInsertPosIndex > self.lastAddedPosition + self.positionMgr.servingFreq) {
            needRequestAd = YES;
            self.positionMgr.nextPos = targetInsertPosIndex;
        } else {
            return;
        }
        
        if (_curPlacement != newAdTagPlacement) {
            NSDictionary *streamServingDict = [I2WAPI getPositionLimitationWithTagName:_adTag placement:newAdTagPlacement];
            _acceptanceRanges = [streamServingDict objectForKey:@"acceptanceRanges"];
            _curPlacement = newAdTagPlacement;
        }
        
    }
    
    if (needRequestAd) {
        desirePlacement = newAdTagPlacement;
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
    for (NSArray *range in _acceptanceRanges) {
        int minPos = [[range firstObject] intValue];
        int maxPos = [[range lastObject] intValue];
        if (posIndex >= minPos -1 && posIndex < maxPos) {
            return YES;
        }
    }
    
    return NO;
}

- (void)reset
{
    [super reset];
    NSDictionary *streamPlacementsInfo = [I2WAPI getStreamPlacementsInfoWithTagName:_adTag];
    int minPos = ([streamPlacementsInfo objectForKey:@"minPos"] == nil) ? -1 : [[streamPlacementsInfo objectForKey:@"minPos"] intValue];
    int maxPos = ([streamPlacementsInfo objectForKey:@"maxPos"] == nil) ? -1 : [[streamPlacementsInfo objectForKey:@"maxPos"] intValue];
    NSArray *streamPlacements = [streamPlacementsInfo objectForKey:@"placements"];
    
    self.positionMgr =
    [[CEStreamPositionManager alloc] initWithTag:_adTag
                                          minPos:minPos
                                          maxPos:maxPos];
    self.lastAddedPosition = self.positionMgr.minPos - self.positionMgr.servingFreq - 2;
    
    if (streamPlacements) {
        self.channelPlacements = streamPlacements;
    }
    
    _acceptanceRanges = nil;
    long long now = [[NSDate date] timeIntervalSince1970] * 1000L;
    // Used to distinguish ad requests from different streams
    self.key = [NSString stringWithFormat:@"%@_%lld", _adTag, now];
}

@end
