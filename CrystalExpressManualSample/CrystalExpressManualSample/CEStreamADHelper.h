//
//  CEStreamADHelper.h
//  Pods
//
//  Created by roylo on 2015/7/16.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol CEStreamAdHelperDelegate <NSObject>

@optional
- (BOOL)CEStreamADDidLoadAdAtIndexPath:(NSIndexPath *)indexPath;
- (void)CEStreamADDidRemoveAdsAtIndexPaths:(NSArray *)indexPaths;
- (void)CEStreamADOnPulldownAnimation;
- (int)indexPathToPosition:(NSIndexPath *)indexPath;
- (NSIndexPath *)positionToIndexPath:(int)position;
- (BOOL)isIdle;
@end

#pragma mark - CEADHolder
@class ADView;

@interface CEADHolder : NSObject
@property (nonatomic, strong) ADView *adView;
@property (nonatomic, assign) BOOL isShowing;
@property (nonatomic, assign) BOOL isPlaying;
@property (nonatomic, assign) NSUInteger section;
@property (nonatomic, assign) NSUInteger row;

- (instancetype)initWithAdView:(ADView *)adView section:(NSUInteger)section row:(NSUInteger)row;
@end

#pragma mark - CEStreamPositionManager
@interface CEStreamPositionManager : NSObject
@property (nonatomic, strong) NSString *placement;
@property (nonatomic, strong) NSString *tag;
@property (nonatomic, assign) int minPos;
@property (nonatomic, assign) int maxPos;
@property (nonatomic, assign) int servingFreq;

- (instancetype)initWithPlacement:(NSString *)placement minPos:(int)minPos maxPos:(int)maxPos;
- (instancetype)initWithTag:(NSString *)tag minPos:(int)minPos maxPos:(int)maxPos;
@end

#define DEFAULT_INIT_VISIBLE_COUNTS 5

#pragma mark - CEStreamADHelper
@interface CEStreamADHelper : NSObject
@property (nonatomic, weak) id<CEStreamAdHelperDelegate> delegate;
@property (nonatomic, strong) NSMutableDictionary *adHolders;
@property (nonatomic, strong) CEStreamPositionManager *positionMgr;
@property (nonatomic, strong) NSArray *channelPlacements;
@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) NSMutableArray *desiredPositions;
@property (nonatomic, assign) int lastViewedPosition;
@property (nonatomic, assign) NSString *curPlacement;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSNumber *> *isPlacementProcessing;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSNumber *> *placementLastAddedPosition;
@property (nonatomic, strong) NSMutableDictionary<NSString *, ADView *> *placementAdViewRecycled;

- (instancetype)initWithDelegate:(id<CEStreamAdHelperDelegate>)delegate;
- (void)setAdWidth:(float)width;
- (void)setActive:(BOOL)isActive;
- (void)updateAdStatus;
- (void)prerollWithVisibleCounts:(int)visibleCounts;
- (void)reset;
- (void)setAppAdsIndexPaths:(NSArray *)appAdsIndexPaths;
- (void)setAdCustomIndexPaths:(NSArray *)adIndexPaths;
- (void)setAutoPlay:(BOOL)enableAutoPlay;
- (void)startAdAtPosition:(NSUInteger)position;
- (void)stopAdAtPosition:(NSUInteger)position;

- (NSUInteger)adjustedNumberOfItems:(NSUInteger)numberOfItems inSection:(NSUInteger)section;
- (BOOL)isAdAtIndexPath:(NSIndexPath *)indexPath;
- (CGSize)getAdSizeAtIndexPath:(NSIndexPath *)indexPath;

- (NSIndexPath *)originalIndexPathForAdjustedIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)adjustedIndexPathForOriginalIndexPath:(NSIndexPath *)indexPath;
- (NSArray *)originalIndexPathsForAdjustedIndexPaths:(NSArray *)indexPaths;
- (NSArray *)adjustedIndexPathsForOriginalIndexPaths:(NSArray *)indexPaths;

- (void)insertItemsAtIndexPaths:(NSArray *)originalIndexPaths;
- (void)deleteItemsAtIndexPaths:(NSArray *)originalIndexPaths;
- (void)moveItemAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath;
- (void)insertSections:(NSIndexSet *)sections;
- (void)deleteSections:(NSIndexSet *)sections;
- (void)moveSection:(NSInteger)section toSection:(NSInteger)newSection;

- (void)updateVisibleCellsFromPosition:(int)firstPos toPosition:(int)lastPos;

// override by children class
- (UIView *)loadAdAtIndexPath:(NSIndexPath *)indexPath;
- (void)requestAdWithPlacement:(NSString *)placement;
@end
