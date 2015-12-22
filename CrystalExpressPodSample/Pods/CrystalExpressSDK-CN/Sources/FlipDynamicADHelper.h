//
//  FlipDynamicADHelper.h
//  Pods
//
//  Created by roylo on 2015/3/30.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface FlipDynamicADHelper : NSObject
- (instancetype)initWithPlacement:(NSString *)placement
                        pageIndex:(NSUInteger)pageIndex;

- (void)setActive;
- (UIView *)requestADAtPosition:(int)position;

#pragma mark - event listener
- (void)onPageSelectedAtPositoin:(int)position;
@end