//
//  SplashADHelper.h
//  Pods
//
//  Created by roylo on 2015/4/16.
//
//

#import <Foundation/Foundation.h>
#import "I2WAPI.h"

#define MULTI_OFFER_AD_MAX_COUNT 4

@class SplashADInterfaceViewController;

/**
 *  SplashADHelper Delegate that can receive AD events
 */
@protocol SplashADHelperDelegate <NSObject>
@required
/**
 *  @brief callback function while splash AD is ready to present
 *
 *  @param ad the adViews in viewController
 *  @param vc splash AD viewController
 */
- (void)SplashADDidReceiveAd:(NSArray *)ad viewController:(SplashADInterfaceViewController *)vc;

/**
 * @brief callback function while fail to request splash AD
 *
 * @param error the error which indicate why request ad fail
 * @param vc    splash AD viewController, will be nil here
 */
- (void)SplashADDidFailToReceiveAdWithError:(NSError *)error viewController:(SplashADInterfaceViewController *)vc;

@end

/**
 *  Splash AD Mode
 */
typedef NS_ENUM(NSUInteger, CESplashMode){
    /**
     *  unknown splash mode, default value
     */
    CE_SPLASH_MODE_UNKNOWN,
    /**
     *  hybrid mode means viewController might be multi-offer or single-offer
     */
    CE_SPLASH_MODE_HYBRID,
    /**
     *  multi-offer splash ADs will contain 1~4 splash ADs in viewController
     *  allow user to swipe between ADs
     */
    CE_SPLASH_MODE_MULTI_OFFER,
    /**
     *  single-offer gurantee that viewController will only have 1 splash AD
     */
    CE_SPLASH_MODE_SINGLE_OFFER,
};

/**
 *  SplashADHelper provide API to request Splash AD for different Splash mode
 */
@interface SplashADHelper : NSObject
/// the delegate that conform SplashADHelperDelegate
@property (nonatomic, weak) id<SplashADHelperDelegate> delegate;

/**
 *  @brief use this method to request Splash ADs
 *
 *  @param placement  placement string
 *  @param splashMode request splash mode
 */
- (void)requestSplashADWithPlacement:(NSString *)placement mode:(CESplashMode)splashMode;
@end
