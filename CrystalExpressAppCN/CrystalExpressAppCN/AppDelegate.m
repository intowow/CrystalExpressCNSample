//
//  AppDelegate.m
//  CrystalExpressDemo
//
//  Created by roylo on 2015/1/28.
//  Copyright (c) 2015年 intowow. All rights reserved.
//

#import "AppDelegate.h"
#import "I2WAPI.h"
#import "CESplashAD.h"
#import "DemoStreamSectionViewController.h"
#import "DemoNavigationViewController.h"
#import "AppUtils.h"

@interface AppDelegate() <UIAlertViewDelegate, CESplashADDelegate, I2WADEventDelegate>
@property (nonatomic, strong) DemoNavigationViewController *nav;
@property (nonatomic, assign) BOOL resetViews;
@property (nonatomic, strong) CESplashAD *CEOpenSplashAD;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    UIViewController *logoVC = [[UIViewController alloc] init];
    // Load launch image
    NSString *launchImageName;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        if ([UIScreen mainScreen].bounds.size.height == 480) launchImageName = @"LaunchImage-700@2x.png"; // iPhone 4/4s, 3.5 inch screen
        if ([UIScreen mainScreen].bounds.size.height == 568) launchImageName = @"LaunchImage-700-568h@2x.png"; // iPhone 5/5s, 4.0 inch screen
        if ([UIScreen mainScreen].bounds.size.height == 667) launchImageName = @"LaunchImage-800-667h@2x.png"; // iPhone 6, 4.7 inch screen
        if ([UIScreen mainScreen].bounds.size.height == 736) launchImageName = @"LaunchImage-800-Portrait-736h@3x.png"; // iPhone 6+, 5.5 inch screen
    }
    UIImageView *lanuchImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:launchImageName]];
    
    [logoVC.view addSubview:lanuchImgView];
    
    _nav = [[DemoNavigationViewController alloc] initWithRootViewController:logoVC];
    [self.window addSubview:[_nav view]];
    [_nav setNavigationBarHidden:YES];
    self.window.rootViewController = _nav;
    [self.window makeKeyAndVisible];
    [I2WAPI initWithVerboseLog:YES isTestMode:YES crystalId:@"crystalidforiostestingdonotuseit"];
    [I2WAPI setAdEventDelegate:self];
    
    _CEOpenSplashAD = [[CESplashAD alloc] initWithPlacement:@"OPEN_SPLASH" delegate:self];
    [_CEOpenSplashAD setPortraitViewControllerPresentAnimation:CE_SPLASH_PORTRAIT_PRESENT_DEFAULT
                                              DismissAnimation:CE_SPLASH_PORTRAIT_DISMISS_DEFAULT];
    _resetViews = YES;
    _shouldRequestOpenSplash = YES;
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    _shouldRequestOpenSplash = NO;
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    _resetViews = YES;

    [_nav popToRootViewControllerAnimated:NO];
   
    // register bgTask while enter background mode
    __block UIBackgroundTaskIdentifier bgTask = [application beginBackgroundTaskWithExpirationHandler:^{
        [application endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    _shouldRequestOpenSplash = YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    BOOL hasReqOpenSplash = [self requestOpenSplash];
    if (!hasReqOpenSplash && _resetViews) {
        [self prepareContentViewController];
    }
    _resetViews = NO;
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - background fetch work
- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    [I2WAPI triggerBackgroundFetchOnSuccess:^{
        completionHandler(UIBackgroundFetchResultNewData);
    } onFail:^{
        completionHandler(UIBackgroundFetchResultFailed);
    } onNoData:^{
        completionHandler(UIBackgroundFetchResultNoData);
    }];
}

#pragma mark - deeplinking
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    NSLog(@"deep linking:");
    NSLog(@"  [url host] : %@", [url host]);
    NSLog(@"  [url path] : %@", [url path]);
    NSLog(@"  [sourceApplication] : %@", sourceApplication);
    [I2WAPI handleDeepLinkWithUrl:url sourceApplication:sourceApplication];
    
    _shouldRequestOpenSplash = NO;
    return YES;
}

#pragma mark - InterstitialADViewControllerDelegate
- (BOOL)requestOpenSplash
{
    if (_shouldRequestOpenSplash == NO) {
        return NO;
    } else {
        _shouldRequestOpenSplash = NO;
    }
  
    BOOL isShowingSplashAd = NO;
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
        if ([_CEOpenSplashAD isSplashAdVC:topController]) {
            isShowingSplashAd = YES;
            return NO;
        }
    }

    // delay a little sec to avoid unbalanced call warning
    [_CEOpenSplashAD performSelector:@selector(loadAd) withObject:nil afterDelay:0.05];
    return YES;
}


#pragma mark - CESplashADDelegate
- (void)CESplashADDidReceiveAd:(NSArray *)ad viewController:(SplashADInterfaceViewController *)vc
{
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
  
    [_CEOpenSplashAD showFromViewController:topController animated:YES];
}

- (void)CESplashADDidFailToReceiveAdWithError:(NSError *)error viewController:(SplashADInterfaceViewController *)vc
{
    [self prepareContentViewController];
}

- (void)CESplashAdWillDismissScreen:(SplashADInterfaceViewController *)vc
{
    
}

- (void)CESplashAdWillPresentScreen:(SplashADInterfaceViewController *)vc
{
    
}

- (void)CESplashAdDidDismissScreen:(SplashADInterfaceViewController *)vc
{

}

- (void)CESplashAdDidPresentScreen:(SplashADInterfaceViewController *)vc
{
    [self prepareContentViewController];
}

#pragma mark - adEvent delegate
- (void)onAdClick:(NSString *)adId
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"ad[%@] click!", adId);
    });
}

- (void)onAdImpression:(NSString *)adId
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"ad[%@] impression!", adId);
    });
}

#pragma mark - private method
- (void)prepareContentViewController
{
    DemoStreamSectionViewController *stream = [[DemoStreamSectionViewController alloc] init];
    [_nav pushViewController:stream animated:NO];
    
}

- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window{
    return  UIInterfaceOrientationMaskAll;
}
@end
