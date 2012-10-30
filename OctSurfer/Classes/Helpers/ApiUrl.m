//
//  ApiUrl.m
//  OctSurfer
//
//  Copyright (c) 2012 yo_waka. All rights reserved.
//

#import "ApiUrl.h"
#import "AppConfig.h"


@implementation ApiUrl

NSString * const GitHubApiURL = @"https://api.github.com/";

+ (NSString *) api: (NSString *)path
{
    NSMutableString *url = [GitHubApiURL mutableCopy];
    [url appendString: path];
    NSString *accessToken = [AppConfig getAccessToken];
    if (accessToken) {
        [url appendString: [NSString stringWithFormat: @"?access_token=%@", accessToken]];
    }
    return url;
}


+ (NSString *) repositorySearch: (NSString *)keyword
{
    NSString *path = [NSString stringWithFormat: @"legacy/repos/search/%@", keyword];
    return [ApiUrl api: path];
}

+ (NSString *) userSearch: (NSString *)keyword
{
    NSString *path = [NSString stringWithFormat: @"legacy/user/search/%@", keyword];
    return [ApiUrl api: path];
}

+ (NSString *) masterBranch: (NSString *) owner repository: (NSString *)repo calling: (BOOL)calling
{
    NSString *path = [NSString stringWithFormat: @"repos/%@/%@/branches/master", owner, repo];
    return (calling) ? [ApiUrl api: path] : path;
}

+ (NSString *) blob: (NSString *) owner repository: (NSString *)repo sha: (NSString *)sha
{
    NSString *path = [NSString stringWithFormat: @"/repos/%@/%@/git/blobs/:sha", owner, repo];
    return [ApiUrl api: path];
}

+ (NSString *) authenticatedUser: (BOOL) calling
{
    NSString *path = @"user";
    return (calling) ? [ApiUrl api: path] : path;
}

+ (NSString *) authenticatedUserStarred: (BOOL) calling
{
    NSString *path = @"user/starred";
    return (calling) ? [ApiUrl api: path] : path;
}

+ (NSString *) authenticatedUserOrganizations: (BOOL) calling
{
    NSString *path = @"user/orgs";
    return (calling) ? [ApiUrl api: path] : path;
}

+ (NSString *) orgRepositories: (NSString *) org calling: (BOOL) calling
{
    NSString *path = [NSString stringWithFormat: @"orgs/%@/repos", org];
    return (calling) ? [ApiUrl api: path] : path;
}

+ (NSString *) starred: (NSString *) owner repository: (NSString *)repo calling: (BOOL) calling
{
    NSString *path = [NSString stringWithFormat: @"user/starred/%@/%@", owner, repo];
    return (calling) ? [ApiUrl api: path] : path;
}

@end
