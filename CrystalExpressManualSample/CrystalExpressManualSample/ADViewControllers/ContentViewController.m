//
//  ContentViewController.m
//  CrystalExpressDemo
//
//  Created by roylo on 2015/2/10.
//  Copyright (c) 2015年 intowow. All rights reserved.
//

#import "ContentViewController.h"
#import "LayoutUtils.h"
#import "CEContentADHelper.h"

@interface ContentViewController() <UIScrollViewDelegate>
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) CEContentADHelper *contentADHelper;
@property (nonatomic, strong) UIView *contentADView;
@property (nonatomic, strong) UIView *adWrapperView;
@property (nonatomic, assign) float adOffset;
@property (nonatomic, strong) UIImageView *relatedImgView;
@property (nonatomic, strong) UIView *titleView;
@property (nonatomic, strong) NSString *contentId;

@end

@implementation ContentViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        _contentADView = nil;
        _adWrapperView = nil;
        _adOffset = -1;
        _relatedImgView = nil;
        [self loadContentWithId:@"1"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    _titleView = [self createTitleView];
    [[self view] addSubview:_titleView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_contentADHelper onShow];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [_contentADHelper onHide];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - public method
- (void)loadContentWithId:(NSString *)contentId
{
    _contentId = contentId;
    _scrollView = [[UIScrollView alloc] init];
    [_scrollView setDelegate:self];
    [[self view] addSubview:_scrollView];
    
    CGFloat scrollHeight = 0;
    
    [_scrollView setFrame:CGRectMake(0, _titleView.bounds.size.height, self.view.bounds.size.width, self.view.bounds.size.height - _titleView.bounds.size.height)];
    
    // article top
    UIImage *articleTop = [UIImage imageNamed:[NSString stringWithFormat:@"asset.bundle/article_%d.jpg", [contentId intValue]]];
    
    UIImageView *articleTopView = [[UIImageView alloc] initWithImage:articleTop];
    [articleTopView setFrame:CGRectMake(0, 0, self.view.bounds.size.width, [LayoutUtils getRelatedHeightWithOriWidth:articleTop.size.width OriHeight:articleTop.size.height])];
    [_scrollView addSubview:articleTopView];
    scrollHeight += articleTopView.bounds.size.height;
    
    // text
    NSString *articleTextFilePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"asset.bundle/article_%d", [contentId intValue]] ofType:@"txt"];
    NSString *articleText = [NSString stringWithContentsOfFile:articleTextFilePath encoding:NSUTF8StringEncoding error:nil];
    
    
    UIView *textContainer = [[UIView alloc] init];
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake([LayoutUtils getScaleWidth:30], [LayoutUtils getRelatedHeightWithOriWidth:720 OriHeight:60], [LayoutUtils getScaleWidth:660], 0)];
    textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    textLabel.numberOfLines = 0;
    textLabel.text = articleText;
    textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:[LayoutUtils getScaleWidth:30]];
    textLabel.textColor = [UIColor colorWithWhite:146.0f/255 alpha:1.0];
    [textLabel sizeToFit];
    [textContainer setFrame:CGRectMake(0, articleTopView.bounds.size.height, self.view.bounds.size.width, [LayoutUtils getRelatedHeightWithOriWidth:720 OriHeight:60] + textLabel.bounds.size.height)];
    [textContainer addSubview:textLabel];
    
    [_scrollView addSubview:textContainer];
    scrollHeight += textContainer.bounds.size.height;
    
    // article AD
    _adWrapperView = [[UIView alloc] initWithFrame:CGRectMake(0, scrollHeight, self.view.bounds.size.width, 0)];
    
    // related article
    UIImage *relatedImg = [UIImage imageNamed:[NSString stringWithFormat:@"asset.bundle/news_related_%d.jpg", [contentId intValue]%2+1]];
    _relatedImgView = [[UIImageView alloc] initWithImage:relatedImg];
    [_relatedImgView setFrame:CGRectMake(0, scrollHeight, self.view.bounds.size.width, [LayoutUtils getRelatedHeightWithOriWidth:relatedImg.size.width OriHeight:relatedImg.size.height])];
    [_scrollView addSubview:_relatedImgView];
    scrollHeight += _relatedImgView.bounds.size.height;
    
    [_scrollView setContentSize:CGSizeMake(self.view.bounds.size.width, scrollHeight)];
    
    [self setupContentAdWithAdView:_adWrapperView contentId:contentId];
}

#pragma mark - content ad
- (void)setupContentAdWithAdView:(UIView *)adView contentId:(NSString *)contentId
{
    _contentADHelper = [CEContentADHelper helperWithPlacement:@"CONTENT" scrollView:_scrollView contentId:contentId];
    [_contentADHelper loadAdInView:adView];
}

#pragma mark - orientation
- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - private method
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

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)pressBackBtn:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (CGFloat)getStatusBarHeight
{
    CGSize statusBarSize = [[UIApplication sharedApplication] statusBarFrame].size;
    return MAX(MIN(statusBarSize.width, statusBarSize.height), 20);
}
@end
