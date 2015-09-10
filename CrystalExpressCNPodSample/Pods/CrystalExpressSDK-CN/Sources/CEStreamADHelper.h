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
- (void)CEStreamADDidLoadAdAtIndexPath:(NSIndexPath *)indexPath;
- (void)CEStreamADDidRemoveAdsAtIndexPaths:(NSArray *)indexPaths;
- (void)CEStreamADOnPulldownAnimation;
- (int)indexPathToPosition:(NSIndexPath *)indexPath;
- (NSIndexPath *)positionToIndexPath:(int)position;
- (BOOL)isIdle;
@end

@interface CEStreamADHelper : NSObject
@property (nonatomic, weak) id<CEStreamAdHelperDelegate> delegate;
- (instancetype)initWithPlacement:(NSString *)placement delegate:(id<CEStreamAdHelperDelegate>)delegate;
- (void)setAdWidth:(float)width;
- (void)setActive:(BOOL)isActive;
- (void)updateAdStatus;
- (void)preroll;
- (void)reset;
- (void)setAppAdsIndexPaths:(NSArray *)appAdsIndexPaths;
- (void)setAdCustomIndexPaths:(NSArray *)adIndexPaths;
- (void)setAutoPlay:(BOOL)enableAutoPlay;
- (void)startAdAtPosition:(NSUInteger)position;
- (void)stopAdAtPosition:(NSUInteger)position;

- (void)setItemCount:(NSUInteger)count forSection:(NSInteger)section;
- (NSUInteger)adjustedNumberOfItems:(NSUInteger)numberOfItems inSection:(NSUInteger)section;
- (UIView *)loadAdAtIndexPath:(NSIndexPath *)indexPath;
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
@end
