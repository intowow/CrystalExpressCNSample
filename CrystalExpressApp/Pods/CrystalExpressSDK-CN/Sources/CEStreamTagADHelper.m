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

- (NSString *)getPlacement:(int)index
{
    if (index >= self.positionMgr.minPos - 1 && index < self.positionMgr.maxPos){
        return [I2WAPI getPlacementWithAdTag:_adTag posIndex:index];
    }
    return nil;
}

- (void)prerollWithVisibleCounts:(int)visibleCounts
{
    if (visibleCounts <= 0) {
        visibleCounts = DEFAULT_INIT_VISIBLE_COUNTS;
    }
    
    if (self.positionMgr.minPos <= visibleCounts) {
        for (int targetIndex = MAX(self.positionMgr.minPos - 1, 0); targetIndex <= visibleCounts - 1; targetIndex++) {
            NSString *placement = [self getPlacement:targetIndex];

            if (placement) {
                NSNumber *isProcessing = [self.isPlacementProcessing objectForKey:placement];
                if (isProcessing == nil){
                    [self.isPlacementProcessing setObject:[NSNumber numberWithBool:YES] forKey:placement];
                    self.curPlacement = placement;
                    self.lastViewedPosition = targetIndex - 1;
                    [self requestAdWithPlacement:placement];
                }
            }
        }
    }
}

- (UIView *)loadAdAtIndexPath:(NSIndexPath *)indexPath
{
    int posIndex = [self.delegate indexPathToPosition:indexPath];
    if ([self.adHolders objectForKey:@(posIndex + 1)] == nil) {
        [self checkShouldLoadAdWithPosition:posIndex + 1];
    }

    if ([self.adHolders objectForKey:@(posIndex)] != nil) {
        CEADHolder *holder = [self.adHolders objectForKey:@(posIndex)];
        return (UIView *)[holder adView];
    }
    
    return nil;
}

- (void)checkShouldLoadAdWithPosition:(int)targetInsertPosIndex
{
    BOOL validPosition = targetInsertPosIndex > self.lastViewedPosition;
    if (!validPosition) return;

    NSString *targetPlacement = [self getPlacement:targetInsertPosIndex];
    NSString *lastPlacement = self.curPlacement;
    self.curPlacement = targetPlacement;

    if (!targetPlacement) return;

    NSNumber *lastAddedPosition = [self.placementLastAddedPosition objectForKey:targetPlacement];

    BOOL needRequest = targetPlacement != lastPlacement || lastAddedPosition == nil || targetInsertPosIndex > [lastAddedPosition intValue] + self.positionMgr.servingFreq;
    if (!needRequest) return;

    //  with ongoing ad request and same placement
    NSNumber *isProcessing = [self.isPlacementProcessing objectForKey:targetPlacement];
    if (isProcessing != nil && [isProcessing boolValue]){
        return;
    }

    [self.isPlacementProcessing setObject:[NSNumber numberWithBool:YES] forKey:targetPlacement];
    // [IMPORTANT] Cannot remove dispatch_async to main thread, or tableview might appear unexpect result
    dispatch_async(dispatch_get_main_queue(), ^{
        [self requestAdWithPlacement:targetPlacement];
    });
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
    
    if (streamPlacements) {
        self.channelPlacements = streamPlacements;
    }
    
    _acceptanceRanges = nil;
    long long now = [[NSDate date] timeIntervalSince1970] * 1000L;
    // Used to distinguish ad requests from different streams
    self.key = [NSString stringWithFormat:@"%@_%lld", _adTag, now];
}

@end
