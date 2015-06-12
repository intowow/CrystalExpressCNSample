//
//  BannerADHelper.h
//  Pods
//
//  Created by roylo on 2014/10/31.
//
//

#import <Foundation/Foundation.h>

@class ADView;
@interface BannerADHelper : NSObject

- (instancetype)initWithPlacement:(NSString *)placement;
- (void)requestADonReady:(void (^)(UIView *))ready
               onFailure:(void (^)(NSError *))failure;
- (void)onStop;
- (void)onStart;
@end
