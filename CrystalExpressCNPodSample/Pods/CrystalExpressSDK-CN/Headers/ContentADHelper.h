//
//  ContentADHelper.h
//  Pods
//
//  Created by roylo on 2015/1/5.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class ADView;

@interface ContentADHelper : NSObject
@property (nonatomic, copy) void (^onPullDownAnimation)(UIView *adView);

- (instancetype)initWithPlacement:(NSString *)placement;
- (void)preroll;
- (ADView *)requestADWithContentId:(NSString *)articleId;
- (void)setScrollOffsetWithKey:(NSString *)key offset:(int)offset;
- (void)checkAdStartWithKey:(NSString *)key ScrollViewBounds:(CGRect)bounds;
- (void)updateScrollViewBounds:(CGRect)bounds withKey:(NSString *)key;
@end
