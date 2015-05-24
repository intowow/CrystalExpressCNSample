//
//  InterstitialADViewController.h
//  Pods
//
//  Created by roylo on 2014/10/16.
//
//

#import <UIKit/UIKit.h>

#define CPD_GROUP @"CPD"
#define MULTI_OFFER_1 @"MULTI_OFFER_1"
#define MULTI_OFFER_2 @"MULTI_OFFER_2"
#define MULTI_OFFER_3 @"MULTI_OFFER_3"
#define MULTI_OFFER_4 @"MULTI_OFFER_4"
#define SECTION_SPLASH @"SECTION_SPLASH"

@class ADDispatcher, ADView, InterstitialADViewController;

@protocol InterstitialADViewControllerDelegate <NSObject>
@required
- (void)CrystalExpressInterstitialAdDidReceiveAd:(NSArray *)ad viewController:(InterstitialADViewController *)vc;
- (void)CrystalExpressInterstitialDidFailToReceiveAdWithError:(NSError *)error viewController:(InterstitialADViewController *)vc;

@optional
- (void)CrystalExpressInterstitialAdWillDismissScreen:(InterstitialADViewController *)vc;
- (void)CrystalExpressInterstitialAdWillPresentScreen:(InterstitialADViewController *)vc;
- (void)CrystalExpressInterstitialAdDidDismissScreen:(InterstitialADViewController *)vc;
- (void)CrystalExpressInterstitialAdDidPresentScreen:(InterstitialADViewController *)vc;
@end

@interface InterstitialADViewController : UIViewController
@property (nonatomic, weak) id<InterstitialADViewControllerDelegate> delegate;
@property (nonatomic, strong) ADDispatcher *dispatcher;
@property (nonatomic, strong) ADView *currentADView;
@property (nonatomic, assign) UIInterfaceOrientationMask orientationMask;

- (instancetype)initWithADDispatcher:(ADDispatcher *)dispatcher;
- (void)resizeToFitSubviews:(UIView *)view;
- (void)loadADWithPlacement:(NSString *)placement;
@end
