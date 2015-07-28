//
//  CESplashAD.h
//  Pods
//
//  Created by roylo on 2015/7/15.
//
//

#import <Foundation/Foundation.h>
#import "I2WAPI.h"
#import "SplashADInterfaceViewController.h"

/**
 *  CESplashADHelper Delegate that can receive AD events
 */
@protocol CESplashADDelegate <NSObject>
@optional
/**
 *  @brief callback function while splash AD is ready to present
 *
 *  @param ad the adViews in viewController
 *  @param vc splash AD viewController
 */
- (void)CESplashADDidReceiveAd:(NSArray *)ad viewController:(SplashADInterfaceViewController *)vc;

/**
 * @brief callback function while fail to request splash AD
 *
 * @param error the error which indicate why request ad fail
 * @param vc    splash AD viewController, will be nil here
 */
- (void)CESplashADDidFailToReceiveAdWithError:(NSError *)error viewController:(SplashADInterfaceViewController *)vc;

/**
 *  @brief callback function while splash AD viewcontroller will dismiss from screen
 *
 *  @param vc the splash AD view controller
 */
- (void)CESplashAdWillDismissScreen:(SplashADInterfaceViewController *)vc;

/**
 *  @brief callback function while splash AD viewcontroller will present to screen
 *
 *  @param vc the splash AD view controller
 */
- (void)CESplashAdWillPresentScreen:(SplashADInterfaceViewController *)vc;

/**
 *  @brief callback function while splash AD viewcontroller did dismiss from screen
 *
 *  @param vc the splash AD view controller
 */
- (void)CESplashAdDidDismissScreen:(SplashADInterfaceViewController *)vc;

/**
 *  @brief callback function while splash AD viewcontroller did present from screen
 *
 *  @param vc the splash AD view controller
 */
- (void)CESplashAdDidPresentScreen:(SplashADInterfaceViewController *)vc;
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

typedef NS_ENUM(NSUInteger, CEPortraitViewControllerPresentAnimationOption){
    CE_SPLASH_PORTRAIT_PRESENT_DEFAULT,
    CE_SPLASH_PORTRAIT_PRESENT_VERTICAL_BOUNCE,
};

typedef NS_ENUM(NSUInteger, CEPortraitViewControllerDismissAnimationOption){
    CE_SPLASH_PORTRAIT_DISMISS_DEFAULT,
};

typedef NS_ENUM(NSUInteger, CELandscapeViewControllerPresentAnimationOption){
    CE_SPLASH_LANDSCAPE_PRESENT_DEFAULT,
    CE_SPLASH_LANDSCAPE_PRESENT_ROTATION,
};

typedef NS_ENUM(NSUInteger, CELandscapeViewControllerDismissAnimationOption){
    CE_SPLASH_LANDSCAPE_DISMISS_DEFAULT,
    CE_SPLASH_LANDSCAPE_DISMISS_ROTATION,
};

/**
 *  CESplashAD provide API to request Splash AD for different Splash mode
 */
@interface CESplashAD : NSObject
@property (nonatomic, weak) id<CESplashADDelegate> delegate;

/**
 *  @brief init CESplashAD with AD placement name and delegate
 *
 *  @param placement AD placement name
 *  @param delegate  delegate that conform CESplashADDelegate
 *
 *  @return CESplashAD instance
 */
- (instancetype)initWithPlacement:(NSString *)placement
                         delegate:(id<CESplashADDelegate>)delegate;

/**
 *  @brief set the desire splash mode
 *
 *  @param splashMode request splash mode
 */
- (void)setSplashMode:(CESplashMode)splashMode;

/**
 *  @brief Starts loading ad content process.
 */
- (void)loadAd;

/**
 *  @brief Presents the splash ad modally from viewCotroller
 *
 *  @param viewController view controller from which splash ad will be presented.
 *  @param animated       animate presenting
 */
- (void)showFromViewController:(UIViewController *)viewController
                      animated:(BOOL)animated;

/**
 *  @brief dismiss splash view controller
 *
 *  @param animated animate presenting
 */
- (void)dismissAnimated:(BOOL)animated;

- (void)setPortraitViewControllerPresentAnimation:(CEPortraitViewControllerPresentAnimationOption)presentAnimation
                                 DismissAnimation:(CEPortraitViewControllerDismissAnimationOption)dismissAnimation;
- (void)setLandscapeViewControllerPresentAnimation:(CELandscapeViewControllerPresentAnimationOption)presentAnimation
                                  DismissAnimation:(CELandscapeViewControllerDismissAnimationOption)dismissAnimation;
- (void)setCustomPortraitViewControllerPresentAnimation:(id<UIViewControllerAnimatedTransitioning>)presentAnimation
                                       DismissAnimation:(id<UIViewControllerAnimatedTransitioning>)dismissAnimation;
- (void)setCustomLandscapeViewControllerPresentAnimation:(id<UIViewControllerAnimatedTransitioning>)presentAnimation
                                        DismissAnimation:(id<UIViewControllerAnimatedTransitioning>)dismissAnimation;
@end
