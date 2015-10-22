//
//  CEStreamTagADHelper.h
//  crystalexpress
//
//  Created by roylo on 2015/10/15.
//  Copyright © 2015年 intowow. All rights reserved.
//

#import "CEStreamADHelper.h"

@interface CEStreamTagADHelper : CEStreamADHelper
- (instancetype)initWithAdTag:(NSString *)adTag delegate:(id<CEStreamAdHelperDelegate>)delegate;
@end
