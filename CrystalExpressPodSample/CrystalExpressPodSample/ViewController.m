//
//  ViewController.m
//  CrystalExpressPodSample
//
//  Created by roylo on 2015/4/29.
//  Copyright (c) 2015年 intowow. All rights reserved.
//

#import "ViewController.h"
#import "I2WAPI.h"
#import "ContentViewController.h"
#import "StreamSectionViewController.h"
#import "FlipViewController.h"
#import "CESplashAD.h"
#import "CardAdViewController.h"

@interface ViewController () <CESplashADDelegate>
@property (nonatomic, strong) CESplashAD *openSplashADHelper;
@property (nonatomic, strong) UIButton *testOpenSplashBtn;
@property (nonatomic, strong) UIButton *testContentBtn;
@property (nonatomic, strong) UIButton *testStreamBtn;
@property (nonatomic, strong) UIButton *testCardAdBtn;
@property (nonatomic, strong) UIButton *testFixedPositionStreamBtn;
@end

@implementation ViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    [[self view] setBackgroundColor:[UIColor whiteColor]];
    
    int screenHeight = [[UIScreen mainScreen] bounds].size.height;
    
    _openSplashADHelper = [[CESplashAD alloc] initWithPlacement:@"OPEN_SPLASH" delegate:self];
    
    CGFloat spaceHeight = screenHeight / 25;
    CGFloat btnHeight = spaceHeight * 1.8;
    
    _testOpenSplashBtn = [self createBtnWithTag:1 title:@"OPEN_SPLASH_AD"];
    _testContentBtn = [self createBtnWithTag:2 title:@"CONTENT_AD"];
    _testStreamBtn = [self createBtnWithTag:3 title:@"STREAM_AD"];
    _testCardAdBtn = [self createBtnWithTag:4 title:@"CARD_AD"];
    _testFixedPositionStreamBtn = [self createBtnWithTag:5 title:@"FIXED_POS_STREAM_AD"];

    NSString *VConstraint = @"V:|-30-[_testOpenSplashBtn(btnHeight)]-10-[_testContentBtn(btnHeight)]-10-[_testStreamBtn(btnHeight)]-10-[_testCardAdBtn(btnHeight)]-10-[_testFixedPositionStreamBtn(btnHeight)]";
    [[self view] addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:VConstraint options:NSLayoutFormatDirectionLeadingToTrailing metrics:[NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:btnHeight] forKey:@"btnHeight"] views:NSDictionaryOfVariableBindings(_testOpenSplashBtn, _testContentBtn, _testStreamBtn, _testCardAdBtn, _testFixedPositionStreamBtn)]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - button action
- (IBAction)highlightBtn:(id)sender
{
    [sender setBackgroundColor:[UIColor redColor]];
}

- (IBAction)requestAD:(id)sender
{
    [sender setBackgroundColor:[UIColor blueColor]];
    switch ([sender tag]) {
        case 1:
            [_openSplashADHelper loadAd];
            break;
        case 2:
            [self.navigationController pushViewController:[[ContentViewController alloc] init] animated:YES];
            break;
        case 3:
            [self.navigationController pushViewController:[[StreamSectionViewController alloc] initWithPlacementName:@"STREAM"] animated:YES];
            break;
        case 4:
            [self.navigationController pushViewController:[[CardAdViewController alloc] init] animated:YES];
            break;
        case 5:
            [self.navigationController pushViewController:[[StreamSectionViewController alloc] initWithAdTagName:@"SPORT"] animated:YES];
            break;
        default:
            break;
    }
    
}

#pragma mark - CESplashADDelegate method
- (void)CESplashADDidReceiveAd:(NSArray *)ad viewController:(SplashADInterfaceViewController *)vc
{
    [_openSplashADHelper showFromViewController:self animated:YES];
}

- (void)CESplashADDidFailToReceiveAdWithError:(NSError *)error viewController:(SplashADInterfaceViewController *)vc
{
}

- (void)CESplashAdWillPresentScreen:(SplashADInterfaceViewController *)vc
{
}

- (void)CESplashAdDidPresentScreen:(SplashADInterfaceViewController *)vc
{
}

- (void)CESplashAdWillDismissScreen:(SplashADInterfaceViewController *)vc
{
}

- (void)CESplashAdDidDismissScreen:(SplashADInterfaceViewController *)vc
{
}

#pragma mark - private method
- (UIButton *)createBtnWithTag:(NSInteger)tag title:(NSString *)text
{
    UIButton *newBtn = [[UIButton alloc] init];
    [newBtn setTitle:text forState:UIControlStateNormal];
    [newBtn setBackgroundColor:[UIColor blueColor]];
    [newBtn setTag:tag];
    newBtn.translatesAutoresizingMaskIntoConstraints = NO;
    
    [newBtn addTarget:self action:@selector(highlightBtn:) forControlEvents:UIControlEventTouchDown];
    [newBtn addTarget:self action:@selector(requestAD:) forControlEvents:UIControlEventTouchUpInside];
    [[self view] addSubview:newBtn];
    [[self view] addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[newBtn]-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:NSDictionaryOfVariableBindings(newBtn)]];
    return newBtn;
}

#pragma mark - orientation
- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}


@end
