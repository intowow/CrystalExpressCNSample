//
//  CEContentADHelper.h
//  Pods
//
//  Created by roylo on 2015/7/28.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 *  CEContentADHelper provide an easy way to integrate Card format AD in scrollView
 */
@interface CEContentADHelper : NSObject

/**
 *  initilaize helper with AD placement name, scrollView and content identify id
 *
 *  @param placement  AD placement name
 *  @param scrollView scrollView to add content AD
 *  @param contentId  an id to identify this page
 *
 *  @return CEContentADHelper instance
 */
+ (instancetype)helperWithPlacement:(NSString *)placement
                         scrollView:(UIScrollView *)scrollView
                          contentId:(NSString *)contentId;

/**
 *  load AD and put inside wrapperView
 *  this function also update wrapperView's size if there's an AD view available
 *
 *  @param wrapperView the view to put AD
 */
- (void)loadAdInView:(UIView *)wrapperView;

/**
 *  call while view controller is present in front of user
 *  this will trigger AD to check whether it should start play
 */
- (void)onShow;

/**
 *  call while view controller is hide from user
 *  this will trigger AD to check whether it should stop play
 */
- (void)onHide;
@end
