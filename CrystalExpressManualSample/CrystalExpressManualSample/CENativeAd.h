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

@interface CENativeAd : NSObject
@property (nonatomic, copy, readonly, nonnull) NSString *placement;
@property (nonatomic, copy, readonly, nullable) NSString *title;
@property (nonatomic, copy, readonly, nullable) NSString *subTitle;
@property (nonatomic, copy, readonly, nullable) NSString *callToAction;
@property (nonatomic, strong, readonly, nullable) CEAdImage *icon;
@property (nonatomic, copy, readonly, nullable) NSString *body;

@property (nonatomic, weak, nullable) id<CENativeAdDelegate> delegate;

- (nonnull instancetype)initWithPlacement:(nonnull NSString *)placement NS_DESIGNATED_INITIALIZER;
- (void)registerViewForInteraction:(nonnull UIView *)view
                withViewController:(nonnull UIViewController *)viewController;
- (void)registerViewForInteraction:(nonnull UIView *)view
                withViewController:(nonnull UIViewController *)viewController
                withClickableViews:(nonnull NSArray *)clickableViews;
- (void)unregisterView;
- (void)loadAd;
@end


@interface CEAdImage : NSObject

@property (nonatomic, copy, readonly, nonnull) NSURL *url;
@property (nonatomic, assign, readonly) NSInteger width;
@property (nonatomic, assign, readonly) NSInteger height;

- (nonnull instancetype)initWithFilePath:(nonnull NSString *)filePath;
- (nonnull instancetype)initWithURL:(nonnull NSURL *)url width:(NSInteger)width height:(NSInteger)height NS_DESIGNATED_INITIALIZER;
- (void)loadImageAsyncWithBlock:(nullable void (^)(UIImage * __nullable image))block;

@end

@protocol CENativeAdDelegate <NSObject>

@optional

- (void)nativeAdDidLoad:(nonnull CENativeAd *)nativeAd;
- (void)nativeAdWillTrackImpression:(nonnull CENativeAd *)nativeAd;
- (void)nativeAd:(nonnull CENativeAd *)nativeAd didFailWithError:(nonnull NSError *)error;
- (void)nativeAdDidClick:(nonnull CENativeAd *)nativeAd;
- (void)nativeAdDidFinishHandlingClick:(nonnull CENativeAd *)nativeAd;

@end