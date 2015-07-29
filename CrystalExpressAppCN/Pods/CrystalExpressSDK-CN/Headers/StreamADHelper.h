//
//  StreamADHelper.h
//  Pods
//
//  Created by roylo on 2014/10/31.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class ADView;
/**
 *  StreamADHelper Delegate that handle stream AD's callback event
 */
@protocol StreamADHelperDelegate <NSObject>

/**
 *  @brief callback delegate while the stream ad is ready at the target indexPath, and indicate whether it is a preroll call
 *
 *  @param adView    stream AD UIView
 *  @param indexPath the target indexPath want to insert to data source
 *  @param isPreroll indicate whether this is an preroll request
 *
 *  @return the final NSIndexPath insert into data source
 */
- (NSIndexPath *)onADLoaded:(UIView *)adView atIndexPath:(NSIndexPath *)indexPath isPreroll:(BOOL)isPreroll;

/**
 *  @brief callback on pull down animation happen at indexPath
 *
 *  @param adView    the pulldown stream AD UIView
 *  @param indexPath the pulldown stream AD's NSIndexPath
 */
- (void)onADAnimation:(UIView *)adView atIndexPath:(NSIndexPath *)indexPath;

/**
 *  @brief callback to check whether the stream view is in idle state
 *
 *  @return whether the stream view is in idle state
 */
- (BOOL)checkIdle;
@end

/**
 *  StreamADHelper which integrate UITableViewController with CrystalExpress SDK to request stream ADs
 */
@interface StreamADHelper : NSObject
/// represent whether this helper is in active state
@property (nonatomic, assign) BOOL isActiveSection;
/// the delegate conform StreamADHelperDelegate
@property (nonatomic, weak) id<StreamADHelperDelegate> delegate;

/**
 *  @brief initialize function
 *
 *  @param placement placement string
 *
 *  @return StreamADHelper instance
 */
- (instancetype)initWithPlacement:(NSString *)placement;

/**
 *  @brief preroll to prepare a stream AD in advance
 */
- (void)preroll;

/**
 *  @brief request stream AD at NSIndexPath
 *
 *  @param indexPath the NSIndexPath represent the position in tableView
 *
 *  @return stream AD UIView, nil if not an AD at this NSIndexPath
 */
- (UIView *)requestADAtPosition:(NSIndexPath *)indexPath;

/**
 *  @brief update current tableVIew visible cell
 *
 *  @param tableView current tableView
 */
- (void)updateVisiblePosition:(UITableView *)tableView;

/**
 *  @brief return all loaded ADs cached in StreamADHelper
 *
 *  @return NSOrderedSet contains all loaded ADs
 */
- (NSOrderedSet *)getLoadedAds;

/**
 *  @brief force all loaded AD stop (ex. stop video playing)
 */
- (void)stopADs;

/**
 *  @brief set helper active state, AD will only play in active helper
 *
 *  @param isActive active state
 */
- (void)setActive:(BOOL)isActive;

/**
 *  @brief check whether the NSIndexPath is an AD
 *
 *  @param indexPath the indexPath in tableView
 *
 *  @return whether this indexPath is an AD
 */
- (BOOL)isAdAtIndexPath:(NSIndexPath *)indexPath;

/**
 *  @brief set stream AD width
 *
 *  @param width prefer stream AD width
 */
- (void)setPreferAdWidth:(CGFloat)width;

/**
 *  @brief get current AD width setting
 *
 *  @return current AD width setting, -1 if didn't set
 */
- (CGFloat)getCurrentAdWidthSetting;

/**
 *  @brief remove all loaded ADs, should be called while tableView data source reloaded (ex. pull to refresh)
 */
- (void)cleanADs;

#pragma mark - event listener
/**
 *  @brief scrollView did scroll event hook
 *
 *  @param scrollView scrollView
 *  @param tableView  tableView
 */
- (void)scrollViewDidScroll:(UIScrollView *)scrollView tableView:(UITableView *)tableView;

/**
 *  @deprecated
 *  @brief tableView did end display cell hook
 *
 *  @param tableView tableView
 *  @param cell      tableView cell
 *  @param indexPath indexPath in tableView
 */
- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath DEPRECATED_ATTRIBUTE;

/**
 *  @deprecated
 *  @brief tableView will display cell hook
 *
 *  @param tableView tableView
 *  @param cell      tableView cell
 *  @param indexPath indexPath in tableView
 */
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath DEPRECATED_ATTRIBUTE;

/**
 *  @brief trigger AD start/stop check while scrollView state changed
 */
- (void)scrollViewStateChanged;
@end
