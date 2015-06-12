//
//  DemoNavigationViewController.m
//  crystalexpress
//
//  Created by roylo on 2015/4/8.
//  Copyright (c) 2015年 intowow. All rights reserved.
//

#import "DemoNavigationViewController.h"

@interface DemoNavigationViewController ()

@end

@implementation DemoNavigationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate
{
    return self.topViewController.shouldAutorotate;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return self.topViewController.supportedInterfaceOrientations;
//    UIViewController *topController = self.topViewController;
//    while (topController.presentedViewController) {
//        topController = topController.presentedViewController;
//    }
//    return topController.supportedInterfaceOrientations;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return self.topViewController.preferredInterfaceOrientationForPresentation;
//    UIViewController *topController = self.topViewController;
//    while (topController.presentedViewController) {
//        topController = topController.presentedViewController;
//    }
//    return topController.preferredInterfaceOrientationForPresentation;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
