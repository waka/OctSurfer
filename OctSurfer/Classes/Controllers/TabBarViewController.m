//
//  TabBarViewController.m
//  OctSurfer
//
//  Copyright (c) 2012 yo_waka. All rights reserved.
//

#import "TabBarViewController.h"
#import "SearchViewController.h"
#import "ProfileViewController.h"
#import "OrganizationViewController.h"
#import "FeedbackViewController.h"
#import "CCColor.h"


@implementation TabBarViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    UIViewController *searchController = [[SearchViewController alloc] init];
    searchController.tabBarItem = [[UITabBarItem alloc] initWithTitle: @"Search" image: [UIImage imageNamed: @"search.png"] tag: 1];

    UIViewController *profileController = [[ProfileViewController alloc] init];
    profileController.tabBarItem = [[UITabBarItem alloc] initWithTitle: @"Starred" image: [UIImage imageNamed: @"star.png"] tag: 2];
    
    UIViewController *orgController = [[OrganizationViewController alloc] init];
    orgController.tabBarItem = [[UITabBarItem alloc] initWithTitle: @"Organizations" image: [UIImage imageNamed: @"org.png"] tag: 3];

    UIViewController *feedbackController = [[FeedbackViewController alloc] init];
    feedbackController.tabBarItem = [[UITabBarItem alloc] initWithTitle: @"Feedback" image: [UIImage imageNamed: @"pacman.png"] tag: 4];
    
    NSArray *viewControllers = @[
        [[UINavigationController alloc] initWithRootViewController: searchController],
        [[UINavigationController alloc] initWithRootViewController: profileController],
        [[UINavigationController alloc] initWithRootViewController: orgController],
        [[UINavigationController alloc] initWithRootViewController: feedbackController]
    ];
    self.viewControllers = viewControllers;
}

@end
