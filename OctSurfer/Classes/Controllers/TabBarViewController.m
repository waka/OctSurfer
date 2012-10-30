//
//  TabBarViewController.m
//  OctSurfer
//
//  Copyright (c) 2012 yo_waka. All rights reserved.
//

#import "TabBarViewController.h"
#import "SearchViewController.h"
#import "StarViewController.h"
#import "ProfileViewController.h"
#import "OAuthFirstViewController.h"
#import "AppConfig.h"


@implementation TabBarViewController

- (void) viewDidAppear: (BOOL)animated
{
    // If not have accessToken, show login view controller
    NSString *accessToken = [AppConfig getAccessToken];
    if (!accessToken) {
        [self showLogin];
    }
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    UIViewController *searchViewController = [[SearchViewController alloc] init];
    searchViewController.tabBarItem = [[UITabBarItem alloc]
                                       initWithTabBarSystemItem: UITabBarSystemItemSearch tag: 1];
    UIViewController *starViewController = [[StarViewController alloc] init];
    starViewController.tabBarItem = [[UITabBarItem alloc]
                                     initWithTabBarSystemItem: UITabBarSystemItemFavorites tag: 2];
    UIViewController *profileViewController = [[ProfileViewController alloc] init];
    profileViewController.tabBarItem = [[UITabBarItem alloc]
                                        initWithTabBarSystemItem: UITabBarSystemItemFeatured tag: 3];
    
    NSArray *viewControllers = @[
        [[UINavigationController alloc] initWithRootViewController: searchViewController],
        [[UINavigationController alloc] initWithRootViewController: starViewController],
        [[UINavigationController alloc] initWithRootViewController: profileViewController]
    ];
    self.viewControllers = viewControllers;
}

- (void) showLogin
{
    OAuthFirstViewController *authController = [[OAuthFirstViewController alloc] init];
    UINavigationController *modalNavigationController;
    modalNavigationController = [[UINavigationController alloc] initWithRootViewController: authController];
    modalNavigationController.navigationBarHidden = YES;
    [self presentModalViewController: modalNavigationController animated: NO];
}

@end
