//
//  CEMediaView.h
//  Pods
//
//  Created by roylo on 2015/10/20.
//
//

#import <UIKit/UIKit.h>
#import "CENativeAd.h"

@protocol CEMediaViewDelegate;

@interface CEMediaView : UIView

@property (nonatomic, weak, nullable) id<CEMediaViewDelegate> delegate;
@property (nonatomic, strong, nonnull) CENativeAd *nativeAd;
@property (nonatomic, assign, getter=isAutoplayEnabled) BOOL autoplayEnabled;

- (nonnull instancetype)initWithNativeAd:(nonnull CENativeAd *)nativeAd;

- (void)destroy;
- (void)play;
- (void)stop;
- (void)mute;
- (void)unmute;

@end


@protocol CEMediaViewDelegate <NSObject>

@optional
- (void)mediaViewDidLoad:(nonnull CEMediaView *)mediaView;

@end