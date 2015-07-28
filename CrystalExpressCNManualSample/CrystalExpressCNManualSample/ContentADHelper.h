//
//  ContentADHelper.h
//  Pods
//
//  Created by roylo on 2015/1/5.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 *  ContentADHelper which integrate scrollView page with CrystalExpress SDK to request content ADs
 */
@interface ContentADHelper : NSObject
/// the block code that will be executed while Card-Video-PullDown format AD is clicked by user
@property (nonatomic, copy) void (^onPullDownAnimation)(UIView *adView);

/**
 *  @brief initialize function
 *
 *  @param placement placement string
 *
 *  @return ContentADHelper instance
 */
- (instancetype)initWithPlacement:(NSString *)placement;

/**
 *  @brief preroll to prepare a content AD in advance
 */
- (void)preroll;

/**
 *  @brief request content AD with an unique content string id
 *
 *  @param articleId an id represent this content page
 *
 *  @return content AD UIView
 */
- (UIView *)requestADWithContentId:(NSString *)articleId;

/**
 *  @brief set the content AD's scrollOffset
 *
 *  @param key    article_id, an id represent this content page
 *  @param offset scrollView offset
 */
- (void)setScrollOffsetWithKey:(NSString *)key offset:(int)offset;

/**
 *  @brief check whether AD should start/stop via scrollView bounds
 *
 *  @param key    article_id, an id represent this content page
 *  @param bounds scrollView visible bounds
 */
- (void)checkAdStartWithKey:(NSString *)key ScrollViewBounds:(CGRect)bounds;

/**
 *  @brief update scrollView visible bounds
 *
 *  @param bounds scrollView bounds
 *  @param key    article_id, an id represent this content page
 */
- (void)updateScrollViewBounds:(CGRect)bounds withKey:(NSString *)key;
@end
