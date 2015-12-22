//
//  CardAdViewController.m
//  CrystalExpressCNManualSample
//
//  Created by roylo on 2015/8/11.
//  Copyright (c) 2015年 intowow. All rights reserved.
//

#import "CardAdViewController.h"
#import "CECardADHelper.h"
#import "LayoutUtils.h"

@interface CardAdViewController ()
@property (nonatomic, strong) CECardADHelper *adHelper;
@property (nonatomic, strong) ADView *cardAd;
@property (nonatomic, assign) BOOL isAdPlaying;
@property (nonatomic, strong) UIButton *startBtn;
@property (nonatomic, strong) UIButton *stopBtn;
@end

@implementation CardAdViewController
- (instancetype)init
{
    self = [super init];
    if (self) {
        _adHelper = nil;
        _cardAd = nil;
        _isAdPlaying = NO;
        _startBtn = nil;
        _stopBtn = nil;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [[self view] addSubview:[self createTitleView]];
    
    UIButton *loadAdBtn = [self createBtnWithTitle:@"loadAD"];
    [loadAdBtn addTarget:self action:@selector(loadAd) forControlEvents:UIControlEventTouchUpInside];
    
    _startBtn = [self createBtnWithTitle:@"startAD"];
    [_startBtn addTarget:self action:@selector(startAd) forControlEvents:UIControlEventTouchUpInside];

    _stopBtn = [self createBtnWithTitle:@"stopAD"];
    [_stopBtn addTarget:self action:@selector(stopAd) forControlEvents:UIControlEventTouchUpInside];
    
    NSDictionary *metric = @{@"btnHeight":@(30)};
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-70-[loadAdBtn(btnHeight)]-[_startBtn(btnHeight)]-[_stopBtn(btnHeight)]" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metric views:NSDictionaryOfVariableBindings(loadAdBtn, _startBtn, _stopBtn)]];
    

    _adHelper = [[CECardADHelper alloc] initWithPlacement:@"STREAM"];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self stopAd];
}

#pragma mark - ad control
- (void)loadAd
{
    if (_cardAd) {
        [self stopAd];
        [_cardAd removeFromSuperview];
        _cardAd = nil;
    }
    
    [_adHelper requestADWithAdWidth:360.0f onReady:^(ADView *adView) {
        CGFloat horizontalStart = (self.view.bounds.size.width - adView.bounds.size.width)/2.0f;
        CGFloat veritalStart = self.view.bounds.size.height - adView.bounds.size.height - 50;
        [adView setFrame:CGRectMake(horizontalStart, veritalStart, adView.bounds.size.width, adView.bounds.size.height)];
        [self.view addSubview:adView];
        _cardAd = adView;
    } onFailure:^(NSError *error) {
        
    }];
}

- (void)startAd
{
    if (_cardAd && _isAdPlaying == NO) {
        [_cardAd onStart];
        _isAdPlaying = YES;
    }
}

- (void)stopAd
{
    if (_cardAd && _isAdPlaying == YES) {
        [_cardAd onStop];
        _isAdPlaying = NO;
        [_cardAd onHide];
    }
}

#pragma mark - private method
- (UIView *)createTitleView
{
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

- (UIButton *)createBtnWithTitle:(NSString *)text
{
    UIButton *newBtn = [[UIButton alloc] init];
    [newBtn setTitle:text forState:UIControlStateNormal];
    [newBtn setBackgroundColor:[UIColor blueColor]];
    newBtn.translatesAutoresizingMaskIntoConstraints = NO;
  
    [newBtn setBackgroundImage:[self imageWithColor:[UIColor redColor]] forState:UIControlStateHighlighted];
    
    [[self view] addSubview:newBtn];
    [[self view] addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[newBtn]-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:NSDictionaryOfVariableBindings(newBtn)]];
    return newBtn;
}

- (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}
@end
