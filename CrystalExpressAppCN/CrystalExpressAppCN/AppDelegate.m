//
//  AppDelegate.m
//  CrystalExpressDemo
//
//  Created by roylo on 2015/1/28.
//  Copyright (c) 2015年 intowow. All rights reserved.
//

#import "AppDelegate.h"
#import "I2WAPI.h"
#import "SplashADHelper.h"
#import "SplashADInterfaceViewController.h"
#import "DemoStreamSectionViewController.h"
#import "DemoNavigationViewController.h"
#import "AppUtils.h"


@interface AppDelegate() <UIAlertViewDelegate, SplashADHelperDelegate, SplashADViewControllerDelegate>
@property (nonatomic, strong) UIViewController *openSplashVC;
@property (nonatomic, strong) DemoNavigationViewController *nav;
@property (nonatomic, assign) BOOL resetViews;
@property (nonatomic, strong) SplashADHelper *openSplashHelper;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    UIViewController *rootVC = [[UIViewController alloc] init];
    _nav = [[DemoNavigationViewController alloc] initWithRootViewController:rootVC];
    [self.window addSubview:[_nav view]];
    [_nav setNavigationBarHidden:YES];
    self.window.rootViewController = _nav;
    [self.window makeKeyAndVisible];
    _openSplashHelper = [[SplashADHelper alloc] init];
    [_openSplashHelper setDelegate:self];
    _resetViews = YES;
  
    [I2WAPI initWithVerboseLog:NO];
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
    [I2WAPI refreshI2WAds];
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
        if ([topController isKindOfClass:[SplashADInterfaceViewController class]]) {
            isShowingSplashAd = YES;
            return NO;
        }
    }
    
    [_openSplashHelper requestSplashADWithPlacement:[AppUtils decidePlacementName:@"OPEN_SPLASH"] mode:CE_SPLASH_MODE_SINGLE_OFFER];
    return YES;
}


#pragma mark - SplashADHelperDelegate
- (void)SplashADDidReceiveAd:(NSArray *)ad viewController:(SplashADInterfaceViewController *)vc
{
    _openSplashVC = vc;
    [vc setDelegate:self];
    
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    
    [topController presentViewController:vc animated:YES completion:^{
        [self prepareContentViewController];
    }];
}

- (void)SplashADDidFailToReceiveAdWithError:(NSError *)error viewController:(SplashADInterfaceViewController *)vc
{
    NSLog(@"fail to request OPEN_SPLASH, reason:%@", error);
    [self prepareContentViewController];
}

#pragma mark - SplashADViewControllerDelegate
- (void)SplashAdWillDismissScreen:(SplashADInterfaceViewController *)vc
{
}

- (void)SplashAdWillPresentScreen:(SplashADInterfaceViewController *)vc
{
    
}

- (void)SplashAdDidDismissScreen:(SplashADInterfaceViewController *)vc
{
    _openSplashVC = nil;
}

- (void)SplashAdDidPresentScreen:(SplashADInterfaceViewController *)vc
{
    
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
