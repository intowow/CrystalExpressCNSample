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

//@protocol I2WAPIDelegate <NSObject>
//- (void)adInAnimation:(UIView *)adView;
//- (void)adViewDidReceiveAd:(UIView *)adView;
//@end

typedef NS_ENUM(NSUInteger, CESplashType) {
    SPLASH_TYPE_DEFAULT,        // default to get any kind of splash ad
    SPLASH_TYPE_MULTI_OFFER,    // MULTI_OFFER to get ads can fit in multioffer view
    SPLASH_TYPE_SPLASH2,        // SPLASH2 to get ads has no header and bottom
};

@interface I2WAPI : NSObject
// initializer
+ (void)initWithVerboseLog:(BOOL)enableVerbose;
+ (BOOL)VERBOSE_LOG;

+ (BOOL)isAdServing;
+ (void)refreshI2WAds;
+ (void)setOpenSplashLastViewTime:(long long)time;
+ (long long)getSectionSplashGuardTime;
+ (void)triggerBackgroundFetchOnSuccess:(void (^)())success
                                 onFail:(void (^)())fail
                               onNoData:(void (^)())noData;

/**
 *  request Splash AD
 *
 *  @return InterstitialADViewController
 */
+ (InterstitialADViewController *)requestSplashAD;

/**
 *  request MultiOffer Splash AD
 *
 *  @return InterstitialADViewController
 */
+ (InterstitialADViewController *)requestMultiofferAD;

+ (void)getSplashADWithPlacement:(NSString *)placement
                           place:(int)place
                            type:(CESplashType)splashType
                         onReady:(void (^)(ADView *adView, BOOL fitsMultiOffer))ready
                       onFailure:(void (^)(NSError *error))failure;

+ (void)getBannerADWithPlacement:(NSString *)placement
                         onReady:(void (^)(ADView *))ready
                       onFailure:(void (^)(NSError *))failure;

+ (void)getStreamADWithPlacement:(NSString *)placement
                       helperKey:(NSString *)helperKey
                           place:(int)place
                         adWidth:(CGFloat)adWidth
                         onReady:(void (^)(ADView *adView))ready
                       onFailure:(void (^)(NSError *error))failure
             onPullDownAnimation:(void (^)(UIView *))animation;

+ (void)getContentADWithPlacement:(NSString *)placement
                             isPreroll:(BOOL)isPreroll
                               onReady:(void (^)(ADView *))ready
                             onFailure:(void (^)(NSError *))failure
                   onPullDownAnimation:(void (^)(UIView *))animation;


+ (void)setActivePlacement:(NSString *)placement;
+ (int)getStreamADServingFreqWithPlacement:(NSString *)placement;
+ (int)getStreamADServingMinPositionWithPlacement:(NSString *)placement;

#pragma mark - track API
+ (void)trackCustomEventWithType:(NSString *)type props:(NSDictionary *)props;
+ (void)updateUserLastLocation:(NSDictionary *)location;

#pragma mark - deep link
+ (void)handleDeepLinkWithUrl:(NSURL *)url sourceApplication:(NSString *)sourceApplication;

#pragma mark - testing API
+ (void)cleanup;
+ (void)sendDebuggerMessage:(NSString *)msg;
@end
