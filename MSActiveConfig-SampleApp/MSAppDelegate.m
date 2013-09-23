//
//  MSAppDelegate.m
//  MSActiveConfig-SampleApp
//
//  Created by Javier Soto on 7/6/13.
//  Copyright (c) 2013 MindSnacks. All rights reserved.
//

#import "MSAppDelegate.h"

#import "MSSettingsViewController.h"
#import "MSSampleViewController.h"

@interface MSAppDelegate () <UIApplicationDelegate, UITabBarControllerDelegate>

@property (strong, readwrite, nonatomic) UITabBarController *tabBarController;

@end

@implementation MSAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    MSSettingsViewController *settingsVC = [[MSSettingsViewController alloc] init];
    MSSampleViewController *sampleVC = [[MSSampleViewController alloc] init];

    self.tabBarController = [[UITabBarController alloc] init];
    self.tabBarController.viewControllers = @[settingsVC, sampleVC];

    self.window.rootViewController = self.tabBarController;

    [self.window makeKeyAndVisible];
    
    return YES;
}

@end
