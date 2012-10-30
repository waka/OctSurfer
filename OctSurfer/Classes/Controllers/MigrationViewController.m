//
//  MigrationViewController.m
//  OctSurfer
//
//  Copyright (c) 2012 yo_waka. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "MigrationViewController.h"
#import "CoreDataManager.h"
#import "CCColor.h"
#import "LoginButton.h"
#import "SVProgressHUD.h"


@interface MigrationViewController ()

@property (nonatomic, strong) UILabel *logoLabel;
@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
@property (nonatomic, strong) UIButton *okButton;
@property (nonatomic, strong) UIButton *retryButton;

@end


@implementation MigrationViewController

- (id) initWithNibName: (NSString *)nibNameOrNil bundle: (NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
	
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.view.bounds;
    gradient.colors = @[(id)[[CCColor hexToUIColor: @"FFFFFF" alpha: 1.0] CGColor],
                        (id)[[CCColor hexToUIColor: @"E8E8E8" alpha: 1.0] CGColor]];
    [self.view.layer insertSublayer: gradient atIndex: 0];
    
    CGRect bounds = self.view.bounds;
    
    self.logoLabel = [[UILabel alloc] initWithFrame: CGRectMake(20.0, 50.0, bounds.size.width - 40, 50)];
    self.logoLabel.backgroundColor = [UIColor clearColor];
    self.logoLabel.font = [UIFont systemFontOfSize: 36.0f];
    self.logoLabel.textColor = [UIColor blackColor];
    self.logoLabel.text = @"OctSurfer";
    self.logoLabel.textAlignment = UITextAlignmentCenter;
    [self.view addSubview: self.logoLabel];
    
    self.messageLabel = [[UILabel alloc] initWithFrame: CGRectMake(20.0, 150.0, bounds.size.width - 40, 50)];
    self.messageLabel.backgroundColor = [UIColor clearColor];
    self.messageLabel.font = [UIFont systemFontOfSize: 16.0f];
    self.messageLabel.textColor = [UIColor grayColor];
    self.messageLabel.textAlignment = UITextAlignmentCenter;
    self.messageLabel.numberOfLines = 2;
    [self.view addSubview: self.messageLabel];
    
    self.indicatorView = [[UIActivityIndicatorView alloc]
                          initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleGray];
    self.indicatorView.frame = CGRectMake((bounds.size.width - 50.0) / 2, 250, 50.0, 50.0);
    [self.view addSubview: self.indicatorView];
    
    self.okButton = [LoginButton buttonWithType: UIButtonTypeCustom];
    self.okButton.frame = CGRectMake(20.0, 250.0, bounds.size.width - 40, 50);
    [self.okButton setTitle: @"Start" forState: UIControlStateNormal];
    [self.okButton addTarget: self action: @selector(confirmAction:) forControlEvents: UIControlEventTouchUpInside];
    [self.view addSubview: self.okButton];
    
    self.retryButton = [LoginButton buttonWithType: UIButtonTypeCustom];
    self.retryButton.frame = CGRectMake(20.0, 250.0, bounds.size.width - 40, 50);
    [self.retryButton setTitle: @"Retry" forState: UIControlStateNormal];
    [self.retryButton addTarget: self action: @selector(retryAction:) forControlEvents: UIControlEventTouchUpInside];
    [self.view addSubview: self.retryButton];
}

- (void) viewWillAppear: (BOOL)animated {
    [self migrate];
}

- (void) migrate
{
    self.messageLabel.text = @"Now updating application...";
    self.indicatorView.hidden = NO;
    self.okButton.hidden = YES;
    self.retryButton.hidden = YES;
    
    [self.indicatorView startAnimating];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        if ([[CoreDataManager sharedManager] doMigration]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self handleMigrateSuccess];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self handleMigrateFailure];
            });
        }
    });
}

- (void) handleMigrateSuccess
{
    [SVProgressHUD showSuccessWithStatus: @"Succeeded to update application"];
    
    self.messageLabel.text = @"Finished to update application.\nPlease tap confirm button";
    [self.indicatorView stopAnimating];
    self.indicatorView.hidden = YES;
    self.okButton.hidden = NO;
}

- (void) handleMigrateFailure
{
    [SVProgressHUD showErrorWithStatus: @"Failed to update application"];
    
    self.messageLabel.text = @"Any error has occured.\nPlease tap retry button";
    [self.indicatorView stopAnimating];
    self.indicatorView.hidden = YES;
    self.retryButton.hidden = NO;
}

- (void) confirmAction: (id)sender
{
    if (self.delegate) {
        [self.delegate migrationDidFinish];
    }
}

- (void) retryAction: (id)sender
{
    [self migrate];
}

@end
