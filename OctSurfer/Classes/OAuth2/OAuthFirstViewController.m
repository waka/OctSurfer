//
//  OAuthFirstViewController.m
//  OctSurfer
//
//  Copyright (c) 2012 yo_waka. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "OAuthFirstViewController.h"
#import "OAuthFirstView.h"
#import "OAuthSecondViewController.h"
#import "CCColor.h"


@interface OAuthFirstViewController ()
@end


@implementation OAuthFirstViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.view.bounds;
    gradient.colors = @[(id)[[CCColor hexToUIColor: @"FFFFFF" alpha: 1.0] CGColor], (id)[[CCColor hexToUIColor: @"E8E8E8" alpha: 1.0] CGColor]];
    [self.view.layer insertSublayer: gradient atIndex: 0];
    
    CGRect bounds = self.view.bounds;
    OAuthFirstView *firstView = [[OAuthFirstView alloc] initWithFrame: CGRectMake(0, 0, bounds.size.width, bounds.size.height)];
    firstView.delegate = self;
    [self.view addSubview: firstView];
}


#pragma mark - First view delegate

- (void) loginButtonClicked:(UIButton *)button
{
    OAuthSecondViewController *secondController = [[OAuthSecondViewController alloc] init];
    [self.navigationController pushViewController: secondController animated: NO];
}

@end
