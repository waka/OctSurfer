//
//  CCHttpClient.h
//  OctSurfer
//
//  Copyright (c) 2012 yo_waka. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CCHttpClient : NSObject

#pragma mark Initialize methods

+ (id) clientWithUrl: (NSString *)url;
- (id) initWithUrl: (NSString *)url;


#pragma mark Utility methods

+ (NSString *) urlEncode: (id)obj;
+ (NSString *) makeQuerystringFromDictionary: (NSDictionary *)dict;
+ (id) responseJSON: (NSData *)data;


#pragma mark Instance methods

- (void) getWithDelegate: (NSDictionary *)params
                 headers: (NSDictionary *)headers
                 delegate: (id)target
                 success: (SEL)successSelector
                 failure: (SEL)failureSelector;

// JSONを"GET"したいとき
- (void) getJsonWithDelegate: (NSDictionary *)params
                     headers: (NSDictionary *)headers
                    delegate: (id)target
                     success: (SEL)successSelector
                     failure: (SEL)failureSelector;

- (void) postWithDelegate: (NSDictionary *)params
                  headers: (NSDictionary *)headers
                 delegate: (id)target
                  success: (SEL)successSelector
                  failure: (SEL)failureSelector;

// JSONを"POST"したいとき
- (void) postJsonWithDelegate: (NSDictionary *)params
                      headers: (NSDictionary *)headers
                     delegate: (id)target
                      success: (SEL)successSelector
                      failure: (SEL)failureSelector;

- (void) putWithDelegate: (NSDictionary *)headers
                delegate: (id)target
                 success: (SEL)successSelector
                 failure: (SEL)failureSelector;

- (void) deleteWithDelegate: (NSDictionary *)headers
                   delegate: (id)target
                    success: (SEL)successSelector
                    failure: (SEL)failureSelector;

@end
