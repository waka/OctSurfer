//
//  CCHttpClient.m
//  OctSurfer
//
//  Copyright (c) 2012 yo_waka. All rights reserved.
//

#import "CCHttpClient.h"
#import "Reachability.h"
#import "SVProgressHUD.h"


@interface CCHttpClient ()

@property (nonatomic, assign) BOOL acceptJson;

- (NSMutableURLRequest *) createGetRequest;

- (NSMutableURLRequest *) createPostRequest;

- (void) send: (NSMutableURLRequest *)req
     delegate: (id)target
      success: (SEL)successSelector
      failure: (SEL)failureSelector;

@end


@implementation CCHttpClient

#pragma mark Initialize methods

+ (id) clientWithUrl: (NSString *)url
{
    return [[CCHttpClient alloc] initWithUrl: url];
}

- (id) initWithUrl: (NSString *)url
{
    self = [super init];
    if (self) {
        _url = url;
        _acceptJson = NO;
    }
    return self;
}


#pragma mark Get request methods

- (void) getWithDelegate: (id)target
                 success: (SEL)successSelector
                 failure: (SEL)failureSelector
{
    NSMutableURLRequest *req = [self createGetRequest];
    [self send: req delegate: target success: successSelector failure: failureSelector];
}

- (void) getJsonWithDelegate: (id)target
                     success: (SEL)successSelector
                     failure: (SEL)failureSelector
{
    NSMutableURLRequest *req = [self createGetRequest];
    [req setValue: @"application/json" forHTTPHeaderField: @"Content-Type"];
    self.acceptJson = YES;
    [self send: req delegate: target success: successSelector failure: failureSelector];
}

- (NSMutableURLRequest *) createGetRequest
{
    NSMutableString *urlString = [[NSMutableString alloc] initWithString: self.url];
    if (self.params) {
        [urlString appendString: @"?"];
        [urlString appendString: [CCHttpClient makeQuerystringFromDictionary: self.params]];
    }
    
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL: [NSURL URLWithString: urlString]
                                                       cachePolicy: NSURLRequestUseProtocolCachePolicy
                                                   timeoutInterval: 30.0];
    [req setHTTPMethod: @"GET"];
    return req;
}


#pragma mark Post request methods

- (void) postWithDelegate: (id)target
                  success: (SEL)successSelector
                  failure: (SEL)failureSelector
{
    NSMutableURLRequest *req = [self createPostRequest];
    
    if (self.params) {
        NSString *postString = [CCHttpClient makeQuerystringFromDictionary: self.params];
        NSData *postData = [NSData dataWithBytes: [postString UTF8String]
                                          length: [postString length]];
        [req setValue: [NSString stringWithFormat: @"%d", [postString length]] forHTTPHeaderField: @"Content-Length"];
        [req setHTTPBody: postData];
    }
    self.acceptJson = YES;
    [self send: req delegate: target success: successSelector failure: failureSelector];
}

- (void) postJsonWithDelegate: (id)target
                      success: (SEL)successSelector
                      failure: (SEL)failureSelector
{
    NSMutableURLRequest *req = [self createPostRequest];
    
    if (self.params) {
        NSError __autoreleasing *jsonError = nil;
        NSData *postData = [NSJSONSerialization dataWithJSONObject: self.params
                                                           options: NSJSONWritingPrettyPrinted
                                                             error: &jsonError];
        int contentLength = [[[NSString alloc] initWithData: postData encoding: NSUTF8StringEncoding] length];
        [req setValue: [NSString stringWithFormat: @"%d", contentLength] forHTTPHeaderField: @"Content-Length"];
        [req setHTTPBody: postData];
    }
    self.acceptJson = YES;
    [self send: req delegate: target success: successSelector failure: failureSelector];
}

- (NSMutableURLRequest *) createPostRequest
{
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL: [NSURL URLWithString: self.url]
                                                       cachePolicy: NSURLRequestUseProtocolCachePolicy
                                                   timeoutInterval: 30.0];
    [req setHTTPMethod: @"POST"];
    [req setValue: @"application/json" forHTTPHeaderField: @"Accept"];
    return req;
}


#pragma mark Perform request

- (void) send: (NSMutableURLRequest *)req
     delegate: (id)target
      success: (SEL)successSelector
      failure: (SEL)failureSelector
{
    // Check network reachability
    Reachability *hostReach = [Reachability reachabilityForInternetConnection];
    if ([hostReach currentReachabilityStatus] == NotReachable) {
        [SVProgressHUD showErrorWithStatus: @"Network is no available"];
        return;
    }
    
    NSInvocation *successInvocation = nil;
    NSInvocation *failureInvocation = nil;
    if (target) {
        if (successSelector) {
            NSMethodSignature *successSig = [target methodSignatureForSelector: successSelector];
            if (successSig) {
                successInvocation = [NSInvocation invocationWithMethodSignature: successSig];
                [successInvocation setTarget: target];
                [successInvocation setSelector: successSelector];
            }
        }
        if (failureSelector) {
            NSMethodSignature *failureSig = [target methodSignatureForSelector: failureSelector];
            if (failureSig) {
                failureInvocation = [NSInvocation invocationWithMethodSignature: failureSig];
                [failureInvocation setTarget: target];
                [failureInvocation setSelector: failureSelector];
            }
        }
    }
    
    __block BOOL acceptJson = self.acceptJson;
    
    // Show spinner
    [SVProgressHUD show];
        
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue setName: @"AsyncHttpRequestQueue"];
    
    [NSURLConnection sendAsynchronousRequest: req
                                       queue: queue
                           completionHandler: ^(NSURLResponse *res, NSData *data, NSError *error) {
                               __block NSError *requestError;
                               
                               // If there was an error getting the data
                               if (error) {
                                   requestError = [error copy];
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       [SVProgressHUD showErrorWithStatus: @"Request error"];
                                       [failureInvocation setArgument: &requestError atIndex: 2];
                                       [failureInvocation invoke];
                                   });
                                   return;
                               }
                               
                               if (!acceptJson) {
                                   __block NSData *responseData = [data copy];
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       [SVProgressHUD dismiss];
                                       [successInvocation setArgument: &responseData atIndex: 2];
                                       [successInvocation invoke];
                                   });
                                   return;
                               }
                               
                               // Decode the data from JSON
                               NSError __autoreleasing *jsonError;
                               __block NSDictionary *responseJson = [NSJSONSerialization JSONObjectWithData: data
                                                                                                    options: 0
                                                                                                      error: &jsonError];
                               if (jsonError) {
                                   requestError = [jsonError copy];
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       [SVProgressHUD showErrorWithStatus: @"Response error"];
                                       [failureInvocation setArgument: &requestError atIndex: 2];
                                       [failureInvocation invoke];
                                   });
                                   return;
                               }
                               
                               // All looks fine
                               dispatch_async(dispatch_get_main_queue(), ^{
                                   [SVProgressHUD dismiss];
                                   [successInvocation setArgument: &responseJson atIndex: 2];
                                   [successInvocation invoke];
                               });
                               return;
                           }];
}


#pragma mark Utility methods

+ (NSString *) urlEncode: (id)obj
{
    NSString *string = [NSString stringWithFormat: @"%@", obj];
    return [string stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
}

+ (NSString *) makeQuerystringFromDictionary: (NSDictionary *)dict
{
    NSMutableArray *parts = [NSMutableArray array];
    for (id key in dict) {
        id value = dict[key];
        NSString *part = [NSString stringWithFormat: @"%@=%@",
                          [CCHttpClient urlEncode: key], [CCHttpClient urlEncode: value]];
        [parts addObject: part];
    }
    return [parts componentsJoinedByString: @"&"];
}

@end
