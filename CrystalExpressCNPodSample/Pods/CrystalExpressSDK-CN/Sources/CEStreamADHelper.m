//
//  CEStreamADHelper.m
//  Pods
//
//  Created by roylo on 2015/7/16.
//
//

#import "CEStreamADHelper.h"
#import "I2WAPI.h"
#import "CEADView.h"

#define DEFAULT_INIT_VISIBLE_COUNTS 4

#pragma mark - ADHolder
@interface CEADHolder : NSObject
@property (nonatomic, strong) ADView *adView;
@property (nonatomic, assign) BOOL isShowing;
@property (nonatomic, assign) BOOL isPlaying;
@property (nonatomic, assign) NSUInteger section;
@property (nonatomic, assign) NSUInteger row;

- (instancetype)initWithAdView:(ADView *)adView section:(NSUInteger)section row:(NSUInteger)row;
@end

@implementation CEADHolder

- (instancetype)initWithAdView:(ADView *)adView section:(NSUInteger)section row:(NSUInteger)row
{
    self = [super init];
    if (self) {
        _adView = adView;
        _isShowing = NO;
        _isPlaying = NO;
        _section = section;
        _row = row;
    }
    return self;
}

@end

@interface CEStreamADHelper()
@property (nonatomic, strong) NSMutableDictionary *sectionCounts;
@property (nonatomic, strong) NSMutableDictionary *adHolders;
@property (nonatomic, strong) NSString *placement;
@property (nonatomic, strong) NSString *key;
@property (nonatomic, assign) int place;
@property (nonatomic, assign) float adWidth;
@property (nonatomic, strong) NSMutableArray *prohibitPositions;
@property (nonatomic, strong) NSMutableArray *desiredPositions;

// serving conf
@property (nonatomic, assign) int servingFreq;
@property (nonatomic, assign) int servingMinPos;
@property (nonatomic, assign) int servingMaxPos;
@property (nonatomic, assign) int lastAddedPosition;
@property (nonatomic, assign) int firstVisiblePosition;
@property (nonatomic, assign) int lastVisiblePosition;

// state
@property (nonatomic, assign) BOOL isProcessing;
@property (nonatomic, assign) BOOL isActive;
@property (nonatomic, assign) BOOL enableAutoPlay;
@end

@implementation CEStreamADHelper
- (instancetype)initWithPlacement:(NSString *)placement delegate:(id<CEStreamAdHelperDelegate>)delegate
{
    self = [super init];
    if (self) {
        _sectionCounts = [[NSMutableDictionary alloc] init];
        _adHolders = [[NSMutableDictionary alloc] init];
        _placement = placement;
        _delegate = delegate;
        long long now = [[NSDate date] timeIntervalSince1970] * 1000L;
        // Used to distinguish ad requests from different streams
        _key            = [NSString stringWithFormat:@"%@_%lld", _placement, now];
        _place = 1;
        _adWidth = -1;
        
        _servingFreq    = [I2WAPI getStreamADServingFreqWithPlacement:placement];
        _servingMinPos  = [I2WAPI getStreamADServingMinPositionWithPlacement:placement];
        _servingMaxPos  = [I2WAPI getStreamADServingMaxPositionWithPlacement:placement];
        _lastAddedPosition = _servingMinPos - _servingFreq - 2;
        _firstVisiblePosition = -1;
        _lastVisiblePosition = -1;
        
        // state
        _isProcessing = NO;
        _isActive = NO;
        _enableAutoPlay = YES;
        
        _prohibitPositions = [[NSMutableArray alloc] init];
        _desiredPositions = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)setAdWidth:(float)width
{
    if (width > 0) {
        _adWidth = width;
    }
}

- (void)setActive:(BOOL)isActive
{
    _isActive = isActive;
    if (isActive) {
        [I2WAPI setActivePlacement:_placement];
    }
    
    [self updateAdStatus];
}

- (void)setItemCount:(NSUInteger)count forSection:(NSInteger)section
{
    self.sectionCounts[@(section)] = @(count);
}

- (NSUInteger)adjustedNumberOfItems:(NSUInteger)numberOfItems inSection:(NSUInteger)section
{
    if (numberOfItems <= 0) return 0;
    
    NSIndexPath *pathOfLastItem = [NSIndexPath indexPathForRow:numberOfItems inSection:section];
    NSUInteger numberOfAdsBeforeLastItem = [self findAdCountInSameSectionBeforeOriginIndexPath:pathOfLastItem];
    
    return numberOfItems + numberOfAdsBeforeLastItem;
}

- (void)prerollWithVisibleCounts:(int)visibleCounts
{
    if (visibleCounts <= 0) {
        visibleCounts = DEFAULT_INIT_VISIBLE_COUNTS;
    }
    
    if (_servingMinPos <= visibleCounts) {
        _isProcessing = YES;
        [self requestAd];
    }
}

- (void)reset
{
    // clean all previous ads
    _place          = 1;
    _isProcessing   = NO;
    
    for (NSNumber *posNum in _adHolders) {
        CEADHolder *holder = [_adHolders objectForKey:posNum];
        [[holder adView] removeFromSuperview];
        [[holder adView] onHide];
        [[holder adView] onStop];
    }
    
    _adHolders      = [[NSMutableDictionary alloc] init];
    
    // A trick so we can pass the initial condition and insert ad at the minimum position!
    _lastAddedPosition      = _servingMinPos - _servingFreq - 2;
    _firstVisiblePosition   = -1;
    _lastVisiblePosition    = -1;
    
    [_prohibitPositions removeAllObjects];
    [_desiredPositions removeAllObjects];
}

- (void)setAppAdsIndexPaths:(NSArray *)appAdsIndexPaths
{
    [_prohibitPositions removeAllObjects];
    NSArray *adjustedIndexPaths = [self adjustedIndexPathsForOriginalIndexPaths:appAdsIndexPaths];
    for (NSIndexPath *adjustedIndexPath in adjustedIndexPaths) {
        int adjustedPos = [_delegate indexPathToPosition:adjustedIndexPath];
        
        if ([_prohibitPositions containsObject:@(adjustedPos)] == NO) {
            [_prohibitPositions addObject:@(adjustedPos)];
        }
        if ([_prohibitPositions containsObject:@(adjustedPos+1)] == NO) {
            [_prohibitPositions addObject:@(adjustedPos+1)];
        }
    }
}

- (void)setAdCustomIndexPaths:(NSArray *)adIndexPaths
{
    [_desiredPositions removeAllObjects];
    adIndexPaths = [adIndexPaths sortedArrayUsingSelector:@selector(compare:)];
    NSArray *adjustedIndexPaths = [self adjustedIndexPathsForOriginalIndexPaths:adIndexPaths];
    for (NSIndexPath *adjustedIndexPath in adjustedIndexPaths) {
        int adjustedPos = [_delegate indexPathToPosition:adjustedIndexPath];
        if ([_desiredPositions containsObject:@(adjustedPos)] == NO) {
            [_desiredPositions addObject:@(adjustedPos)];
        }
    }
}

- (void)setAutoPlay:(BOOL)enableAutoPlay
{
    _enableAutoPlay = enableAutoPlay;
}

- (void)startAdAtPosition:(NSUInteger)position
{
    if ([_adHolders objectForKey:@(position)]) {
        CEADHolder *holder = [_adHolders objectForKey:@(position)];
        [holder.adView onStart];
        holder.isPlaying = YES;
    }
}

- (void)stopAdAtPosition:(NSUInteger)position
{
    if ([_adHolders objectForKey:@(position)]) {
        CEADHolder *holder = [_adHolders objectForKey:@(position)];
        [holder.adView onStop];
        holder.isPlaying = NO;
    }
    
}

- (UIView *)loadAdAtIndexPath:(NSIndexPath *)indexPath
{
    int position = [_delegate indexPathToPosition:indexPath];
    if ([_adHolders objectForKey:@(position)] != nil) {
        CEADHolder *holder = [_adHolders objectForKey:@(position)];
        return (UIView *)[holder adView];
    }
    
    
    if (!_isProcessing &&
        (position >= _lastAddedPosition + _servingFreq) &&
        (position <= _servingMaxPos) &&
        (_lastAddedPosition + _servingFreq <= _servingMaxPos)) {
        
        _isProcessing = YES;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            [self requestAd];
        });
    }
    
    return nil;
}

- (BOOL)isAdAtIndexPath:(NSIndexPath *)indexPath
{
    int pos = [_delegate indexPathToPosition:indexPath];
    return [_adHolders objectForKey:@(pos)] != nil;
}

- (CGSize)getAdSizeAtIndexPath:(NSIndexPath *)indexPath
{
    if (![self isAdAtIndexPath:indexPath]) {
        return CGSizeZero;
    }
    
    int pos = [_delegate indexPathToPosition:indexPath];
    CEADHolder *holder = [_adHolders objectForKey:@(pos)];
    return [holder adView].bounds.size;
}

- (NSIndexPath *)originalIndexPathForAdjustedIndexPath:(NSIndexPath *)indexPath
{
    if (!indexPath || indexPath.row == NSNotFound) {
        return indexPath;
    } else if ([self isAdAtIndexPath:indexPath]) {
        return nil;
    } else {
        NSUInteger numberOfAdsBeforeIndexPath = [self findAdCountInSameSectionBeforeAdjustedIndexPath:indexPath];
        return [NSIndexPath indexPathForRow:indexPath.row - numberOfAdsBeforeIndexPath inSection:indexPath.section];
    }
}

- (NSIndexPath *)adjustedIndexPathForOriginalIndexPath:(NSIndexPath *)indexPath
{
    if (!indexPath || indexPath.row == NSNotFound) {
        return indexPath;
    }
    
    NSUInteger numberOfAdsBeforeIndexPath = [self findAdCountInSameSectionBeforeOriginIndexPath:indexPath];
    return [NSIndexPath indexPathForRow:indexPath.row + numberOfAdsBeforeIndexPath inSection:indexPath.section];
}

- (NSArray *)originalIndexPathsForAdjustedIndexPaths:(NSArray *)indexPaths
{
    NSMutableArray *originalIndexPaths = [NSMutableArray array];
    for (NSIndexPath *indexPath in indexPaths) {
        NSIndexPath *originalIndexPath = [self originalIndexPathForAdjustedIndexPath:indexPath];
        if (originalIndexPath) {
            [originalIndexPaths addObject:originalIndexPath];
        }
    }
    return [originalIndexPaths copy];
}

- (NSArray *)adjustedIndexPathsForOriginalIndexPaths:(NSArray *)indexPaths
{
    NSMutableArray *adjustedIndexPaths = [NSMutableArray array];
    for (NSIndexPath *indexPath in indexPaths) {
        [adjustedIndexPaths addObject:[self adjustedIndexPathForOriginalIndexPath:indexPath]];
    }
    return [adjustedIndexPaths copy];
}

- (void)insertItemsAtIndexPaths:(NSArray *)originalIndexPaths
{
    originalIndexPaths = [originalIndexPaths sortedArrayUsingSelector:@selector(compare:)];
    for (NSIndexPath *oriIndexPath in originalIndexPaths) {
        NSIndexPath *adjustedIndexPath = [self adjustedIndexPathForOriginalIndexPath:oriIndexPath];
        NSArray *keys = [_adHolders allKeys];
        for (NSNumber *adPos in keys) {
            CEADHolder *holder = [_adHolders objectForKey:adPos];
            if (holder.section != adjustedIndexPath.section) {
                continue;
            }
            
            if (holder.row >= adjustedIndexPath.row) {
                int newPos = [adPos intValue] + 1;
                [_adHolders removeObjectForKey:adPos];
                [_adHolders setObject:holder forKey:@(newPos)];
            }
        }
    }
}

- (void)deleteItemsAtIndexPaths:(NSArray *)originalIndexPaths
{
    originalIndexPaths = [originalIndexPaths sortedArrayUsingSelector:@selector(compare:)];
    for (NSIndexPath *oriIndexPath in originalIndexPaths) {
        NSIndexPath *adjustedIndexPath = [self adjustedIndexPathForOriginalIndexPath:oriIndexPath];
        if ([self isAdAtIndexPath:adjustedIndexPath]) {
            [_adHolders removeObjectForKey:adjustedIndexPath];
        }
    }
}

- (void)moveItemAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    
}

- (void)insertSections:(NSIndexSet *)sections
{
    [sections enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        NSArray *keys = [_adHolders allKeys];
        for (NSNumber *adPos in keys) {
            CEADHolder *holder = [_adHolders objectForKey:adPos];
            if (holder.section >= idx) {
                holder.section ++;
            }
        }
    }];
}

- (void)deleteSections:(NSIndexSet *)sections
{
    [sections enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        NSArray *keys = [_adHolders allKeys];
        for (NSNumber *adPos in keys) {
            CEADHolder *holder = [_adHolders objectForKey:adPos];
            if (holder.section == idx) {
                [_adHolders removeObjectForKey:adPos];
            }
        }
    }];
}

- (void)moveSection:(NSInteger)section toSection:(NSInteger)newSection
{
    NSArray *keys = [_adHolders allKeys];
    for (NSNumber *adPos in keys) {
        CEADHolder *holder = [_adHolders objectForKey:adPos];
        if (holder.section == section) {
            NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:holder.row inSection:newSection];
            holder.section = newSection;
            [_adHolders removeObjectForKey:adPos];
            int newPos = [_delegate indexPathToPosition:newIndexPath];
            [_adHolders setObject:holder forKey:@(newPos)];
        }
    }
}

- (void)updateVisibleCellsFromPosition:(int)firstPos toPosition:(int)lastPos
{
    _firstVisiblePosition = firstPos;
    _lastVisiblePosition = lastPos;
    
    // for ad status onShow/onHide event
    [self updateAdStatus];
}

#pragma mark - private method
- (void)requestAd
{
    [I2WAPI getStreamADWithPlacement:_placement
                           helperKey:_key
                               place:_place
                             adWidth:_adWidth
                             timeout:5.0
                             onReady:^(ADView *adView) {
        [self onADLoaded:adView];
        _isProcessing = NO;
    } onFailure:^(NSError *error) {
        _isProcessing = NO;
    } onPullDownAnimation:^(UIView *adView) {
        [_delegate CEStreamADOnPulldownAnimation];
    }];
}

- (void)updateProhibitPosWithAdPos:(int)adPos
{
    NSMutableArray *newProhitbitPos = [[NSMutableArray alloc] init];
    for (NSNumber *prohibitPos in _prohibitPositions) {
        if ([prohibitPos intValue] >= adPos) {
            [newProhitbitPos addObject:@([prohibitPos intValue]+1)];
        } else {
            [newProhitbitPos addObject:prohibitPos];
        }
    }
    
    _prohibitPositions = newProhitbitPos;
}

#pragma mark - indexPath helper
- (NSUInteger)findAdCountInSameSectionBeforeAdjustedIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger count = 0;
    for (NSNumber *adPos in [_adHolders allKeys]) {
        CEADHolder *holder = [_adHolders objectForKey:adPos];
        if (holder.section != indexPath.section) {
            continue;
        }
        
        if (holder.row <= indexPath.row) {
            count++;
        }
    }
    return count;
}

- (NSUInteger)findAdCountInSameSectionBeforeOriginIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger count = 0;
    NSUInteger oriRow = indexPath.row;
    
    NSArray *keys = [_adHolders allKeys];
    keys = [keys sortedArrayUsingSelector:@selector(compare:)];
    for (NSNumber *adPos in keys) {
        CEADHolder *holder = [_adHolders objectForKey:adPos];
        if (holder.section != indexPath.section) {
            continue;
        }
        
        if (holder.row <= oriRow) {
            oriRow++;
            count++;
        }
    }
    
    return count;
}

- (void)onADLoaded:(ADView *)adView
{
    int targetPosition = MAX(_lastVisiblePosition + 1, _lastAddedPosition + _servingFreq + 1);
    if ([_desiredPositions count] == 0) {
        while ([_prohibitPositions containsObject:@(targetPosition)]) {
            targetPosition ++;
        }
    } else {
        targetPosition = -1;
        NSArray *curDesiredPositions = [_desiredPositions copy];
        for (NSNumber *desiredPos in curDesiredPositions) {
            // this position already has ad
            if ([_adHolders objectForKey:desiredPos] != nil) {
                continue;
            }
            
            if ([desiredPos intValue] >= _lastVisiblePosition + 1) {
                targetPosition = [desiredPos intValue];
                break;
            }
        }
    }
    
    if (targetPosition < _servingMaxPos) {
        if (targetPosition != -1 && adView != nil) {
            NSIndexPath *targetIndexPath = [_delegate positionToIndexPath:targetPosition];
            if (targetIndexPath == nil) {
                return;
            }
            
            _lastAddedPosition = targetPosition;
            CEADHolder *newADHolder = [[CEADHolder alloc] initWithAdView:adView section:targetIndexPath.section row:targetIndexPath.row];
            [_adHolders setObject:newADHolder forKey:@(targetPosition)];
            
            BOOL isInsertedToTableView = [_delegate CEStreamADDidLoadAdAtIndexPath:targetIndexPath];
           
            if (isInsertedToTableView) {
                [self updateAdStatus];
                [self decorateADView:(UIView *)adView];
            
                [self updateProhibitPosWithAdPos:targetPosition];
                ++_place;
            } else {
                [_adHolders removeObjectForKey:@(targetPosition)];
            }
        }
    }
}

#pragma mark - AD view
- (void)decorateADView:(UIView *)adView
{
    adView.layer.shadowColor = [[UIColor blackColor] CGColor];
    adView.layer.shadowOffset = CGSizeMake(0.0f, 0.0f); // [horizontal offset, vertical offset]
    adView.layer.shadowOpacity = 1.0f; // 0.0 ~ 1.0
    adView.layer.shadowRadius = 1.0f;
}

- (void)updateAdStatus
{
    for (NSNumber *adPos in _adHolders) {
        CEADHolder *holder = [_adHolders objectForKey:adPos];
        BOOL isVisible = ([adPos intValue] >= _firstVisiblePosition && [adPos intValue] <= _lastVisiblePosition);
        if (!_isActive) {
            if (holder.isShowing == YES) {
                holder.isShowing = NO;
                [holder.adView onHide];
            }
            
            if (holder.isPlaying == YES) {
                holder.isPlaying = NO;
                [holder.adView onStop];
            }
        } else {
            if (holder.isPlaying == YES && isVisible == NO) {
                if (holder.isShowing == YES) {
                    holder.isShowing = NO;
                    [holder.adView onHide];
                }
                
                if ([_delegate isIdle]) {
                    holder.isPlaying = NO;
                    [holder.adView onStop];
                }
            } else if (holder.isPlaying == NO && isVisible == NO) {
                if (holder.isShowing == YES) {
                    holder.isShowing = NO;
                    [holder.adView onHide];
                }
            } else if (holder.isPlaying == NO && isVisible == YES) {
                if (holder.isShowing == NO) {
                    holder.isShowing = YES;
                    [holder.adView onShow];
                }
                
                if ([_delegate isIdle] && _enableAutoPlay) {
                    holder.isPlaying = YES;
                    [holder.adView onStart];
                }
            } else if (holder.isPlaying == YES && isVisible == YES) {
                if (holder.isShowing == NO) {
                    holder.isShowing = YES;
                    [holder.adView onShow];
                }
                
            }
        }
    }
}
@end
