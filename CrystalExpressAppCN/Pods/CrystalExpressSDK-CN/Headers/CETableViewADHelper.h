//
//  CETableViewADHelper.h
//  Pods
//
//  Created by roylo on 2015/7/16.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CETableViewADHelper : NSObject
+ (instancetype)helperWithTableView:(UITableView *)tableView
                     viewController:(UIViewController *)controller
                          placement:(NSString *)placement;

- (void)setAdWidth:(float)width;
- (void)loadAd;
- (void)reloadAd;
- (void)onShow;
- (void)onHide;
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
