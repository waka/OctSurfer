//
//  ApiUrl.h
//  OctSurfer
//
//  Copyright (c) 2012 yo_waka. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ApiUrl : NSObject

+ (NSString *) api: (NSString *)path;
+ (NSString *) searchRepository: (NSString *)keyword;
+ (NSString *) masterBranch: (NSString *) owner repository: (NSString *)name;
+ (NSString *) blob: (NSString *) owner repository: (NSString *)repo sha: (NSString *)sha;
+ (NSString *) starredRepository;
+ (NSString *) authenticatedUser;

@end
