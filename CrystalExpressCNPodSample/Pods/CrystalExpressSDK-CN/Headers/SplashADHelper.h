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

@protocol SplashADHelperDelegate <NSObject>
@required
- (void)SplashADDidReceiveAd:(NSArray *)ad viewController:(SplashADInterfaceViewController *)vc;
- (void)SplashADDidFailToReceiveAdWithError:(NSError *)error viewController:(SplashADInterfaceViewController *)vc;

@end

typedef NS_ENUM(NSUInteger, CESplashMode) {
    CE_SPLASH_MODE_UNKNOWN,
    CE_SPLASH_MODE_HYBRID,
    CE_SPLASH_MODE_MULTI_OFFER,
    CE_SPLASH_MODE_SINGLE_OFFER,
};

@interface SplashADHelper : NSObject
@property (nonatomic, weak) id<SplashADHelperDelegate> delegate;

- (void)requestSplashADWithPlacement:(NSString *)placement mode:(CESplashMode)splashMode;
@end
