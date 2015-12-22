//
//  FlipViewController.m
//  CrystalDemo
//
//  Created by roylo on 2014/10/1.
//  Copyright (c) 2014年 intowow. All rights reserved.
//

#import "FlipViewController.h"
#import "LayoutUtils.h"
#import "FlipDynamicADHelper.h"

#define NUM_OF_PAGES 100

@interface FlipViewController ()
@property (nonatomic, assign) int curIndex;
@property (nonatomic, strong) UIView *titleView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) FlipDynamicADHelper *flipADHelper;
@property (nonatomic, strong) NSMutableArray *dataSource;
@end

@implementation FlipViewController
- (instancetype)initWithPlacementName:(NSString *)placementName
{
    self = [super init];
    if (self) {
        _curIndex = 0;
        _flipADHelper = [[FlipDynamicADHelper alloc] initWithPlacement:placementName pageIndex:_curIndex];
        _titleView = nil;
        _scrollView = nil;
        _dataSource = [[NSMutableArray alloc] init];
        
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
    
    for (int i=0; i<NUM_OF_PAGES; i++) {
//        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(_scrollView.bounds.origin.x + i*_scrollView.bounds.size.width, _scrollView.bounds.origin.y, _scrollView.bounds.size.width, _scrollView.bounds.size.height)];
        UIView *view = [[UIView alloc] init];
        CGFloat red = arc4random() / (CGFloat)INT_MAX;
        CGFloat green = arc4random() / (CGFloat)INT_MAX;
        CGFloat blue = arc4random() / (CGFloat)INT_MAX;
        view.backgroundColor = [UIColor colorWithRed:red
                                               green:green
                                                blue:blue
                                               alpha:1.0];
        [_dataSource addObject:view];
        [_scrollView addSubview:view];
    }
   
    [self loadScrollViewWithIndex:_curIndex];
    [self loadScrollViewWithIndex:_curIndex + 1];
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
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - prepare data source
- (void)loadScrollViewWithIndex:(NSUInteger)index
{
    if (index >= [_dataSource count]) {
        return;
    }
    
    UIView *adView = [_flipADHelper requestADAtPosition:(int)index];
    if (adView != nil) {
        if ([_dataSource objectAtIndex:index] != adView) {
            [_dataSource insertObject:adView atIndex:index];
            [_scrollView setContentSize:CGSizeMake(_scrollView.contentSize.width + adView.bounds.size.width, _scrollView.contentSize.height)];
            [_scrollView addSubview:adView];
        }

        [adView setFrame:CGRectMake(_scrollView.bounds.size.width * index, 0, adView.bounds.size.width, adView.bounds.size.height)];
        [adView setCenter:CGPointMake(adView.frame.origin.x + _scrollView.bounds.size.width/2.0f, _scrollView.bounds.size.height/2.0f)];
        NSLog(@"%f, %f", adView.center.x, adView.center.y);

    } else {
        UIView *view = [_dataSource objectAtIndex:index];
        [view setFrame:CGRectMake(_scrollView.bounds.size.width * index, _scrollView.bounds.origin.y, _scrollView.bounds.size.width, _scrollView.bounds.size.height)];
    }
}


#pragma mark - scrollview delegate
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat pageWidth = CGRectGetWidth([scrollView frame]);
    NSUInteger page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    [_flipADHelper onPageSelectedAtPositoin:(int)page];

    if (_curIndex == page) {
        return;
    } else {
        _curIndex = page;
        [self loadScrollViewWithIndex:_curIndex];
        if (_curIndex > 0) {
            [self loadScrollViewWithIndex:_curIndex - 1];
        }
        [self loadScrollViewWithIndex:_curIndex + 1];
    }
    
    
}
@end
