//
//  CETableViewADHelper.h
//  Pods
//
//  Created by roylo on 2015/7/16.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 *  CETableViewADHelper
 */
@interface CETableViewADHelper : NSObject
/**
 *  initialize helper with tableView to insert stream ADs, current viewcontroller and AD placement name
 *
 *  @param tableView  tableView to insert stream ADs
 *  @param controller current view controller
 *  @param placement  AD placement name
 *
 *  @return CETableViewADHelper instance
 */
+ (instancetype)helperWithTableView:(UITableView *)tableView
                     viewController:(UIViewController *)controller
                          placement:(NSString *)placement;

/**
 *  initialize helper with tableView to insert stream ADs, current viewcontroller and tag name
 *
 *  @param tableView  tableView to insert stream ADs
 *  @param controller current view controller
 *  @param adTag      tag name
 *
 *  @return CETableViewADHelper instance
 */
+ (instancetype)helperWithTableView:(UITableView *)tableView
                     viewController:(UIViewController *)controller
                              adTag:(NSString *)adTag;

/**
 *  this is an optional method to set stream AD's width
 *  stream AD's height will be adjusted to keep the original creative ratio from width
 *
 *  @param width stream AD width
 */
- (void)setAdWidth:(float)width;

/**
 *  this is an optiona; method to set stream AD's vertical margin between cells
 *
 *  @param verticalMargin the margin height
 */
- (void)setAdVerticalMargin:(float)verticalMargin;

/**
 *  this is an optional method to set stream AD's background color
 *
 *  @param bgColor background color
 */
- (void)setAdBackgroundColor:(UIColor *)bgColor;

/**
 *  customized adCell view
 *
 *  @param customizedAdCellBlock customized code block
 */
- (void)setAdCellCustomizedBlock:(void (^)(UITableViewCell *adCell))customizedAdCellBlock;

/**
 *  start load stream AD
 */
- (void)loadAd;

/**
 *  disable load AD
 */
- (void)disableAd;

/**
 *  clean all cached ADs, reset the helper
 */
- (void)cleanAds;

/**
 *  call while view controller is present in front of user
 *  this will trigger AD to check whether it should start play
 */
- (void)onShow;

/**
 *  call while view controller is hide from user
 *  this will trigger AD to check whether it should stop play
 */
- (void)onHide;

/**
 *  set App AD indexPaths to avoid SDK insert aside them
 *
 *  @param appAdsIndexPaths App Ad's indexPaths
 */
- (void)setAppAdsIndexPaths:(NSArray *)appAdsIndexPaths;

/**
 *  set customized fixed AD position for CrystalExpress AD to insert
 *
 *  @param adIndexPaths fixed AD positions to insert
 */
- (void)setAdCustomIndexPaths:(NSArray *)adIndexPaths;

/**
 *  set Stream Ad to be auto play
 *
 *  @param enableAutoPlay whether to enable AD auto play
 */
- (void)setAutoPlay:(BOOL)enableAutoPlay;

/**
 *  start playing ad at indexPath
 *
 *  @param indexPath Ad indexPath
 */
- (void)startAdAtIndexPath:(NSIndexPath *)indexPath;

/**
 *  stop playing ad at indexPath
 *
 *  @param indexPath Ad indexPath
 */
- (void)stopAdAtIndexPath:(NSIndexPath *)indexPath;
@end

@interface UITableView (CETableViewAdHelper)

- (void)ce_setAdHelper:(CETableViewADHelper *)helper;

/** @name Obtaining the Table View Ad helper */

- (CETableViewADHelper *)ce_adHelper;
- (void)ce_setDataSource:(id<UITableViewDataSource>)dataSource;
- (id<UITableViewDataSource>)ce_dataSource;
- (void)ce_setDelegate:(id<UITableViewDelegate>)delegate;
- (id<UITableViewDelegate>)ce_delegate;
- (void)ce_beginUpdates;
- (void)ce_endUpdates;
- (void)ce_reloadData;
- (void)ce_insertRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation;
- (void)ce_deleteRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation;
- (void)ce_reloadRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation;
- (void)ce_moveRowAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath;
- (void)ce_insertSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation;
- (void)ce_deleteSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation;
- (void)ce_reloadSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation;
- (void)ce_moveSection:(NSInteger)section toSection:(NSInteger)newSection;
- (UITableViewCell *)ce_cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (id)ce_dequeueReusableCellWithIdentifier:(NSString *)identifier forIndexPath:(NSIndexPath *)indexPath;
- (void)ce_deselectRowAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated;
- (NSIndexPath *)ce_indexPathForCell:(UITableViewCell *)cell;
- (NSIndexPath *)ce_indexPathForRowAtPoint:(CGPoint)point;
- (NSIndexPath *)ce_indexPathForSelectedRow;
- (NSArray *)ce_indexPathsForRowsInRect:(CGRect)rect;
- (NSArray *)ce_indexPathsForSelectedRows;
- (NSArray *)ce_indexPathsForVisibleRows;
- (CGRect)ce_rectForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)ce_scrollToRowAtIndexPath:(NSIndexPath *)indexPath atScrollPosition:(UITableViewScrollPosition)scrollPosition animated:(BOOL)animated;
- (void)ce_selectRowAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated scrollPosition:(UITableViewScrollPosition)scrollPosition;
- (NSArray *)ce_visibleCells;

@end
