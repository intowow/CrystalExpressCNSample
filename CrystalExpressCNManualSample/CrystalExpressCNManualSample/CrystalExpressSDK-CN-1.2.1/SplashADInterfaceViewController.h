//
//  SplashADInterfaceViewController.h
//  Pods
//
//  Created by roylo on 2015/4/16.
//
//

#import <UIKit/UIKit.h>
@class SplashADInterfaceViewController;

@protocol SplashADViewControllerDelegate <NSObject>
@optional
- (void)SplashAdWillDismissScreen:(SplashADInterfaceViewController *)vc;
- (void)SplashAdWillPresentScreen:(SplashADInterfaceViewController *)vc;
- (void)SplashAdDidDismissScreen:(SplashADInterfaceViewController *)vc;
- (void)SplashAdDidPresentScreen:(SplashADInterfaceViewController *)vc;
@end

@interface SplashADInterfaceViewController : UIViewController
@property (nonatomic, weak) id<SplashADViewControllerDelegate> delegate;
@property (nonatomic, assign) UIInterfaceOrientationMask orientationMask;

- (void)resizeToFitSubviews:(UIView *)view;
- (void)createContentViews:(NSArray *)adViews withPlacement:(NSString *)placement;
- (void)dismissAD:(id)sender;
@end
