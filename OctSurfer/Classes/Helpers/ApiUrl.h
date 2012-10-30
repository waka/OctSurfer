//
//  ApiUrl.h
//  OctSurfer
//
//  Copyright (c) 2012 yo_waka. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ApiUrl : NSObject

+ (NSString *) api: (NSString *)path;
+ (NSString *) repositorySearch: (NSString *)keyword;
+ (NSString *) userSearch: (NSString *)keyword;
+ (NSString *) masterBranch: (NSString *) owner repository: (NSString *)name calling: (BOOL)calling;
+ (NSString *) blob: (NSString *) owner repository: (NSString *)repo sha: (NSString *)sha;
+ (NSString *) authenticatedUser: (BOOL)calling;
+ (NSString *) authenticatedUserStarred: (BOOL)calling;
+ (NSString *) authenticatedUserOrganizations: (BOOL)calling;
+ (NSString *) orgRepositories: (NSString *) org calling: (BOOL)calling;
+ (NSString *) starred: (NSString *) owner repository: (NSString *)repo calling: (BOOL) calling;

@end
