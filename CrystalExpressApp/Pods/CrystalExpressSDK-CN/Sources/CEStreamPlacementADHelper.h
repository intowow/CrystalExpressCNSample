//
//  CEStreamPlacementADHelper.h
//  crystalexpress
//
//  Created by roylo on 2015/10/15.
//  Copyright © 2015年 intowow. All rights reserved.
//

#import "CEStreamADHelper.h"

@interface CEStreamPlacementADHelper : CEStreamADHelper

- (instancetype)initWithPlacement:(NSString *)placement delegate:(id<CEStreamAdHelperDelegate>)delegate;
@end
