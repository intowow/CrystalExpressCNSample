//
//  CEMediaView.h
//  Pods
//
//  Created by roylo on 2015/10/20.
//
//

#import <UIKit/UIKit.h>
#import "CENativeAd.h"

/**
 *  MediaViewDelegate
 */
@protocol CEMediaViewDelegate;

/**
 *  @abstract CEMediaView class, native AD main media view
 */
@interface CEMediaView : UIView

/**
 *  the delegate that receive MediaView event
 */
@property (nonatomic, weak, nullable) id<CEMediaViewDelegate> delegate;

/**
 *  the native AD instance that provide the AD component
 */
@property (nonatomic, strong, nonnull) CENativeAd *nativeAd;

/**
 *  whether to start AD play automatically
 */
@property (nonatomic, assign, getter=isAutoplayEnabled) BOOL autoplayEnabled;

/**
 *  initializer function
 *
 *  @param nativeAd CENativeAd instance that can provide ad component
 *
 *  @return instance of CEMediaView
 */
- (nonnull instancetype)initWithNativeAd:(nonnull CENativeAd *)nativeAd;

/**
 *  destroy the cache ad in media view
 */
- (void)destroy;

/**
 *  start the video ad play
 */
- (void)play;

/**
 *  stop the video ad play
 */
- (void)stop;

/**
 *  mute the video
 */
- (void)mute;

/**
 *  unmute the video
 */
- (void)unmute;

@end

/**
 *  CEMediaViewDelegate
 */
@protocol CEMediaViewDelegate <NSObject>

@optional
/**
 *  Callback while media view is loaded successfully
 *
 *  @param mediaView media view
 */
- (void)mediaViewDidLoad:(nonnull CEMediaView *)mediaView;

@end