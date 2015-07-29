//
//  DemoDetailContentViewController.m
//  crystalexpress
//
//  Created by roylo on 2015/3/28.
//  Copyright (c) 2015年 intowow. All rights reserved.
//

#import "DemoDetailContentViewController.h"
#import "LayoutUtils.h"
#import "DemoContentViewController.h"
#import "DemoFlipADViewController.h"
#import "ContentADHelper.h"
#import "FlipDynamicADHelper.h"
#import "AppUtils.h"

#define NUM_OF_PAGES 300

@interface DemoDetailContentViewController () <UIScrollViewDelegate>
@property (nonatomic, strong) UIView *titleView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, assign) NSUInteger curIndex;
@property (nonatomic, strong) NSMutableArray *articleVCPool;
@property (nonatomic, strong) NSMutableArray *contentVCs;
@property (nonatomic, strong) ContentADHelper *articleADHelper;
@property (nonatomic, strong) FlipDynamicADHelper *flipADHelper;
@property (nonatomic, strong) DemoFlipADViewController *flipADVC;
@end

@implementation DemoDetailContentViewController

- (instancetype)initWithIndex:(NSUInteger)index
{
    self = [super init];
    if (self) {
        _curIndex = index;
        _articleVCPool = [[NSMutableArray alloc] init];
        _contentVCs = [[NSMutableArray alloc] init];
        _flipADHelper = [[FlipDynamicADHelper alloc] initWithPlacement:[AppUtils decidePlacementName:@"FLIP"] pageIndex:_curIndex];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[self view] setBackgroundColor:[UIColor whiteColor]];
    
    _titleView = [self createTitleView];
    [[self view] addSubview:_titleView];
    
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, _titleView.bounds.size.height, self.view.bounds.size.width, self.view.bounds.size.height - _titleView.bounds.size.height)];
    
    [_scrollView setDelegate:self];
    [_scrollView setContentSize:CGSizeMake(self.view.bounds.size.width * NUM_OF_PAGES, _scrollView.bounds.size.height)];
    [_scrollView setPagingEnabled:YES];
    [_scrollView setShowsHorizontalScrollIndicator:NO];
    [[self view] addSubview:_scrollView];
    
    if (_curIndex > 0) {
        for (int i=0; i<_curIndex; i++) {
            [_contentVCs addObject:[NSNull null]];
        }
        
        [_scrollView setContentOffset:CGPointMake(self.view.bounds.size.width * _curIndex, 0)];
    }
    
    [self loadScrollViewWithIndex:_curIndex];
    if (_curIndex > 0) {
        [self loadScrollViewWithIndex:_curIndex-1];
    }
    [self loadScrollViewWithIndex:_curIndex+1];
    
    [_flipADHelper setActive];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_flipADHelper onPageSelectedAtPositoin:(int)_curIndex];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [_flipADHelper onPageSelectedAtPositoin:-1];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

#pragma mark - private method
- (CGFloat)getStatusBarHeight
{
    CGSize statusBarSize = [[UIApplication sharedApplication] statusBarFrame].size;
    return MAX(MIN(statusBarSize.width, statusBarSize.height), 20);
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark - private method - create view
- (UIView *)createTitleView
{
    // create title bar
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, [LayoutUtils getRelatedHeightWithOriWidth:720 OriHeight:90] + [self getStatusBarHeight])];
    [titleView setBackgroundColor:[UIColor colorWithRed:234.0f/255 green:90.0f/255 blue:49.0f/255 alpha:1.0]];
    UIImage *titleImg = [UIImage imageNamed:@"asset.bundle/article_topbar.jpg"];
    UIImageView *titleImgView = [[UIImageView alloc] initWithImage:titleImg];
    [titleImgView setFrame:CGRectMake(0, [self getStatusBarHeight], self.view.bounds.size.width, [LayoutUtils getRelatedHeightWithOriWidth:720 OriHeight:90])];
    [titleView addSubview:titleImgView];
    
    // back button
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, titleView.bounds.size.height - [LayoutUtils getRelatedHeightWithOriWidth:90 OriHeight:90], [LayoutUtils getScaleWidth:90], [LayoutUtils getRelatedHeightWithOriWidth:90 OriHeight:90])];
    [backBtn setBackgroundImage:[UIImage imageNamed:@"asset.bundle/back_nm.png"] forState:UIControlStateNormal];
    [backBtn setBackgroundImage:[UIImage imageNamed:@"asset.bundle/back_at.png"] forState:UIControlStateHighlighted];
    [backBtn addTarget:self action:@selector(pressBackBtn:) forControlEvents:UIControlEventTouchUpInside];
    [titleView addSubview:backBtn];
    
    // seperate line
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.backgroundColor = [UIColor colorWithWhite:0.8235 alpha:1.0].CGColor;
    bottomBorder.frame = CGRectMake(0, titleView.bounds.size.height, self.view.bounds.size.width, [LayoutUtils getScaleHeight:2]);
    [titleView.layer addSublayer:bottomBorder];
    
    
    return titleView;
}

- (void)pressBackBtn:(id)sender
{
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        [_delegate requestInterstitialSplashAD];
    }];
    
    [self.navigationController popViewControllerAnimated:YES];
    
    [CATransaction commit];
}

#pragma mark - prepare data source
- (void)loadScrollViewWithIndex:(NSUInteger)index
{
    if (index < [_contentVCs count] && [_contentVCs objectAtIndex:index] != [NSNull null]) {
        return;
    }
    
    UIView *adView = [_flipADHelper requestADAtPosition:(int)index];
    if (adView != nil) {
        DemoFlipADViewController *flipADVC = [self dequeueReusableFlipADViewController];
        NSUInteger prevIndex = [_contentVCs indexOfObject:flipADVC];
        
        if (prevIndex != NSNotFound) {
            [_contentVCs replaceObjectAtIndex:prevIndex withObject:[NSNull null]];
        }
        
        [[flipADVC view] setFrame:CGRectMake(_scrollView.bounds.size.width * index, 0, _scrollView.bounds.size.width, _scrollView.bounds.size.height)];
        [flipADVC setFlipAD:adView];
        
        if (index >= [_contentVCs count]) {
            [_contentVCs addObject:flipADVC];
        } else {
            [_contentVCs insertObject:flipADVC atIndex:index];
        }
        
        [_scrollView setContentSize:CGSizeMake(_scrollView.contentSize.width + [flipADVC view].bounds.size.width, _scrollView.contentSize.height)];
        
    } else {
        DemoContentViewController *articleVC = [self dequeueReusableContentViewController];
        NSUInteger prevIndex = [_contentVCs indexOfObject:articleVC];
        
        if (prevIndex != NSNotFound) {
            [_contentVCs replaceObjectAtIndex:prevIndex withObject:[NSNull null]];
        }
        
        CGRect frame = [_scrollView frame];
        frame.origin.x = CGRectGetWidth(frame) * index;
        frame.origin.y = 0;
        [articleVC.view setFrame:frame];
        [articleVC loadContentWithId:[NSString stringWithFormat:@"%lu", (unsigned long)index]];
        
        if (index >= [_contentVCs count]) {
            [_contentVCs addObject:articleVC];
        } else {
            [_contentVCs replaceObjectAtIndex:index withObject:articleVC];
        }
    }
}

- (DemoContentViewController *) dequeueReusableContentViewController
{
    for (DemoContentViewController *artiVC in _articleVCPool) {
        if ([self isViewControllerVisable:artiVC] == NO) {
            [[[artiVC view] subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
            return artiVC;
        }
    }
    
    DemoContentViewController *newContentVC = [[DemoContentViewController alloc] init];
    [_articleVCPool addObject:newContentVC];
    [self addChildViewController:newContentVC];
    [_scrollView addSubview:[newContentVC view]];
    
    [newContentVC didMoveToParentViewController:self];
    return newContentVC;
}

- (DemoFlipADViewController *) dequeueReusableFlipADViewController
{
    if (_flipADVC) {
        [[[_flipADVC view] subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    } else {
        _flipADVC = [[DemoFlipADViewController alloc] init];
        [self addChildViewController:_flipADVC];
        [_flipADVC didMoveToParentViewController:self];
        [_scrollView addSubview:[_flipADVC view]];
    }
    return _flipADVC;
}

- (BOOL)isViewControllerVisable:(UIViewController *)vc
{
    CGRect visableArea = _scrollView.bounds;
    visableArea.origin.x -= _scrollView.bounds.size.width;
    visableArea.size.width += 2 * _scrollView.bounds.size.width;
    return CGRectIntersectsRect(vc.view.frame, visableArea);
}

#pragma mark - scrollview delegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat pageWidth = CGRectGetWidth([scrollView frame]);
    NSUInteger page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    [_flipADHelper onPageSelectedAtPositoin:(int)page];
    
    if (_curIndex == page) {
        return;
    } else {
        if ([_contentVCs objectAtIndex:_curIndex] != [NSNull null]) {
            [[_contentVCs objectAtIndex:_curIndex] viewDidDisappear:YES];
        }
        
        _curIndex = page;
        
        [self loadScrollViewWithIndex:_curIndex];
        if (_curIndex > 0) {
            [self loadScrollViewWithIndex:_curIndex - 1];
        }
        [self loadScrollViewWithIndex:_curIndex + 1];
        
        if ([_contentVCs objectAtIndex:_curIndex] != [NSNull null]) {
            [[_contentVCs objectAtIndex:_curIndex] viewDidAppear:YES];
        }
    }
    
    
}
@end
