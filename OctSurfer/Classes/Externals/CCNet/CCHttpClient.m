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

@property (nonatomic, strong) NSString *url;

- (NSMutableURLRequest *) createGetRequest: (NSDictionary *)params;
- (NSMutableURLRequest *) createPostRequest;
- (NSMutableURLRequest *) createPutRequest;
- (NSMutableURLRequest *) createDeleteRequest;
- (void) setRequestHeaders: (NSMutableURLRequest *)req headers: (NSDictionary *)headers;

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
    }
    return self;
}

- (void) setRequestHeaders: (NSMutableURLRequest *)req headers: (NSDictionary *)headers
{
    if (!headers) {
        return;
    }
    for (id key in headers) {
        [req setValue: key forHTTPHeaderField: [headers objectForKey: key]];
    }
}


#pragma mark Get request methods

- (void) getWithDelegate: (NSDictionary *)params
                 headers: (NSDictionary *)headers
                delegate: (id)target
                 success: (SEL)successSelector
                 failure: (SEL)failureSelector
{
    NSMutableURLRequest *req = [self createGetRequest: params];
    [self setRequestHeaders: req headers: headers];

    [self send: req delegate: target success: successSelector failure: failureSelector];
}

- (void) getJsonWithDelegate: (NSDictionary *)params
                     headers: (NSDictionary *)headers
                    delegate: (id)target
                     success: (SEL)successSelector
                     failure: (SEL)failureSelector
{
    NSMutableURLRequest *req = [self createGetRequest: params];
    [self setRequestHeaders: req headers: headers];
    [req setValue: @"application/json" forHTTPHeaderField: @"Content-Type"];

    [self send: req delegate: target success: successSelector failure: failureSelector];
}

- (NSMutableURLRequest *) createGetRequest: (NSDictionary *)params
{
    NSMutableString *urlString = [[NSMutableString alloc] initWithString: self.url];
    if (params) {
        [urlString appendString: @"?"];
        [urlString appendString: [CCHttpClient makeQuerystringFromDictionary: params]];
    }
    
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL: [NSURL URLWithString: urlString]
                                                       cachePolicy: NSURLRequestUseProtocolCachePolicy
                                                   timeoutInterval: 30.0];
    [req setHTTPMethod: @"GET"];
    return req;
}


#pragma mark Post request methods

- (void) postWithDelegate: (NSDictionary *)params
                  headers: (NSDictionary *)headers
                 delegate: (id)target
                  success: (SEL)successSelector
                  failure: (SEL)failureSelector
{
    NSMutableURLRequest *req = [self createPostRequest];
    [self setRequestHeaders: req headers: headers];

    if (params) {
        NSString *postString = [CCHttpClient makeQuerystringFromDictionary: params];
        NSData *postData = [NSData dataWithBytes: [postString UTF8String]
                                          length: [postString length]];
        [req setValue: [NSString stringWithFormat: @"%d", [postString length]] forHTTPHeaderField: @"Content-Length"];
        [req setHTTPBody: postData];
    }

    [self send: req delegate: target success: successSelector failure: failureSelector];
}

- (void) postJsonWithDelegate: (NSDictionary *)params
                      headers: (NSDictionary *)headers
                     delegate: (id)target
                      success: (SEL)successSelector
                      failure: (SEL)failureSelector
{
    NSMutableURLRequest *req = [self createPostRequest];
    [self setRequestHeaders: req headers: headers];
    
    if (params) {
        NSError *jsonError = nil;
        NSData *postData = [NSJSONSerialization dataWithJSONObject: params
                                                           options: NSJSONWritingPrettyPrinted
                                                             error: &jsonError];
        int contentLength = [[[NSString alloc] initWithData: postData encoding: NSUTF8StringEncoding] length];
        [req setValue: [NSString stringWithFormat: @"%d", contentLength] forHTTPHeaderField: @"Content-Length"];
        [req setHTTPBody: postData];
    }
    [self send: req delegate: target success: successSelector failure: failureSelector];
}

- (NSMutableURLRequest *) createPostRequest
{
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL: [NSURL URLWithString: self.url]
                                                       cachePolicy: NSURLRequestUseProtocolCachePolicy
                                                   timeoutInterval: 30.0];
    [req setHTTPMethod: @"POST"];
    return req;
}


#pragma mark Put request methods

- (void) putWithDelegate: (NSDictionary *)headers
                delegate: (id)target
                 success: (SEL)successSelector
                 failure: (SEL)failureSelector
{
    NSMutableURLRequest *req = [self createPutRequest];
    [self setRequestHeaders: req headers: headers];
    [self send: req delegate: target success: successSelector failure: failureSelector];
}

- (NSMutableURLRequest *) createPutRequest
{
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL: [NSURL URLWithString: self.url]
                                                       cachePolicy: NSURLRequestUseProtocolCachePolicy
                                                   timeoutInterval: 30.0];
    [req setHTTPMethod: @"PUT"];
    return req;
}


#pragma mark Delete request methods

- (void) deleteWithDelegate: (NSDictionary *)headers
                   delegate: (id)target
                    success: (SEL)successSelector
                    failure: (SEL)failureSelector
{
    NSMutableURLRequest *req = [self createDeleteRequest];
    [self setRequestHeaders: req headers: headers];
    [self send: req delegate: target success: successSelector failure: failureSelector];
}

- (NSMutableURLRequest *) createDeleteRequest
{
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL: [NSURL URLWithString: self.url]
                                                       cachePolicy: NSURLRequestUseProtocolCachePolicy
                                                   timeoutInterval: 30.0];
    [req setHTTPMethod: @"DELETE"];
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
    
    // Show spinner
    [SVProgressHUD show];
        
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue setName: @"AsyncHttpRequestQueue"];
    
    [NSURLConnection sendAsynchronousRequest: req
                                       queue: queue
                           completionHandler: ^(NSURLResponse *res, NSData *data, NSError *error) {
                               __block NSHTTPURLResponse *response = [(NSHTTPURLResponse *)res copy];
                               
                               // If there was an error getting the data
                               if (error) {
                                   __block NSError *requestError = [error copy];
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       [SVProgressHUD dismiss];
                                       [failureInvocation setArgument: &response atIndex: 2];
                                       [failureInvocation setArgument: &requestError atIndex: 3];
                                       [failureInvocation invoke];
                                       
                                       response = nil;
                                       requestError = nil;
                                   });
                                   return;
                               }

                               //success => 200, 201, 202, 204, 304
                               int statusCode = response.statusCode;
                               if (statusCode == 200 || statusCode == 201 || statusCode == 202 || statusCode == 204 || statusCode == 304) {
                                   __block NSData *responseData = [data copy];
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       [SVProgressHUD dismiss];
                                       [successInvocation setArgument: &response atIndex: 2];
                                       [successInvocation setArgument: &responseData atIndex: 3];
                                       [successInvocation invoke];
                                       
                                       response = nil;
                                       responseData = nil;
                                   });
                               } else {
                                   __block NSError *responseError = [NSError errorWithDomain: @"CCHttpClient"
                                                                                        code: 1000
                                                                                    userInfo: nil];
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       [SVProgressHUD dismiss];
                                       [failureInvocation setArgument: &response atIndex: 2];
                                       [failureInvocation setArgument: &responseError atIndex: 3];
                                       [failureInvocation invoke];
                                       
                                       response = nil;
                                       responseError = nil;
                                   });
                               }
                           }];
}


#pragma mark Utility methods

+ (NSString *) urlEncode: (id)obj
{
    NSString *string = [NSString stringWithFormat: @"%@", obj];
    return [string stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
}

+ (NSString *) makeQuerystringFromDictionary: (NSDictionary *)params
{
    NSMutableArray *parts = [NSMutableArray array];
    for (id key in params) {
        id value = params[key];
        NSString *part = [NSString stringWithFormat: @"%@=%@",
                          [CCHttpClient urlEncode: key], [CCHttpClient urlEncode: value]];
        [parts addObject: part];
    }
    return [parts componentsJoinedByString: @"&"];
}


+ (id) responseJSON: (NSData *)data
{
    // Decode the data from JSON
    NSError *jsonError;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData: data
                                                         options: 0
                                                           error: &jsonError];
    return (jsonError) ? nil : json;
}

@end

