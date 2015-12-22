//
//  CECardADHelper.h
//  crystalexpress
//
//  Created by roylo on 2015/8/11.
//  Copyright (c) 2015年 intowow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CEADView.h"

@interface CECardADHelper : NSObject
- (instancetype)initWithPlacement:(NSString *)placement;

- (void)requestADonReady:(void (^)(ADView *))ready
               onFailure:(void (^)(NSError *))failure;

- (void)requestADWithAdWidth:(CGFloat)adWidth
                     onReady:(void (^)(ADView *))ready
                   onFailure:(void (^)(NSError *))failure;
@end
