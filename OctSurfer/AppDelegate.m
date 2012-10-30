//
//  AppDelegate.m
//  OctSurfer
//
//  Copyright (c) 2012 yo_waka. All rights reserved.
//

#import "AppDelegate.h"
#import "TabBarViewController.h"
#import "CoreDataManager.h"
#import "CCColor.h"


@implementation AppDelegate

- (BOOL) application: (UIApplication *)application didFinishLaunchingWithOptions: (NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame: [[UIScreen mainScreen] bounds]];
    self.window.frame = [[UIScreen mainScreen] bounds];
    self.window.backgroundColor = [CCColor hexToUIColor: @"F8F8F8" alpha: 1.0];
    
    // Add tabbar, this controller is each view router
    UITabBarController *tabBarController = [[TabBarViewController alloc] init];
    self.window.rootViewController = tabBarController;
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (void) applicationDidEnterBackground: (UIApplication *)application
{
    [self saveContext];
}

- (void) applicationWillTerminate:(UIApplication *)application
{
    [self saveContext];
}

- (void) saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = [[CoreDataManager sharedManager] getManagedObjectContext];
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

/**
 * Application scheme is only used for getting OAuth2 access token.
 */
- (BOOL) application: (UIApplication *)application handleOpenURL: (NSURL *) url {
    return NO;
}

@end
