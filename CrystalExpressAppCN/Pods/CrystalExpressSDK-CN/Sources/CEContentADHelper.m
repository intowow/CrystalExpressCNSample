//
//  CEContentADHelper.m
//  Pods
//
//  Created by roylo on 2015/7/28.
//
//

#import "CEContentADHelper.h"
#import "I2WAPI.h"
#import "CEADView.h"

#define AD_VERTICAL_MARGIN 10

#pragma mark - ContentADHolder
@interface CEContentADHolder : NSObject
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) ADView *adView;
@property (nonatomic, assign) float scrollOffset;
@property (nonatomic, assign) BOOL hadTracked;
@property (nonatomic, assign) BOOL isPlaying;
@property (nonatomic, assign) BOOL isShowing;

- (instancetype)initWithContainerView:(UIView *)containerView adView:(ADView *)adView offset:(float)offset;
@end

@implementation CEContentADHolder

- (instancetype)initWithContainerView:(UIView *)containerView adView:(ADView *)adView offset:(float)offset
{
    self = [super init];
    if (self) {
        _containerView = containerView;
        _adView = adView;
        _scrollOffset = offset;
        _hadTracked = NO;
        _isShowing = NO;
    }
    return self;
}

@end


@interface CEContentADHelper() <UIScrollViewDelegate>
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, weak) id<UIScrollViewDelegate> originalDelegate;

@property (nonatomic, strong) UIView *wrapperView;
@property (nonatomic, strong) NSString *placement;
@property (nonatomic, assign) BOOL isProcessing;
@property (nonatomic, assign) CGFloat preferAdWidth;
@property (nonatomic, strong) CEContentADHolder *adHolder;
@end

@implementation CEContentADHelper
+ (instancetype)helperWithPlacement:(NSString *)placement
                         scrollView:(UIScrollView *)scrollView
                          contentId:(NSString *)contentId
{
    return [[CEContentADHelper alloc] initWithPlacement:placement scrollView:scrollView contentId:contentId];
}

- (instancetype)initWithPlacement:(NSString *)placement
                       scrollView:(UIScrollView *)scrollView
                        contentId:(NSString *)contentId
{
    self = [super init];
    if (self) {
        _placement = placement;
        _scrollView = scrollView;
        _originalDelegate = scrollView.delegate;
        scrollView.delegate = self;
        _wrapperView = nil;
        _preferAdWidth = 300.0f;
        _adHolder = nil;
    }
    return self;
}

- (void)loadAdInView:(UIView *)wrapperView
{
    [I2WAPI setActivePlacement:_placement];
    _wrapperView = wrapperView;
    [self requestAd];
}

- (void)onShow
{
    [self handleVisibleWithScrollViewBounds:_scrollView.bounds];
    [self handleStartAndStopWithScrollViewBounds:_scrollView.bounds];
}

- (void)onHide
{
    [self handleVisibleWithScrollViewBounds:CGRectZero];
    [self handleStartAndStopWithScrollViewBounds:CGRectZero];
}


#pragma mark - private method

- (void)requestAd
{
    if (_isProcessing) {
        return;
    }
    
    _isProcessing = YES;
    
    __weak CEContentADHelper *weakSelf = self;
    [I2WAPI getContentADWithPlacement:_placement isPreroll:YES registerCallback:NO adWidth:_preferAdWidth onReady:^(ADView *adView) {
        [self onADLoaded:adView];
        _isProcessing = NO;
    } onFailure:^(NSError *error) {
        [self onADFailed:error];
        _isProcessing = NO;
    } onPullDownAnimation:^(UIView *adView) {
        [weakSelf onPullDownAnimation:adView];
    }];
}

- (void)onADLoaded:(ADView *)adView
{
    if (_wrapperView.superview == nil) {
        [_scrollView addSubview:_wrapperView];
    }
    
    // update wrapper bounds
    UIView *decorateAdView = [self decorateAdView:adView];
    [_wrapperView addSubview:decorateAdView];
    
    CGRect tmpFrame = _wrapperView.frame;
    tmpFrame.size.height = decorateAdView.bounds.size.height + 2*AD_VERTICAL_MARGIN;
    [_wrapperView setFrame:tmpFrame];
    
    float startX = (_wrapperView.bounds.size.width - decorateAdView.bounds.size.width)/2.0f;
    [decorateAdView setFrame:CGRectMake(startX, AD_VERTICAL_MARGIN, decorateAdView.bounds.size.width, decorateAdView.bounds.size.height)];
    
    BOOL showsVerticalScrollIndicator = _scrollView.showsVerticalScrollIndicator;
    BOOL showsHorizontalScrollIndicator = _scrollView.showsHorizontalScrollIndicator;
    
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;

    // update view below AD origin position
    for (UIView *childView in _scrollView.subviews) {
        if (childView == _wrapperView) {
            continue;
        }
        
        CGRect frame = childView.frame;
        if (frame.origin.y >= _wrapperView.frame.origin.y) {
            frame.origin.y += _wrapperView.bounds.size.height;
            [childView setFrame:frame];
        }
    }

    _scrollView.showsVerticalScrollIndicator = showsVerticalScrollIndicator;
    _scrollView.showsHorizontalScrollIndicator = showsHorizontalScrollIndicator;
    
    // update content size
    CGSize contentSize = _scrollView.contentSize;
    contentSize.height += _wrapperView.bounds.size.height;
    [_scrollView setContentSize:contentSize];
    
    _adHolder = [[CEContentADHolder alloc] initWithContainerView:decorateAdView adView:adView offset:_wrapperView.frame.origin.y];
}

- (void)onADFailed:(NSError *)error
{
    if (_wrapperView.superview == nil) {
        [_scrollView addSubview:_wrapperView];
    }
    
    CGRect tmpFrame = _wrapperView.frame;
    tmpFrame.size.height = 10;
    [_wrapperView setFrame:tmpFrame];
    
    BOOL showsVerticalScrollIndicator = _scrollView.showsVerticalScrollIndicator;
    BOOL showsHorizontalScrollIndicator = _scrollView.showsHorizontalScrollIndicator;
    
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;

    // update view below AD origin position
    for (UIView *childView in _scrollView.subviews) {
        if (childView == _wrapperView) {
            continue;
        }
        
        CGRect frame = childView.frame;
        if (frame.origin.y >= _wrapperView.frame.origin.y) {
            frame.origin.y += _wrapperView.bounds.size.height;
        }
        [childView setFrame:frame];
    }
   
    _scrollView.showsVerticalScrollIndicator = showsVerticalScrollIndicator;
    _scrollView.showsHorizontalScrollIndicator = showsHorizontalScrollIndicator;
    
    // update content size
    CGSize contentSize = _scrollView.contentSize;
    contentSize.height += _wrapperView.bounds.size.height;
    [_scrollView setContentSize:contentSize];
    
}

- (void)onPullDownAnimation:(UIView *)adView
{
    // update wrapper frame
    if (_adHolder) {
        CGRect frame = _adHolder.containerView.frame;
        frame.size.height = adView.bounds.size.height;
        [_adHolder.containerView setFrame:frame];
    
        frame = _wrapperView.frame;
        frame.size.height = _adHolder.containerView.frame.size.height + 2*AD_VERTICAL_MARGIN;
        [_wrapperView setFrame:frame];
    }
   
    BOOL showsVerticalScrollIndicator = _scrollView.showsVerticalScrollIndicator;
    BOOL showsHorizontalScrollIndicator = _scrollView.showsHorizontalScrollIndicator;
    
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    
    CGFloat belowAdHeight = 0.0f;
    // update view below AD origin position
    for (UIView *childView in _scrollView.subviews) {
        if (childView == _wrapperView) {
            continue;
        }

        CGRect frame = childView.frame;
        if (frame.origin.y >= _wrapperView.frame.origin.y) {
            frame.origin.y = _wrapperView.frame.origin.y + _wrapperView.bounds.size.height;
            [childView setFrame:frame];
            belowAdHeight += frame.size.height;
        }
    }

    _scrollView.showsVerticalScrollIndicator = showsVerticalScrollIndicator;
    _scrollView.showsHorizontalScrollIndicator = showsHorizontalScrollIndicator;
    
    // update content size
    CGSize contentSize = _scrollView.contentSize;
    contentSize.height = _adHolder.scrollOffset + _wrapperView.bounds.size.height + belowAdHeight;
    [_scrollView setContentSize:contentSize];
}

- (UIView *)decorateAdView:(UIView *)adView
{
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, adView.bounds.size.width, adView.bounds.size.height)];
    adView.layer.shadowColor = [[UIColor blackColor] CGColor];
    adView.layer.shadowOffset = CGSizeMake(0.0f, 0.0f); // [水平偏移, 垂直偏移]
    adView.layer.shadowOpacity = 1.0f; // 0.0 ~ 1.0 的值
    adView.layer.shadowRadius = 1.0f;
    [containerView addSubview:adView];
    [adView setTag:1];
    return containerView;
}

#pragma mark - scrollView event handling
- (void)handleVisibleWithScrollViewBounds:(CGRect)scrollViewBounds
{
    if (_adHolder) {
        CGRect adBounds = CGRectMake(0, _adHolder.scrollOffset, _adHolder.containerView.bounds.size.width, _adHolder.containerView.bounds.size.height);
        BOOL isVisible = CGRectIntersectsRect(adBounds, scrollViewBounds);
        if (isVisible == YES && _adHolder.isShowing == NO) {
            [_adHolder.adView onShow];
            _adHolder.isShowing = YES;
        } else if (isVisible == NO && _adHolder.isShowing == YES) {
            [_adHolder.adView onHide];
            _adHolder.isShowing = NO;
        }
        
        if (_adHolder.hadTracked == YES) {
            return;
        }
       
        CGFloat viewOffset = scrollViewBounds.origin.y + scrollViewBounds.size.height;
        if (viewOffset >= _adHolder.scrollOffset) {
            [I2WAPI trackAdRequestWithPlacement:_placement];
            _adHolder.hadTracked = YES;
        }
    }
}

- (void)handleStartAndStopWithScrollViewBounds:(CGRect)scrollViewBounds
{
    if (_adHolder) {
        CGRect adBounds = CGRectMake(0, _adHolder.scrollOffset, _adHolder.containerView.bounds.size.width, _adHolder.containerView.bounds.size.height);
        BOOL isVisible = CGRectIntersectsRect(adBounds, scrollViewBounds);
        if (isVisible == YES && _adHolder.isPlaying == NO) {
            [_adHolder.adView onStart];
            _adHolder.isPlaying = YES;
        } else if (isVisible == NO && _adHolder.isPlaying == YES) {
            [_adHolder.adView onStop];
            _adHolder.isPlaying = NO;
        }
    }
}

#pragma mark - <UIScrollViewDelegate>
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self handleVisibleWithScrollViewBounds:scrollView.bounds];
    
    id<UIScrollViewDelegate> delegate = self.originalDelegate;
    if ([delegate respondsToSelector:@selector(scrollViewDidScroll:)]) {
        return [delegate scrollViewDidScroll:scrollView];
    }
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    id<UIScrollViewDelegate> delegate = self.originalDelegate;
    if ([delegate respondsToSelector:@selector(scrollViewDidZoom:)]) {
        return [delegate scrollViewDidZoom:scrollView];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    id<UIScrollViewDelegate> delegate = self.originalDelegate;
    if ([delegate respondsToSelector:@selector(scrollViewWillBeginDragging:)]) {
        return [delegate scrollViewWillBeginDragging:scrollView];
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    id<UIScrollViewDelegate> delegate = self.originalDelegate;
    if ([delegate respondsToSelector:@selector(scrollViewWillEndDragging:withVelocity:targetContentOffset:)]) {
        return [delegate scrollViewWillEndDragging:scrollView withVelocity:velocity targetContentOffset:targetContentOffset];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (decelerate == NO) {
        [self handleStartAndStopWithScrollViewBounds:scrollView.bounds];
    }
    
    id<UIScrollViewDelegate> delegate = self.originalDelegate;
    if ([delegate respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)]) {
        return [delegate scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    id<UIScrollViewDelegate> delegate = self.originalDelegate;
    if ([delegate respondsToSelector:@selector(scrollViewWillBeginDecelerating:)]) {
        return [delegate scrollViewWillBeginDecelerating:scrollView];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self handleStartAndStopWithScrollViewBounds:scrollView.bounds];
    
    id<UIScrollViewDelegate> delegate = self.originalDelegate;
    if ([delegate respondsToSelector:@selector(scrollViewDidEndDecelerating:)]) {
        return [delegate scrollViewDidEndDecelerating:scrollView];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    id<UIScrollViewDelegate> delegate = self.originalDelegate;
    if ([delegate respondsToSelector:@selector(scrollViewDidEndScrollingAnimation:)]) {
        return [delegate scrollViewDidEndScrollingAnimation:scrollView];
    }
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    id<UIScrollViewDelegate> delegate = self.originalDelegate;
    if ([delegate respondsToSelector:@selector(viewForZoomingInScrollView:)]) {
        return [delegate viewForZoomingInScrollView:scrollView];
    }
    return nil;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view
{
    id<UIScrollViewDelegate> delegate = self.originalDelegate;
    if ([delegate respondsToSelector:@selector(scrollViewWillBeginZooming:withView:)]) {
        return [delegate scrollViewWillBeginZooming:scrollView withView:view];
    }
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    id<UIScrollViewDelegate> delegate = self.originalDelegate;
    if ([delegate respondsToSelector:@selector(scrollViewDidEndZooming:withView:atScale:)]) {
        return [delegate scrollViewDidEndZooming:scrollView withView:view atScale:scale];
    }
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView
{
    id<UIScrollViewDelegate> delegate = self.originalDelegate;
    if ([delegate respondsToSelector:@selector(scrollViewShouldScrollToTop:)]) {
        return [delegate scrollViewShouldScrollToTop:scrollView];
    }
    return YES;
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView
{
    id<UIScrollViewDelegate> delegate = self.originalDelegate;
    if ([delegate respondsToSelector:@selector(scrollViewDidScrollToTop:)]) {
        return [delegate scrollViewDidScrollToTop:scrollView];
    }
}
@end
