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
 *  the Splash AD's type
 */
typedef NS_ENUM(NSUInteger, CESplashType){
    /**
     *  default type, can be multi-offer or splash2
     */
    SPLASH_TYPE_DEFAULT,
    /**
     *  MULTI_OFFER to get ADs can fit in multioffer view
     */
    SPLASH_TYPE_MULTI_OFFER,
    /**
     *  SPLASH2 to get ADs has no header and bottom
     */
    SPLASH_TYPE_SPLASH2
};

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
 *  @brief check whether AD serving is enabled in backend server
 *
 *  @return BOOL
 */
+ (BOOL)isAdServing;

/**
 *  @brief get current using crystal id
 *
 *  @return crystal id
 */
+ (NSString *)getCrystalID;

/**
 *  @brief refresh/remove unnecessary AD creatives
 */
+ (void)refreshI2WAds;

/**
 *  @deprecated
 *  @brief set OpenSplash AD last view time
 *
 *  @param time unixtime in millisecond
 */
+ (void)setOpenSplashLastViewTime:(long long)time DEPRECATED_ATTRIBUTE;

/**
 *  @deprecated
 *  @brief get section splash guard time server setting
 *
 *  @return millisecond
 */
+ (long long)getSectionSplashGuardTime DEPRECATED_ATTRIBUTE;

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

/**
 *  @deprecated
 *  @brief request Splash AD
 *
 *  @return InterstitialADViewController
 */
+ (InterstitialADViewController *)requestSplashAD DEPRECATED_ATTRIBUTE;

/**
 *  @deprecated
 *  @brief request MultiOffer Splash AD
 *
 *  @return InterstitialADViewController
 */
+ (InterstitialADViewController *)requestMultiofferAD DEPRECATED_ATTRIBUTE;

/**
 *  @brief request Splash AD
 *
 *  @param placement  placement string
 *  @param place      AD order
 *  @param splashType the splash type want to request
 *  @param ready      callback block while ADView is ready
 *  @param failure    callback block while fail to request AD
 */
+ (void)getSplashADWithPlacement:(NSString *)placement
                           place:(int)place
                            type:(CESplashType)splashType
                         onReady:(void (^)(ADView *adView, BOOL fitsMultiOffer))ready
                       onFailure:(void (^)(NSError *error))failure;

/**
 *  @brief request banner AD
 *
 *  @param placement placement string
 *  @param ready     callback block while ADView is ready
 *  @param failure   callback block while fail to request AD
 */
+ (void)getBannerADWithPlacement:(NSString *)placement
                         onReady:(void (^)(ADView *))ready
                       onFailure:(void (^)(NSError *))failure;

/**
 *  @brief request stream AD
 *
 *  @param placement placement string
 *  @param helperKey the key to identify this request, will be placement+unix_timestamp (ex. STREAM_1435318372000)
 *  @param place     AD order
 *  @param adWidth   preferred stream AD width
 *  @param timeout   timeout second to wait for stream ad
 *  @param ready     callback block while ADView is ready
 *  @param failure   callback block while fail to request AD
 *  @param animation callback block while AD animation occur (ex. CARD-VIDEO-PULLDOWN AD is clicked by user)
 */
+ (void)getStreamADWithPlacement:(NSString *)placement
                       helperKey:(NSString *)helperKey
                           place:(int)place
                         adWidth:(CGFloat)adWidth
                         timeout:(int)timeout
                         onReady:(void (^)(ADView *adView))ready
                       onFailure:(void (^)(NSError *error))failure
             onPullDownAnimation:(void (^)(UIView *))animation;

/**
 *  @brief request content AD
 *
 *  @param placement placement string
 *  @param isPreroll whether this is a preroll request
 *  @param registerCallback whether to register a callback for asyn callback while ad available
 *  @param adWidth   preferred content AD width
 *  @param ready     callback block while ADView is ready
 *  @param failure   callback block while fail to request AD
 *  @param animation callback block while AD animation occur (ex. CARD-VIDEO-PULLDOWN AD is clicked by user)
 *
 *  @return token to identify ad
 */
+ (NSString *)getContentADWithPlacement:(NSString *)placement
                              isPreroll:(BOOL)isPreroll
                       registerCallback:(BOOL)registerCallback
                                adWidth:(CGFloat)adWidth
                                onReady:(void (^)(ADView *adView, NSString *adToken))ready
                              onFailure:(void (^)(NSError *))failure
                    onPullDownAnimation:(void (^)(UIView *))animation;

/**
 *  @brief set current active placement
 *
 *  @param placement placement string
 */
+ (void)setActivePlacement:(NSString *)placement;

/**
 *  @brief set current active placements
 *
 *  @param placements an array of placement names
 */
+ (void)setActivePlacements:(NSArray *)placements;

/**
 *  @brief get stream AD serving frequency server setting
 *
 *  @param placement placement string
 *
 *  @return int value for frequency number
 */
+ (int)getStreamADServingFreqWithPlacement:(NSString *)placement;

/**
 *  @brief get stream AD serving min position server setting
 *
 *  @param placement placement string
 *
 *  @return int value for min position
 */
+ (int)getStreamADServingMinPositionWithPlacement:(NSString *)placement;

/**
 *  @brief get stream AD serving max position server setting
 *
 *  @param placement placement string
 *
 *  @return int value for max position
 */
+ (int)getStreamADServingMaxPositionWithPlacement:(NSString *)placement;

#pragma mark - Ad tag
/**
 *  @brief get AD placement name from (adTag name, position)
 *
 *  @param adTag    AD tag name
 *  @param posIndex position index to place AD
 *
 *  @return placement name
 */
+ (NSString *)getPlacementWithAdTag:(NSString *)adTag posIndex:(int)posIndex;

/**
 *  @brief check whether this placement is blocking
 *
 *  @param placement placement name
 *
 *  @return true if placement group is blocking, otherwise false
 */
+ (BOOL)isPlacementBlocking:(NSString *)placement;

/**
 *  @brief get stream placement setting, including acceptanceRanges, freq
 *
 *  @param tagName   ad tag name
 *  @param placement placement name
 *
 *  @return dictionary with info key: acceptanceRanges, freq
 */
+ (NSDictionary *)getPositionLimitationWithTagName:(NSString *)tagName placement:(NSString *)placement;

/**
 *  @brief get stream all placements info, including min/max position in all placements, and placements name
 *
 *  @param tagName ad tag name
 *
 *  @return dictionary with info key: maxPos, minPos, placements
 */
+ (NSDictionary *)getStreamPlacementsInfoWithTagName:(NSString *)tagName;

#pragma mark - audience targeting
/**
 *  @brief set audience targeting tags
 *
 *  @param tags set of tag strings
 */
+ (void)setAudienceTargetingUserTags:(NSSet *)tags;

#pragma mark - track API
/**
 *  @brief send customized track event to CrystalExpress tracking server
 *
 *  @param type  string represet event type
 *  @param props properties dictionary
 */
+ (void)trackCustomEventWithType:(NSString *)type props:(NSDictionary *)props;

/**
 *  @brief send AD request tracking message
 *
 *  @param placement placement string
 *  @param adToken   ad token
 */
+ (void)trackAdRequestWithPlacement:(NSString *)placement adToken:(NSString *)adToken;

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

/**
 *  @brief send debug message to realtime debug server
 *
 *  @param msg message string
 */
+ (void)sendDebuggerMessage:(NSString *)msg;
@end
