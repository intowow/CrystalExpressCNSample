//
//  DemoContentViewController.m
//  crystalexpress
//
//  Created by roylo on 2015/3/27.
//  Copyright (c) 2015年 intowow. All rights reserved.
//

#import "DemoContentViewController.h"
#import "LayoutUtils.h"
#import "ContentADHelper.h"

#define ARTICLES_CNT 3
#define ADMARGIN     10.0f

@interface DemoContentViewController () <UIScrollViewDelegate>
@property (nonatomic, strong) NSString *articleId;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, weak) ContentADHelper *articleADHelper;
@property (nonatomic, strong) UIView *articleADView;
@property (nonatomic, strong) UIView *adWrapperView;
@property (nonatomic, strong) UIImageView *relatedImgView;
@property (nonatomic, assign) CGFloat adOffset;

@end

@implementation DemoContentViewController

- (instancetype)initWithADHelper:(ContentADHelper *)helper
{
    self = [super init];
    if (self) {
        _articleId = @"";
        _articleADHelper = helper;
        _adOffset = -1;

    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_articleADHelper checkAdStartWithKey:_articleId ScrollViewBounds:[_scrollView bounds]];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [_articleADHelper checkAdStartWithKey:_articleId ScrollViewBounds:CGRectZero];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - public method
- (void)loadContentWithId:(NSString *)articleId
{
    _articleId = articleId;
    _scrollView = [[UIScrollView alloc] init];
    [_scrollView setDelegate:self];
    [[self view] addSubview:_scrollView];
    
    CGFloat scrollHeight = 0;

    [_scrollView setFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];

    // article top
    UIImage *articleTop = [UIImage imageNamed:[NSString stringWithFormat:@"asset.bundle/article_%d.jpg", [articleId intValue]%ARTICLES_CNT+1]];
    
    UIImageView *articleTopView = [[UIImageView alloc] initWithImage:articleTop];
    [articleTopView setFrame:CGRectMake(0, 0, self.view.bounds.size.width, [LayoutUtils getRelatedHeightWithOriWidth:articleTop.size.width OriHeight:articleTop.size.height])];
    [_scrollView addSubview:articleTopView];
    scrollHeight += articleTopView.bounds.size.height;
    
    // text
    NSString *articleTextFilePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"asset.bundle/article_%d", [articleId intValue]%ARTICLES_CNT+1] ofType:@"txt"];
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
    _adWrapperView = [[UIView alloc] init];
    _articleADView = (UIView *)[_articleADHelper requestADWithContentId:articleId];
    [_articleADHelper setScrollOffsetWithKey:articleId offset:scrollHeight];
    if (_articleADView) {
        [_adWrapperView setFrame:CGRectMake(0, scrollHeight, _articleADView.bounds.size.width + 2*ADMARGIN, _articleADView.bounds.size.height + 2*ADMARGIN)];
        [_articleADView setFrame:CGRectMake(ADMARGIN, ADMARGIN, _articleADView.bounds.size.width, _articleADView.bounds.size.height)];
        [_adWrapperView addSubview:_articleADView];
        _adOffset = scrollHeight;
        scrollHeight += _adWrapperView.bounds.size.height;
        [_scrollView addSubview:_adWrapperView];
    } else {
        scrollHeight += [LayoutUtils getRelatedHeightWithOriWidth:720 OriHeight:60];
    }
    
    
    
    // related article
    UIImage *relatedImg = [UIImage imageNamed:[NSString stringWithFormat:@"asset.bundle/news_related_%d.jpg", [articleId intValue]%2+1]];
    _relatedImgView = [[UIImageView alloc] initWithImage:relatedImg];
    [_relatedImgView setFrame:CGRectMake(0, scrollHeight, self.view.bounds.size.width, [LayoutUtils getRelatedHeightWithOriWidth:relatedImg.size.width OriHeight:relatedImg.size.height])];
    [_scrollView addSubview:_relatedImgView];
    scrollHeight += _relatedImgView.bounds.size.height;

    
    [_scrollView setContentSize:CGSizeMake(self.view.bounds.size.width, scrollHeight)];
}

#pragma mark - pull down
- (void)onPullDownAnimationWithAD:(UIView *)adView
{
    if (adView == _articleADView) {
        CGRect frame = [_adWrapperView frame];
        frame.size.height = adView.bounds.size.height + ADMARGIN*2;
        [_adWrapperView setFrame:frame];
        
        frame = [_relatedImgView frame];
        frame.origin.y = _adOffset + _adWrapperView.bounds.size.height;
        [_relatedImgView setFrame:frame];
        
        CGFloat finalContentOffset = _adOffset + adView.bounds.size.height + _relatedImgView.bounds.size.height;
        [_scrollView setContentSize:CGSizeMake(self.view.bounds.size.width, finalContentOffset)];
    }
}

#pragma mark - scrollview delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_articleADHelper updateScrollViewBounds:[scrollView bounds] withKey:_articleId];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (decelerate == NO) {
        [_articleADHelper checkAdStartWithKey:_articleId ScrollViewBounds:[scrollView bounds]];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [_articleADHelper checkAdStartWithKey:_articleId ScrollViewBounds:[scrollView bounds]];
}

@end
