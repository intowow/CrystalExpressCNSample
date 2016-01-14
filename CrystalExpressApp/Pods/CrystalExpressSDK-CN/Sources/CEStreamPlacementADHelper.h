//
//  CEStreamPlacementADHelper.h
//  crystalexpress
//
//  Created by roylo on 2015/10/15.
//  Copyright © 2015年 intowow. All rights reserved.
//

#import "CEStreamTagADHelper.h"

@interface CEStreamPlacementADHelper : CEStreamTagADHelper

- (instancetype)initWithPlacement:(NSString *)placement delegate:(id<CEStreamAdHelperDelegate>)delegate;
@end
