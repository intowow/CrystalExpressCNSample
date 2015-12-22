//
//  StreamSectionViewController.m
//  CrystalExpressPodSample
//
//  Created by roylo on 2015/4/29.
//  Copyright (c) 2015年 intowow. All rights reserved.
//

#import "StreamSectionViewController.h"
#import "LayoutUtils.h"
#import "StreamTableViewController.h"

@interface StreamSectionViewController () <UIScrollViewDelegate>
@property (nonatomic, strong) UIScrollView *contentView;
@property (nonatomic, strong) NSString *placementName;
@property (nonatomic, strong) NSString *tagName;
@end

@implementation StreamSectionViewController
- (instancetype)initWithPlacementName:(NSString *)placementName
{
    self = [super init];
    if (self) {
        _placementName = placementName;
    }
    return self;
}

- (instancetype)initWithAdTagName:(NSString *)tagName
{
    self = [super init];
    if (self) {
        _tagName = tagName;
    }
    return self;
}

- (void)viewDidLoad
{
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
    
    [[self view] addSubview:titleView];

    // content swipe view
    _contentView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, titleView.bounds.size.height, SCREEN_WIDTH, SCREEN_HEIGHT - titleView.bounds.size.height)];
    [_contentView setDelegate:self];
    [_contentView setContentSize:CGSizeMake(SCREEN_WIDTH, _contentView.bounds.size.height)];
    [_contentView setPagingEnabled:YES];
    [_contentView setShowsHorizontalScrollIndicator:NO];
    [_contentView setShowsVerticalScrollIndicator:NO];
    [[self view] addSubview:_contentView];

    StreamTableViewController *vc;
    if (_placementName != nil && ![_placementName isEqual:@""]) {
        vc = [[StreamTableViewController alloc] initWithPlacementName:_placementName];
    } else {
        vc = [[StreamTableViewController alloc] initWithAdTagName:_tagName];
    }
    
    if ([vc.view superview] == nil) {
        CGRect frame = [_contentView frame];
        frame.origin.x = 0;
        frame.origin.y = 0;
        frame.size.width = frame.size.width;
        frame.size.height = frame.size.height;
        vc.view.frame = frame;
        
        [self addChildViewController:vc];
        [_contentView addSubview:[vc view]];
        [vc didMoveToParentViewController:self];
    }
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

- (void)pressBackBtn:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
@end
