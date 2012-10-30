//
//  CCHttpClient.h
//  OctSurfer
//
//  Copyright (c) 2012 yo_waka. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CCHttpClient : NSObject

#pragma mark Properties

@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSDictionary *params;

#pragma mark Class methods

+ (id) clientWithUrl: (NSString *)url;

+ (NSString *) urlEncode: (id)obj;
+ (NSString *) makeQuerystringFromDictionary: (NSDictionary *)dict;

#pragma mark Instance methods

- (id) initWithUrl: (NSString *)url;

- (void) getWithDelegate: (id)target
                 success: (SEL)successSelector
                 failure: (SEL)failureSelector;

- (void) getJsonWithDelegate: (id)target
                     success: (SEL)successSelector
                     failure: (SEL)failureSelector;

- (void) postWithDelegate: (id)target
                  success: (SEL)successSelector
                  failure: (SEL)failureSelector;

- (void) postJsonWithDelegate: (id)target
                      success: (SEL)successSelector
                      failure: (SEL)failureSelector;

@end
