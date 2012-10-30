//
//  SourceViewController.m
//  OctSurfer
//
//  Copyright (c) 2012 yo_waka. All rights reserved.
//

#import "SourceViewController.h"
#import "RepositoryInfoView.h"
#import "CCBase64.h"
#import "FileTypes.h"
#import "CCHttpClient.h"


@interface SourceViewController ()

@property (nonatomic, weak) UIWebView *webView;

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
    [self.view addSubview: webView];
    
    NSString *path = [[NSBundle mainBundle] pathForResource: @"source" ofType: @"html"];
    [webView loadRequest: [NSURLRequest requestWithURL: [NSURL fileURLWithPath: path]]];
    
    // Set self property
    self.title = self.name;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithBarButtonSystemItem: UIBarButtonSystemItemRefresh
                                              target: self
                                              action: @selector(handleRefreshClicked:)];
    self.webView = webView;
    
    [self getContent];
}

- (void) handleRefreshClicked: (id)sender
{
    [self getContent];
}

- (void) getContent
{
    CCHttpClient *client = [CCHttpClient clientWithUrl: self.url];
    [client getJsonWithDelegate: self success: @selector(handleGetContentSuccess:) failure: nil];
}

- (void) handleGetContentSuccess: (NSDictionary *)json
{
    NSString *content = [CCBase64 decode: (NSString *)json[@"content"]];
    NSString *language = [FileTypes get: self.name];
    
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
