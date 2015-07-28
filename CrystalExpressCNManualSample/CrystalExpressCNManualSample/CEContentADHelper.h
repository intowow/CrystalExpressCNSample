//
//  CEContentADHelper.h
//  Pods
//
//  Created by roylo on 2015/7/28.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CEContentADHelper : NSObject
+ (instancetype)helperWithPlacement:(NSString *)placement
                         scrollView:(UIScrollView *)scrollView
                          contentId:(NSString *)contentId;
- (void)loadAdInView:(UIView *)wrapperView;
@end
