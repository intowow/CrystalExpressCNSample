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
@protocol StreamADHelperDelegate <NSObject>

// callback delegate while the stream ad is ready at the target indexPath, and indicate whether it is a preroll call
- (NSIndexPath *)onADLoaded:(UIView *)adView atIndexPath:(NSIndexPath *)indexPath isPreroll:(BOOL)isPreroll;

// callback on pull down animation happen at indexPath
- (void)onADAnimation:(UIView *)adView atIndexPath:(NSIndexPath *)indexPath;

// callback to check whether the view is in idle state
- (BOOL)checkIdle;
@end

@interface StreamADHelper : NSObject
@property (nonatomic, assign) BOOL isActiveSection;
@property (nonatomic, weak) id<StreamADHelperDelegate> delegate;

// init helper with placement name
- (instancetype)initWithPlacement:(NSString *)placement;

// preroll will request a stream ad for future use
- (void)preroll;

// request stream ad at stream indexPath
- (UIView *)requestADAtPosition:(NSIndexPath *)indexPath;

// update current table view visible cell
- (void)updateVisiblePosition:(UITableView *)tableView;

// get all loaded ads
- (NSOrderedSet *)getLoadedAds;

// force all loaded ad stop (ex. stop video playing)
- (void)stopADs;

// set helper active state, ad will only play in active helper
- (void)setActive:(BOOL)isActive;

// check whether the indexPath is an AD
- (BOOL)isAdAtIndexPath:(NSIndexPath *)indexPath;

// set prefer AD width
- (void)setPreferAdWidth:(CGFloat)width;

// get previous setting of AD width, return -1 if user didn't set adWidth before
- (CGFloat)getCurrentAdWidthSetting;

// remove all loaded ADs, please call this while stream data source reloaded (ex. pull to refresh)
- (void)cleanADs;

#pragma mark - event listener
// scroll view did scroll event hook
- (void)scrollViewDidScroll:(UIScrollView *)scrollView tableView:(UITableView *)tableView;

// deprecated.
- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;
// deprecated.
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;

// trigger AD state change while scrollview state changed
- (void)scrollViewStateChanged;
@end
