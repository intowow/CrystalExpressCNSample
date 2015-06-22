//
//  DemoStreamSectionViewController.m
//  crystalexpress
//
//  Created by roylo on 2015/3/26.
//  Copyright (c) 2015年 intowow. All rights reserved.
//

#import "DemoStreamSectionViewController.h"
#import "LayoutUtils.h"
#import "DemoStreamTableViewController.h"
#import "StreamADHelper.h"
#import "SplashADHelper.h"
#import "SplashADInterfaceViewController.h"
#import "I2WAPI.h"
#import "AppDelegate.h"
#import "AppUtils.h"

@interface DemoStreamSectionViewController () <UIScrollViewDelegate, SplashADHelperDelegate, SplashADViewControllerDelegate>
@property (nonatomic, strong) NSArray *menuTitles;
@property (nonatomic, strong) DemoSectionMenuScrollView *menuView;
@property (nonatomic, strong) UIScrollView *contentView;
@property (nonatomic, strong) NSMutableArray *streamVCs;
@property (nonatomic, strong) NSMutableArray *streamADHelpers;
@property (nonatomic, strong) SplashADHelper *interstitialSplashHelper;
@property (nonatomic, assign) NSUInteger curIndex;

// splash ad view controller
@property (nonatomic, assign) long long splashLastViewTime;
@property (nonatomic, strong) UIViewController *splashVC;
@end

@implementation DemoStreamSectionViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        _streamVCs = [[NSMutableArray alloc] init];
        _streamADHelpers = [[NSMutableArray alloc] init];
        _curIndex = 0;
        _splashLastViewTime = [[NSDate date] timeIntervalSince1970] * 1000L;
        _splashVC = nil;
        _interstitialSplashHelper = [[SplashADHelper alloc] init];
        [_interstitialSplashHelper setDelegate:self];
    }
    return self;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[self view] setBackgroundColor:[UIColor colorWithWhite:0.906 alpha:1.0]];
    [self setNeedsStatusBarAppearanceUpdate];
    
    // create title bar
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, [LayoutUtils getRelatedHeightWithOriWidth:720 OriHeight:90] + [self getStatusBarHeight])];
    [titleView setBackgroundColor:[UIColor colorWithRed:234.0f/255 green:90.0f/255 blue:49.0f/255 alpha:1.0]];
    UIImage *streamLogoImg = [UIImage imageNamed:@"asset.bundle/stream_topbar.jpg"];
    UIImageView *streamLogoImgView = [[UIImageView alloc] initWithImage:streamLogoImg];
    [streamLogoImgView setFrame:CGRectMake(0, [self getStatusBarHeight], SCREEN_WIDTH, [LayoutUtils getRelatedHeightWithOriWidth:720 OriHeight:90])];
    [titleView addSubview:streamLogoImgView];
    [[self view] addSubview:titleView];
    
    // create menu bar
    _menuView = [[DemoSectionMenuScrollView alloc] initWithFrame:CGRectMake(0, titleView.bounds.size.height, SCREEN_WIDTH, [LayoutUtils getRelatedHeightWithOriWidth:720 OriHeight:90])];
    _menuTitles = [NSArray arrayWithObjects:@"News", @"Sport", @"Business", @"Earth", @"Future", nil];
    [_menuView createMenuItemsWithTitles:_menuTitles];
    [_menuView setDelegate:self];
    [[self view] addSubview:_menuView];
    
    // content swipe view
    _contentView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, titleView.bounds.size.height + _menuView.bounds.size.height, SCREEN_WIDTH, SCREEN_HEIGHT - titleView.bounds.size.height - _menuView.bounds.size.height)];
    [_contentView setDelegate:self];
    [_contentView setContentSize:CGSizeMake(SCREEN_WIDTH * [_menuTitles count], _contentView.bounds.size.height)];
    [_contentView setPagingEnabled:YES];
    [_contentView setShowsHorizontalScrollIndicator:NO];
    [_contentView setShowsVerticalScrollIndicator:NO];
    [[self view] addSubview:_contentView];
   
    for (int i=0; i<[_menuTitles count]; i++) {
        [_streamVCs addObject:[NSNull null]];
    }
    
    [self loadScrollViewWithIndex:_curIndex - 1];
    [self loadScrollViewWithIndex:_curIndex];
    [self loadScrollViewWithIndex:_curIndex + 1];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[[_streamVCs objectAtIndex:_curIndex] streamHelper] setActive:NO];
    [[[_streamVCs objectAtIndex:_curIndex] streamHelper] scrollViewStateChanged];
}

- (void)viewWillAppear:(BOOL)animated
{
    [[[_streamVCs objectAtIndex:_curIndex] streamHelper] setActive:YES];
    [[[_streamVCs objectAtIndex:_curIndex] streamHelper] scrollViewStateChanged];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - private method
- (CGFloat)getStatusBarHeight
{
    CGSize statusBarSize = [[UIApplication sharedApplication] statusBarFrame].size;
    return MAX(MIN(statusBarSize.width, statusBarSize.height), 20);
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

#pragma mark - prepare data source
- (void)loadScrollViewWithIndex:(NSUInteger)index
{
    if (index >= [_menuTitles count]) {
        return;
    }
    
    DemoStreamTableViewController *vc = [_streamVCs objectAtIndex:index];
    if ((NSNull *)vc == [NSNull null]) {
        StreamADHelper *newStreamHelper = [[StreamADHelper alloc] initWithPlacement:[AppUtils decidePlacementName:@"STREAM_118"]];
        vc = [[DemoStreamTableViewController alloc] init];
        [vc setDelegate:self];
        
        NSString *menuTitle = [_menuTitles objectAtIndex:index];
        [vc setSectionName:[menuTitle lowercaseString]];
        [vc setStreamHelper:newStreamHelper];
        if (index == _curIndex) {
            [newStreamHelper setActive:YES];
        }
        
        CGRect frame = [_contentView frame];
        frame.origin.x = CGRectGetWidth(frame) * index;
        frame.origin.y = 0;
        frame.size.width = frame.size.width;
        frame.size.height = frame.size.height;
        [vc.view setFrame:frame];
        [_streamVCs replaceObjectAtIndex:index withObject:vc];
    }
    
    if ([vc.view superview] == nil) {
        [self addChildViewController:vc];
        [_contentView addSubview:[vc view]];
        [vc didMoveToParentViewController:self];
    }
}

#pragma mark - scroll view delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([scrollView isKindOfClass:[DemoSectionMenuScrollView class]]) {
    
    } else {
        CGFloat pageWidth = CGRectGetWidth([_contentView frame]);
        CGFloat curItemOffset = (_contentView.contentOffset.x / pageWidth);
        [_menuView scrollTo:curItemOffset WithAnimation:YES];

        NSUInteger page = floor((_contentView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
        if (page != _curIndex) {
            [self scrollViewCurrentItemIndexDidChange:page];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if ([scrollView isKindOfClass:[DemoSectionMenuScrollView class]]) {
    
    } else {
        CGFloat pageWidth = CGRectGetWidth([_contentView frame]);
        NSUInteger page = floor((_contentView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
        if (_curIndex == page) {
            return;
        } else {
            [[[_streamVCs objectAtIndex:_curIndex] streamHelper] setActive:NO];
            [[[_streamVCs objectAtIndex:_curIndex] streamHelper] scrollViewStateChanged];

            _curIndex = (NSUInteger)page;
//            [self requestSplashAD];

            [[[_streamVCs objectAtIndex:_curIndex] streamHelper] setActive:YES];
            [[[_streamVCs objectAtIndex:_curIndex] streamHelper] scrollViewStateChanged];
        }
//
        [self loadScrollViewWithIndex:_curIndex - 1];
        [self loadScrollViewWithIndex:_curIndex];
        [self loadScrollViewWithIndex:_curIndex + 1];
    }
    
}

- (void)scrollViewCurrentItemIndexDidChange:(NSUInteger)newIndex
{
    [_menuView updateHighlightBtnWithIndex:newIndex];
}

#pragma mark - DemoSectionMenuDelegate
- (void)selectItemAt:(NSUInteger)index
{
    NSUInteger previousIndex = _curIndex;
    _curIndex = index;
//    [self requestSplashAD];
    
    [self loadScrollViewWithIndex:_curIndex - 1];
    [self loadScrollViewWithIndex:_curIndex];
    [self loadScrollViewWithIndex:_curIndex + 1];
    [_contentView setContentOffset:CGPointMake(index * SCREEN_WIDTH, 0)];
    
    if (previousIndex != _curIndex) {
        [[[_streamVCs objectAtIndex:previousIndex] streamHelper] setActive:NO];
        [[[_streamVCs objectAtIndex:previousIndex] streamHelper] scrollViewStateChanged];
        
        [[[_streamVCs objectAtIndex:_curIndex] streamHelper] setActive:YES];
        [[[_streamVCs objectAtIndex:_curIndex] streamHelper] scrollViewStateChanged];
    }
}

#pragma mark - private method - splash 
- (void)requestInterstitialSplashAD
{
    [_interstitialSplashHelper requestSplashADWithPlacement:[AppUtils decidePlacementName:@"SPLASH"] mode:CE_SPLASH_MODE_SINGLE_OFFER];
}

//- (void)requestSplashAD
//{
//    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
//    long long now = [[NSDate date] timeIntervalSince1970] * 1000L;
//    long long splashDuration = now - _splashLastViewTime;
//    long long openSplashDuration = now - [appDelegate getOpenSplashLastViewTime];
//    if ([appDelegate shouldRequestOpenSplash] == NO && splashDuration > [appDelegate getSectionSplashGuardTime] && openSplashDuration > [appDelegate getSectionSplashGuardTime]) {
//        [_sectionSplashHelper requestSplashADWithPlacement:[AppUtils decidePlacementName:@"SPLASH"] mode:CE_SPLASH_MODE_SINGLE_OFFER];
//    }
//}

#pragma mark - SplashADHelperDelegate
- (void)SplashADDidReceiveAd:(NSArray *)ad viewController:(SplashADInterfaceViewController *)vc
{
    _splashVC = vc;
    [vc setDelegate:self];
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)SplashADDidFailToReceiveAdWithError:(NSError *)error viewController:(SplashADInterfaceViewController *)vc
{
}

#pragma mark - SplashADViewControllerDelegate
- (void)SplashAdWillDismissScreen:(SplashADInterfaceViewController *)vc
{
    _splashLastViewTime = [[NSDate date] timeIntervalSince1970] * 1000L;
}

- (void)SplashAdWillPresentScreen:(SplashADInterfaceViewController *)vc
{
    
}

- (void)SplashAdDidDismissScreen:(SplashADInterfaceViewController *)vc
{
    _splashVC = nil;
}

- (void)SplashAdDidPresentScreen:(SplashADInterfaceViewController *)vc
{
    
}
@end
