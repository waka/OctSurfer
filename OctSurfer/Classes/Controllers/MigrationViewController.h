//
//  MigrationViewController.h
//  OctSurfer
//
//  Copyright (c) 2012 yo_waka. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MigrationViewControllerDelegate.h"


@interface MigrationViewController : UIViewController

@property (nonatomic, weak) id<MigrationViewControllerDelegate> delegate;

@end
