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

+ (NSString *) searchRepository: (NSString *)keyword
{
    NSString *path = [NSString stringWithFormat: @"legacy/repos/search/%@", keyword];
    return [ApiUrl api: path];
}

+ (NSString *) masterBranch: (NSString *) owner repository: (NSString *)repo
{
    NSString *path = [NSString stringWithFormat: @"repos/%@/%@/branches/master", owner, repo];
    return [ApiUrl api: path];
}

+ (NSString *) blob: (NSString *) owner repository: (NSString *)repo sha: (NSString *)sha
{
    NSString *path = [NSString stringWithFormat: @"/repos/%@/%@/git/blobs/:sha", owner, repo];
    return [ApiUrl api: path];
}

+ (NSString *) starredRepository
{
    NSString *path = @"user/starred";
    return [ApiUrl api: path];
}

+ (NSString *) authenticatedUser
{
    NSString *path = @"user";
    return [ApiUrl api: path];
}

@end
