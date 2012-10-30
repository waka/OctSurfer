//
//  AbstractViewController.h
//  OctSurfer
//
//  Copyright (c) 2012 yo_waka. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AbstractViewController : UIViewController <UIGestureRecognizerDelegate>

@property (nonatomic, assign) BOOL hiddenTabBar;

- (void) showLogin: (BOOL)animated;

- (void) setScrollGesture: (UIView *)view;
- (void) handleTap: (id)sender;
- (void) scrollViewWillBeginDragging: (UIScrollView *)scrollView;
- (void) pushToNavigationController: (UIViewController *)controller;

- (void) showTabBar: (BOOL)animated;
- (void) hideTabBar: (BOOL)animated;

@end
