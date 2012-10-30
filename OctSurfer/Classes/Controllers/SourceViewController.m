//
//  SourceViewController.m
//  OctSurfer
//
//  Copyright (c) 2012 yo_waka. All rights reserved.
//

#import "SourceViewController.h"
#import "RepositoryInfoView.h"
#import "ApiCache.h"
#import "ApiUrl.h"
#import "AppConfig.h"
#import "CCBase64.h"
#import "FileTypes.h"
#import "CCHttpClient.h"
#import "SVProgressHUD.h"


@interface SourceViewController ()

@property (nonatomic, weak) UIWebView *webView;
@property (nonatomic, assign) BOOL forceUpdate;

@end


@implementation SourceViewController

- (id) init
{
    self = [super init];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    CGRect bounds = [[UIScreen mainScreen] applicationFrame];
    
    UIWebView *webView = [[UIWebView alloc]
                          initWithFrame: CGRectMake(0, 0, bounds.size.width, bounds.size.height)];
    webView.scalesPageToFit = NO;
    webView.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal;
    webView.delegate = self;
    webView.scrollView.delegate = self;
    [self.view addSubview: webView];
    
    //UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(handleTap:)];
    //tapGesture.delegate=self;
    //[webView addGestureRecognizer: tapGesture];
    
    // Set self property
    self.title = self.name;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithBarButtonSystemItem: UIBarButtonSystemItemRefresh
                                              target: self
                                              action: @selector(handleRefreshClicked:)];
    self.webView = webView;
    
    [self getContent: NO];
}

- (BOOL) gestureRecognizer: (UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer: (UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (void) handleRefreshClicked: (id)sender
{
    [self getContent: YES];
}

- (void) getContent: (BOOL)forceUpdate
{
    self.forceUpdate = forceUpdate;
    NSString *path = [[NSBundle mainBundle] pathForResource: @"source" ofType: @"html"];
    [self.webView loadRequest: [NSURLRequest requestWithURL: [NSURL fileURLWithPath: path]]];
}

- (void) webViewDidFinishLoad: (UIWebView *)webView {
    if (!self.forceUpdate) {
        id json = [ApiCache get: self.url];
        if (json) {
            [self showContent: json];
            return;
        }
    }
    NSMutableString *url = [self.url mutableCopy];
    NSString *accessToken = [AppConfig getAccessToken];
    if (accessToken) {
        [url appendString: [NSString stringWithFormat: @"?access_token=%@", accessToken]];
    }
    CCHttpClient *client = [CCHttpClient clientWithUrl: url];
    [client getJsonWithDelegate: nil
                        headers: nil
                       delegate: self
                        success: @selector(handleGetContentSuccess:result:)
                        failure: @selector(handleGetContentFailure:error:)];
}

- (void) handleGetContentSuccess: (NSHTTPURLResponse *) res result: (NSData *)result
{
    id json = [CCHttpClient responseJSON: result];
    [self showContent: json];
    [ApiCache set: self.url path: nil value: json];
}

- (void) handleGetContentFailure: (NSHTTPURLResponse *) res error: (NSError *)error
{
    [SVProgressHUD showErrorWithStatus: @"Load error, please refresh."];
}

- (void) showContent: (id)json
{
    NSString *content = [CCBase64 decode: (NSString *)json[@"content"]];
    NSString *language = [FileTypes get: [self.name copy]];
    
    // Inject language, source code, and do colorize
    [self.webView stringByEvaluatingJavaScriptFromString: [NSString stringWithFormat: @"var codeEl = document.getElementById('source');"
                                                           "codeEl.setAttribute('data-language', '%@');"
                                                           "codeEl.innerText = '%@';"
                                                           "Rainbow.color();",
                                                           language,
                                                           [self addSlashes: content]]];
}

- (NSString *) addSlashes: (NSString *)string {
    // Escape the characters
    string = [string stringByReplacingOccurrencesOfString: @"\\" withString: @"\\\\"];
    string = [string stringByReplacingOccurrencesOfString: @"\"" withString: @"\\\""];
    string = [string stringByReplacingOccurrencesOfString: @"\'" withString: @"\\\'"];
    string = [string stringByReplacingOccurrencesOfString: @"\n" withString: @"\\n"];
    string = [string stringByReplacingOccurrencesOfString: @"\r" withString: @"\\r"];
    string = [string stringByReplacingOccurrencesOfString: @"\f" withString: @"\\f"];
    return string;
}

@end
