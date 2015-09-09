//
//  CEADView.h
//  crystalexpress
//
//  Created by roylo on 2015/8/11.
//  Copyright (c) 2015年 intowow. All rights reserved.
//

#ifndef crystalexpress_CEADView_h
#define crystalexpress_CEADView_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ADView : UIView
/**
 *  call onShow while ADView is seen by user
 */
- (void)onShow;

/**
 *  call onHide while ADView is hide from user
 */
- (void)onHide;

/**
 *  call onStart to trigger ADView impression and video play
 */
- (void)onStart;

/**
 *  call onStop to stop ADView video play
 */
- (void)onStop;

@end
#endif
