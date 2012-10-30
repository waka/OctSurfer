//
//  OAuthLastViewController.m
//  OctSurfer
//
//  Copyright (c) 2012 yo_waka. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "OAuthLastViewController.h"
#import "OAuthConstants.h"
#import "CoreDataManager.h"
#import "AuthEntity.h"
#import "AppConfig.h"
#import "CCColor.h"
#import "CCHttpClient.h"
#import "SVProgressHUD.h"


@interface OAuthLastViewController ()
@end


@implementation OAuthLastViewController

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
    
    CCHttpClient *client = [CCHttpClient clientWithUrl: ACCESS_TOKEN_URL];
    NSDictionary *params = @{@"client_id": CLIENT_ID, @"client_secret": CLIENT_SECRET, @"code": self.code};
    [client postWithDelegate: params
                     headers: @{@"application/json": @"Accept"}
                    delegate: self
                     success: @selector(handleGetAccessTokenSuccess:result:)
                     failure: @selector(handleGetAccessTokenFailure:error:)];
}

- (void) handleGetAccessTokenSuccess: (NSHTTPURLResponse *)response result: (NSData *)result
{
    NSDictionary *json = [CCHttpClient responseJSON: result];
    NSString *accessToken = json[@"access_token"];
    
    // Save access token
    AuthEntity *auth = [[CoreDataManager sharedManager] insertNewAuth];
    auth.accessToken = accessToken;
    
    // Save memory because still not saved in CoreData
    [AppConfig set: @"accessToken" value: accessToken];
    [[CoreDataManager sharedManager] save];
    
    [self dismissModalViewControllerAnimated: YES];
}

- (void) handleGetAccessTokenFailure: (NSHTTPURLResponse *)response error: (NSError *)error
{
    [SVProgressHUD showErrorWithStatus: @"Failed to get access token, please retry."];
    [self.navigationController popToRootViewControllerAnimated: NO];
}

@end
