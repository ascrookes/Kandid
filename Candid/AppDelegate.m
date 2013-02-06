//
//  AppDelegate.m
//  Candid
//
//  Created by Amadou Crookes on 6/23/12.
//  Copyright (c) 2012 Amadou Crookes. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize didResign;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [TestFlight takeOff:@"486bc2144e1258a6096557a2792a3082_MTc3ODc2MjAxMy0wMS0yMiAwMDoyNzozMi4yOTYyNDc"];
    [TestFlight setDeviceIdentifier:[[UIDevice currentDevice] uniqueIdentifier]];
    [self customizeAppearance];
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        
        CGSize result = [[UIScreen mainScreen] bounds].size;
        CGFloat scale = [UIScreen mainScreen].scale;
        result = CGSizeMake(result.width * scale, result.height * scale);
        // this is the height of the iPhone 5 Screen
        // change the storyboard to use the entire screen
        if(result.height == 1136) {
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"iPhone5Storyboard" bundle:nil];
            UIViewController *initViewController = [storyBoard instantiateInitialViewController];
            [self.window setRootViewController:initViewController];
        }
    }
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"premiumUser"];
    
    return YES;
}

- (void)customizeAppearance
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
    //[[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"navBar.png"] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setTintColor:[UIColor lightGrayColor]];
    [[UIBarButtonItem appearance] setTintColor:[UIColor colorWithRed:122/255.0 green:0 blue:1 alpha:1]];
}

							
- (void)applicationWillResignActive:(UIApplication *)application
{
    self.didResign = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kandid.beginInterruption" object:nil];
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    self.didResign = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kandid.didEnterBackground" object:nil];
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    self.didResign = NO;
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kandid.appBecameActive" object:nil];
    if(self.didResign) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kandid.endInterruption" object:nil];
    }
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    NSLog(@"TerminATION...");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kandid.appWillTerminate" object:nil];
}

@end
