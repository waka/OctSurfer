//
//  AbstractViewController.m
//  OctSurfer
//
//  Copyright (c) 2012 yo_waka. All rights reserved.
//

#import "AbstractViewController.h"
#import "OAuthFirstViewController.h"
#import "AppConfig.h"


@interface AbstractViewController ()
@end


@implementation AbstractViewController

- (id) init
{
    self = [super initWithNibName: nil bundle: nil];
    if (self) {
    }
    return self;
}

- (void) showLogin: (BOOL)animated
{
    OAuthFirstViewController *authController = [[OAuthFirstViewController alloc] init];
    UINavigationController *modalNavigationController;
    modalNavigationController = [[UINavigationController alloc] initWithRootViewController: authController];
    modalNavigationController.navigationBarHidden = YES;
    modalNavigationController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentModalViewController: modalNavigationController animated: animated];
}


#pragma mark - Interaction for NavBar/TabBar

- (void) viewDidAppear: (BOOL)animated
{
    [super viewDidAppear: animated];
    
    // If not have accessToken, show login view controller
    NSString *accessToken = [AppConfig getAccessToken];
    if (!accessToken) {
        [self showLogin: YES];
    }
    
    NSArray *subViews = self.navigationController.navigationBar.subviews;
    UIView *navigationBgView = nil;
    for (UIView *subView in subViews) {
        if (subViews.count > 1) {
            if ([[[subView class] description].lowercaseString rangeOfString: @"uinavigationitemview"].location != NSNotFound) {
                navigationBgView = subView;
            }
        } else {
            if ([[[subView class] description].lowercaseString rangeOfString: @"uinavigationbarbackground"].location != NSNotFound) {
                navigationBgView = subView;
            }
        }
        if (navigationBgView) {
            break;
        }
    }
    if (navigationBgView) {
        [self setScrollGesture: navigationBgView];
    }
    
    [self showTabBar: YES];
}

- (void) setScrollGesture: (UIView *)view
{
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(handleTap:)];
    tapGesture.delegate = self;
    view.userInteractionEnabled = YES;
    [view addGestureRecognizer: tapGesture];
}

- (void) handleTap: (id)sender
{
    [self showTabBar: YES];
}

- (void) scrollViewWillBeginDragging: (UIScrollView *)scrollView
{
    if (self.hiddenTabBar == NO) {
        [self hideTabBar: YES];
    }
}

- (void) pushToNavigationController: (UIViewController *)controller
{
    [self showTabBar: NO];
    [self.navigationController pushViewController: controller animated: YES];
}


#pragma mark - TabBar toggle

- (void) showTabBar: (BOOL)animated
{
    /*if (self.hiddenTabBar == NO) {
        return;
    }*/
    
    CGRect bounds = [[UIScreen mainScreen] applicationFrame];
    
    if (animated == YES) {
        [UIView beginAnimations: nil context: NULL];
        [UIView setAnimationDuration: 0.4];
    }
    
    for (UIView *view in self.tabBarController.view.subviews) {
        CGRect rect = view.frame;
        if([view isKindOfClass: [UITabBar class]]) {
            rect.origin.y = bounds.size.height - 29;
            [view setFrame: rect];
        } else {
            rect.size.height = bounds.size.height - 29;
            [view setFrame: rect];
        }
    }
    
    if (animated == YES) {
        [UIView commitAnimations];
    }
    
    self.hiddenTabBar = NO;
}

- (void) hideTabBar: (BOOL)animated
{
    /*if (self.hiddenTabBar == YES) {
        return;
    }*/
    
    CGRect bounds = [[UIScreen mainScreen] applicationFrame];
    
    if (animated == YES) {
        [UIView beginAnimations: nil context: NULL];
        [UIView setAnimationDuration: 0.4];
    }
    
    for (UIView *view in self.tabBarController.view.subviews) {
        CGRect rect = view.frame;
        if([view isKindOfClass: [UITabBar class]]) {
            rect.origin.y = bounds.size.height + 20;
            [view setFrame: rect];
        } else {
            rect.size.height = bounds.size.height + 20;
            [view setFrame: rect];
        }
    }
    
    if (animated == YES) {
        [UIView commitAnimations];
    }
    
    self.hiddenTabBar = YES;
}

@end
