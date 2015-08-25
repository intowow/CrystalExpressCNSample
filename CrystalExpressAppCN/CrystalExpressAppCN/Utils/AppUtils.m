//
//  AppUtils.m
//  crystalexpress
//
//  Created by roylo on 2015/4/9.
//  Copyright (c) 2015年 intowow. All rights reserved.
//

#import "AppUtils.h"
#define TESTING         0

@implementation AppUtils
+ (NSString *)getAppVersion
{
    NSString *versionName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    if (versionName == nil) {
        return nil;
    }
    return versionName;
}

+ (NSString *)decidePlacementName:(NSString *)curPlacementName
{
    if (TESTING) {
        return [@"TEST_" stringByAppendingString:curPlacementName];
    } else {
        return curPlacementName;
    }
}
@end
