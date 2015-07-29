//
//  SplashADInterfaceViewController.h
//  Pods
//
//  Created by roylo on 2015/4/16.
//
//

#import <UIKit/UIKit.h>
@class SplashADInterfaceViewController;
/**
 *  @brief SplashADViewController Delegate
 */
@protocol SplashADViewControllerDelegate <NSObject>
- (void)dismissAnimated:(BOOL)animated;
@end

/**
 *  Splash AD interfaceViewController
 */
@interface SplashADInterfaceViewController : UIViewController
/// the delegate conform SplashADViewControllerDelegate
@property (nonatomic, weak) id<SplashADViewControllerDelegate> delegate;
/// the orientationMask for this viewController
@property (nonatomic, assign) UIInterfaceOrientationMask orientationMask;

/**
 *  @brief resize the superView for its subviews
 *
 *  @param view UIView
 */
- (void)resizeToFitSubviews:(UIView *)view;

/**
 *  @brief create content view for adViews and placmenet string
 *
 *  @param adViews   ADViews
 *  @param placement placement string
 */
- (void)createContentViews:(NSArray *)adViews withPlacement:(NSString *)placement;

/**
 *  @brief dismiss this viewController
 *
 *  @param sender sender for this dismiss event
 */
- (void)dismissAD:(id)sender;

- (void)setPortraitViewControllerPresentAnimation:(id<UIViewControllerAnimatedTransitioning>)portraitPresent;
- (void)setPortraitViewControllerDismissAnimation:(id<UIViewControllerAnimatedTransitioning>)portraitDismiss;
- (void)setLandscapeViewControllerPresentAnimation:(id<UIViewControllerAnimatedTransitioning>)landscapePresent;
- (void)setLandscapeViewControllerDismissAnimation:(id<UIViewControllerAnimatedTransitioning>)landscapeDismiss;
@end
