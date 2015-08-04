//
//  DemoContentViewController.m
//  crystalexpress
//
//  Created by roylo on 2015/3/27.
//  Copyright (c) 2015年 intowow. All rights reserved.
//

#import "DemoContentViewController.h"
#import "LayoutUtils.h"
#import "CEContentADHelper.h"

#define ARTICLES_CNT 3
#define AD_MARGIN    10

@interface DemoContentViewController () <UIScrollViewDelegate>
@property (nonatomic, strong) NSString *articleId;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *articleADView;
@property (nonatomic, strong) UIView *adWrapperView;
@property (nonatomic, strong) UIImageView *relatedImgView;
@property (nonatomic, assign) CGFloat adOffset;

@property (nonatomic, strong) CEContentADHelper *contentAdHelper;
@end

@implementation DemoContentViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        _articleId = @"";
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
    [_contentAdHelper onShow];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [_contentAdHelper onHide];
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
    _adWrapperView = [[UIView alloc] initWithFrame:CGRectMake(0, scrollHeight, self.view.bounds.size.width, 0)];
    
    // related article
    UIImage *relatedImg = [UIImage imageNamed:[NSString stringWithFormat:@"asset.bundle/news_related_%d.jpg", [articleId intValue]%2+1]];
    _relatedImgView = [[UIImageView alloc] initWithImage:relatedImg];
    [_relatedImgView setFrame:CGRectMake(0, scrollHeight, self.view.bounds.size.width, [LayoutUtils getRelatedHeightWithOriWidth:relatedImg.size.width OriHeight:relatedImg.size.height])];
    [_scrollView addSubview:_relatedImgView];
    scrollHeight += _relatedImgView.bounds.size.height;

    [_scrollView setContentSize:CGSizeMake(self.view.bounds.size.width, scrollHeight)];
    
   
    _contentAdHelper = [CEContentADHelper helperWithPlacement:@"CONTENT" scrollView:_scrollView contentId:articleId];
    [_contentAdHelper loadAdInView:_adWrapperView];
}

@end
