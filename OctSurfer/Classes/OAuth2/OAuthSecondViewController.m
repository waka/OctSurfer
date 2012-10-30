//
//  OAuthSecondViewController.m
//  OctSurfer
//
//  Copyright (c) 2012 yo_waka. All rights reserved.
//

#import "OAuthSecondViewController.h"
#import "OAuthConstants.h"
#import "OAuthLastViewController.h"


@interface OAuthSecondViewController ()
@end


@implementation OAuthSecondViewController

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
    
    CGRect bounds = self.view.bounds;
    UIWebView *webView = [[UIWebView alloc] initWithFrame: CGRectMake(0, 0, bounds.size.width, bounds.size.height)];
    webView.delegate = self;
    [self.view addSubview: webView];
    
    NSString *authorizeURL = [AUTHORIZATION_URL stringByAppendingString: [NSString stringWithFormat: @"?client_id=%@", CLIENT_ID]];
    [webView loadRequest: [NSURLRequest requestWithURL: [NSURL URLWithString: authorizeURL]]];
}


#pragma mark - Web view delegate

/**
 * No redirect to get access token.
 * Because we must do post request to get access token at GitHub's Oauth2.
 */
- (BOOL) webView: (UIWebView *)webView shouldStartLoadWithRequest: (NSURLRequest *)request navigationType: (UIWebViewNavigationType)navigationType {
    if ([request.URL.scheme isEqualToString: CUSTOM_URL_SCHEME] && [request.URL.host isEqualToString: CALLBACK_HOST]) {
        NSString *URLString = [request.URL absoluteString];
        if ([URLString rangeOfString: @"code="].location != NSNotFound) {
            // Get access token
            NSString *code = [[URLString componentsSeparatedByString: @"="] lastObject];
            
            OAuthLastViewController *lastController = [[OAuthLastViewController alloc] init];
            lastController.code = code;
            [self.navigationController pushViewController: lastController animated: NO];
        }
        
        return NO;
    }
    return YES;
}

@end
