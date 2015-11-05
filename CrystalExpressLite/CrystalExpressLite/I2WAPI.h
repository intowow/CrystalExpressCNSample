//
//  I2WAPI.h
//  Pods
//
//  Created by roylo on 2014/10/20.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class InterstitialADViewController, ADView;

/**
 *  CrsytalExpress AD event delegate
 */
@protocol I2WADEventDelegate <NSObject>
/**
 *  @brief callback while AD is clicked by user
 *
 *  @param adId AD unique string id
 *  @param data the click landing url
 */
- (void)onAdClick:(NSString *)adId data:(NSString *)data;

/**
 *  @brief callback while AD is viewed by user
 *
 *  @param adId AD unique string id
 */
- (void)onAdImpression:(NSString *)adId;
@end

/**
 *  @brief I2WAPI class
 */
@interface I2WAPI : NSObject
/**
 *  @brief initializer of I2WAPI
 *
 *  @param enableVerbose whether to enable debug message
 *  @param testMode      whether to init in TEST mode
 */
+ (void)initWithVerboseLog:(BOOL)enableVerbose isTestMode:(BOOL)testMode;

/**
 *  @brief initializer of I2WAPI
 *
 *  @param enableVerbose whether to enable debug message
 *  @param testMode      whether to init in TEST mode
 *  @param crystalId     your crystal id
 */
+ (void)initWithVerboseLog:(BOOL)enableVerbose isTestMode:(BOOL)testMode crystalId:(NSString *)crystalId;

/**
 *  @brief is I2WAPI is in TEST mode
 *
 *  @return BOOL
 */
+ (BOOL)isTestMode;

/**
 *  @brief get current using crystal id
 *
 *  @return crystal id
 */
+ (NSString *)getCrystalID;

/**
 *  @brief trigger SDK background fetch flow
 *
 *  @param success the callback block of background fetch success
 *  @param fail    the callback block of background fetch fail
 *  @param noData  the callback block of background fetch no data
 */
+ (void)triggerBackgroundFetchOnSuccess:(void (^)())success
                                 onFail:(void (^)())fail
                               onNoData:(void (^)())noData;

#pragma mark - audience targeting
/**
 *  @brief set audience targeting tags
 *
 *  @param tags set of tag strings
 */
+ (void)setAudienceTargetingUserTags:(NSSet *)tags;

#pragma mark - callback method
/**
 *  @brief set AD event delegate
 *
 *  @param delegate the object conform to I2WADEventDelegate
 */
+ (void)setAdEventDelegate:(id<I2WADEventDelegate>)delegate;

#pragma mark - deep link
/**
 *  @brief handle deeplinking
 *
 *  @param url               deeplink url
 *  @param sourceApplication sourceApplication
 */
+ (void)handleDeepLinkWithUrl:(NSURL *)url sourceApplication:(NSString *)sourceApplication;

#pragma mark - testing API
/**
 *  @brief cleanup SDK storage, this is for testing only
 */
+ (void)cleanup;

@end
