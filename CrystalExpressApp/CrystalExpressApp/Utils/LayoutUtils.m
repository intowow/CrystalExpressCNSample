//
//  LayoutUtils.m
//  crystalexpress
//
//  Created by roylo on 2015/3/25.
//  Copyright (c) 2015年 intowow. All rights reserved.
//

#import "LayoutUtils.h"
#import <UIKit/UIKit.h>

@implementation LayoutUtils
+ (float)getScaleHeight:(float)oriHeight
{
    return oriHeight * (SCREEN_HEIGHT/1280.0f);
}

+ (float)getScaleWidth:(float)oriWidth
{
    return oriWidth * (SCREEN_WIDTH/720.0f);
}

+ (float)getRelatedHeightWithOriWidth:(float)oriWidth OriHeight:(float)oriHeight
{
//    return oriHeight * [self getScalingRatio];
    return (oriHeight*[self getScaleWidth:oriWidth] / oriWidth);
}

+ (CGFloat)getScalingRatio
{
    float screenWidth = MIN([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    return screenWidth/720.0f;
}

@end
