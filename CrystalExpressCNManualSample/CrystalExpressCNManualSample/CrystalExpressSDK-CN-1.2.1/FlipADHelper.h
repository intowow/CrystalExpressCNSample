//
//  FlipADHelper.h
//  Pods
//
//  Created by roylo on 2014/10/30.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface FlipADHelper : NSObject
- (instancetype)initWithPlacement:(NSString *)placement;
- (void)setActive;
- (UIView *)requestADAtPosition:(int)position;

#pragma mark - event listener
- (void)onPageSelectedAtPositoin:(int)position;
- (void)onStop;
@end
