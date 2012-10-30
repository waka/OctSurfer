//
//  AppDelegate.m
//  OctSurfer
//
//  Copyright (c) 2012 yo_waka. All rights reserved.
//

#import "AppDelegate.h"
#import "MigrationViewController.h"
#import "TabBarViewController.h"
#import "CoreDataManager.h"
#import "CCColor.h"


@implementation AppDelegate

- (BOOL) application: (UIApplication *)application didFinishLaunchingWithOptions: (NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame: [[UIScreen mainScreen] bounds]];
    self.window.frame = [[UIScreen mainScreen] bounds];
    self.window.backgroundColor = [CCColor hexToUIColor: @"F8F8F8" alpha: 1.0];
    
    // Color defined
    [[UINavigationBar appearance] setTintColor: [UIColor grayColor]];
    
    if ([[CoreDataManager sharedManager] isRequiredMigration]) {
        [self startMigration];
    } else {
        [self startApplication];
    }
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (void) startMigration
{
    MigrationViewController *migrationController = [[MigrationViewController alloc] init];
    migrationController.delegate = self;
    self.window.rootViewController = migrationController;
}

- (void) migrationDidFinish
{
    [UIView beginAnimations: nil context: nil];
    [UIView setAnimationDuration: 0.5];
    [UIView setAnimationCurve: UIViewAnimationCurveLinear];
    [UIView setAnimationDelegate: self];
    [UIView setAnimationDidStopSelector: @selector(didMigrationViewAnimationFinished:finished:context:)];
    self.window.rootViewController.view.alpha = 0.0;
    [UIView commitAnimations];
}

- (void) didMigrationViewAnimationFinished: (NSString *)animation finished: (BOOL)finished context: (void *)context
{
    [self startApplication];
}

- (void) startApplication
{
    // Add tabbar, this controller is each view router
    UITabBarController *tabBarController = [[TabBarViewController alloc] init];
    self.window.rootViewController = tabBarController;
}

- (void) applicationDidEnterBackground: (UIApplication *)application
{
    [[CoreDataManager sharedManager] save];
    [self deleteCookie];
}

- (void) applicationWillTerminate: (UIApplication *)application
{
    [[CoreDataManager sharedManager] save];
    [self deleteCookie];
}

- (void) deleteCookie
{
    NSHTTPCookieStorage *cookieStrage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
	for (id obj in [cookieStrage cookies]) {
		[cookieStrage deleteCookie:obj];
	}
}


/**
 * Application scheme is only used for getting OAuth2 access token.
 */
- (BOOL) application: (UIApplication *)application handleOpenURL: (NSURL *) url {
    return NO;
}

@end
