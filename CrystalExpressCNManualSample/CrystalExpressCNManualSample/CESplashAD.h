//
//  CESplashAD.h
//  Pods
//
//  Created by roylo on 2015/7/15.
//
//

#import <Foundation/Foundation.h>
#import "I2WAPI.h"
//#import "SplashADInterfaceViewController.h"

@class SplashADInterfaceViewController;
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

/**
 *  Portrait viewcontroller present animation option
 */
typedef NS_ENUM(NSUInteger, CEPortraitViewControllerPresentAnimationOption){
    /**
     *  iOS default animation
     */
    CE_SPLASH_PORTRAIT_PRESENT_DEFAULT,
    /**
     *  vertical bounce present animation
     */
    CE_SPLASH_PORTRAIT_PRESENT_VERTICAL_BOUNCE,
};

/**
 *  Portrait viewcontroller dismiss animation option
 */
typedef NS_ENUM(NSUInteger, CEPortraitViewControllerDismissAnimationOption){
    /**
     *  iOS default animation
     */
    CE_SPLASH_PORTRAIT_DISMISS_DEFAULT,
};

/**
 *  Landscape viewcontroller present animation option
 */
typedef NS_ENUM(NSUInteger, CELandscapeViewControllerPresentAnimationOption){
    /**
     *  iOS default animation
     */
    CE_SPLASH_LANDSCAPE_PRESENT_DEFAULT,
    /**
     *  rotation from portrait to landscape animation
     */
    CE_SPLASH_LANDSCAPE_PRESENT_ROTATION,
};

/**
 *  Landscape viewcontroller dismiss animation option
 */
typedef NS_ENUM(NSUInteger, CELandscapeViewControllerDismissAnimationOption){
    /**
     *  iOS default animation
     */
    CE_SPLASH_LANDSCAPE_DISMISS_DEFAULT,
    /**
     *  rotation from landscape to portrait animation 
     */
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
 *  @brief return whether viewcontroller is a Splash Ad viewcontroller
 *
 *  @param vc viewcontroller
 *
 *  @return bool to indicate viewcontroller is a CrystalExpress Splash AD viewcontroller
 */
- (BOOL)isSplashAdVC:(UIViewController *)vc;

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

/**
 *  @brief dismiss splash view controller automatically after user had engage this Ad
 *
 *  @param dismissAd
 */
- (void)setDismissAdAfterEngageAd:(BOOL)dismissAd;

/**
 *  @brief set portrait splash AD present and dismiss animation with CrystalExpress bulit-in animation effect
 *
 *  @param presentAnimation viewcontroller present animation
 *  @param dismissAnimation viewcontroller dismiss animation
 */
- (void)setPortraitViewControllerPresentAnimation:(CEPortraitViewControllerPresentAnimationOption)presentAnimation
                                 DismissAnimation:(CEPortraitViewControllerDismissAnimationOption)dismissAnimation;

/**
 *  @brief set landscape splash AD present and dismiss animation with CrystalExpress bulit-in animation effect
 *
 *  @param presentAnimation viewcontroller present animation
 *  @param dismissAnimation viewcontroller dismiss animation
 */
- (void)setLandscapeViewControllerPresentAnimation:(CELandscapeViewControllerPresentAnimationOption)presentAnimation
                                  DismissAnimation:(CELandscapeViewControllerDismissAnimationOption)dismissAnimation;

/**
 *  @brief Splash AD allowed customized present/dismiss animation
 *
 *  @param presentAnimation animation object which conform to UIViewControllerAnimatedTransitioning
 *  @param dismissAnimation animation object which conform to UIViewControllerAnimatedTransitioning
 */
- (void)setCustomPortraitViewControllerPresentAnimation:(id<UIViewControllerAnimatedTransitioning>)presentAnimation
                                       DismissAnimation:(id<UIViewControllerAnimatedTransitioning>)dismissAnimation;
- (void)setCustomLandscapeViewControllerPresentAnimation:(id<UIViewControllerAnimatedTransitioning>)presentAnimation
                                        DismissAnimation:(id<UIViewControllerAnimatedTransitioning>)dismissAnimation;
@end
