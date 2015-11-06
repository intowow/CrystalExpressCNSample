//
//  CENativeAd.h
//  Pods
//
//  Created by roylo on 2015/10/20.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class CEAdImage;
@protocol CENativeAdDelegate;

/**
 *  CENativeAd class
 */
@interface CENativeAd : NSObject

/**
 *  AD placement string
 */
@property (nonatomic, copy, readonly, nonnull) NSString *placement;

/**
 *  AD title
 */
@property (nonatomic, copy, readonly, nullable) NSString *title;

/**
 *  AD subtitle
 */
@property (nonatomic, copy, readonly, nullable) NSString *subTitle;

/**
 *  AD call to action string
 */
@property (nonatomic, copy, readonly, nullable) NSString *callToAction;

/**
 *  AD icon image
 */
@property (nonatomic, strong, readonly, nullable) CEAdImage *icon;

/**
 *  AD descripstion body string
 */
@property (nonatomic, copy, readonly, nullable) NSString *body;

/**
 *  the unique token identifier for current native AD
 */
@property (nonatomic, strong, nullable) NSString *adToken;

/**
 *  delegate that receive CENativeAd events
 */
@property (nonatomic, weak, nullable) id<CENativeAdDelegate> delegate;

/**
 *  initializer of CENativeAd
 *
 *  @param placement AD placement string
 *
 *  @return CENativeAd instance
 */
- (nonnull instancetype)initWithPlacement:(nonnull NSString *)placement NS_DESIGNATED_INITIALIZER;

/**
 *  register view for AD interaction
 *
 *  @param view           the container view for native ad
 *  @param viewController the viewcontroller that has the native ad container view
 */
- (void)registerViewForInteraction:(nonnull UIView *)view
                withViewController:(nonnull UIViewController *)viewController;

/**
 *  register clickable views for AD interaction instead of container view
 *
 *  @param view           the container view for native ad
 *  @param viewController the viewcontroller that has the native ad container view
 *  @param clickableViews the clickable views that allowed user interaction
 */
- (void)registerViewForInteraction:(nonnull UIView *)view
                withViewController:(nonnull UIViewController *)viewController
                withClickableViews:(nonnull NSArray *)clickableViews;

/**
 *  unregister previous native ad view
 */
- (void)unregisterView;

/**
 *  request native ad from CrystalExpressSDK
 */
- (void)loadAd;
@end

#pragma mark - CEAdImage
/**
 *  CEAdImage class
 */
@interface CEAdImage : NSObject

/**
 *  the url for ad image data
 */
@property (nonatomic, copy, readonly, nonnull) NSURL *url;

/**
 *  the width of image
 */
@property (nonatomic, assign, readonly) NSInteger width;

/**
 *  the height of image
 */
@property (nonatomic, assign, readonly) NSInteger height;

/**
 *  initialize CEAdImage from local file path
 *
 *  @param filePath string of local path
 *
 *  @return CEAdImage instance
 */
- (nonnull instancetype)initWithFilePath:(nonnull NSString *)filePath;

/**
 *  initialize CEAdImage from NSURL
 *
 *  @param url    url of image data
 *  @param width  image width
 *  @param height image height
 *
 *  @return CEAdImage instance
 */
- (nonnull instancetype)initWithURL:(nonnull NSURL *)url width:(NSInteger)width height:(NSInteger)height NS_DESIGNATED_INITIALIZER;

/**
 *  load image data asynchronously
 *
 *  @param block the callback block while image is loaded
 */
- (void)loadImageAsyncWithBlock:(nullable void (^)(UIImage * __nullable image))block;

@end

#pragma mark - CENativeAdDelegate
/**
 *  protocol of CENativeAdDelegate
 */
@protocol CENativeAdDelegate <NSObject>

@optional
/**
 *  callback while native ad component is loaded from CrystalExpressSDK
 *
 *  @param nativeAd CENativeAd instance that own this native ad component
 */
- (void)nativeAdDidLoad:(nonnull CENativeAd *)nativeAd;

/**
 *  callback while native ad is about to log impression
 *
 *  @param nativeAd CENativeAd instance
 */
- (void)nativeAdWillTrackImpression:(nonnull CENativeAd *)nativeAd;

/**
 *  callback while fail to load a native ad from CrystalExpressSDK
 *
 *  @param nativeAd CENativeAd instance that own this native ad component
 *  @param error    error indicates the fail reason
 */
- (void)nativeAd:(nonnull CENativeAd *)nativeAd didFailWithError:(nonnull NSError *)error;

/**
 *  callback while this native ad is clicked by user
 *
 *  @param nativeAd CENativeAd instance that own this native ad component
 */
- (void)nativeAdDidClick:(nonnull CENativeAd *)nativeAd;

/**
 *  callback while native ad finished handle click event
 *
 *  @param nativeAd CENativeAd instance that own this native ad component
 */
- (void)nativeAdDidFinishHandlingClick:(nonnull CENativeAd *)nativeAd;

@end