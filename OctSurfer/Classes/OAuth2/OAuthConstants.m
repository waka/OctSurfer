//
//  OAuthConstants.m
//  OctSurfer
//
//  Copyright (c) 2012 yo_waka. All rights reserved.
//

#import "OAuthConstants.h"

@implementation OAuthConstants

NSString *AUTHORIZATION_URL = @"https://github.com/login/oauth/authorize";
NSString *ACCESS_TOKEN_URL  = @"https://github.com/login/oauth/access_token";
NSString *CLIENT_ID         = @"<HERE_IS_CLIENT_ID>";
NSString *CLIENT_SECRET     = @"<HERE_IS_CLIENT_SECRET>";
NSString *SCOPE             = @"user,repo";
NSString *CUSTOM_URL_SCHEME = @"octsurfer";
NSString *CALLBACK_HOST     = @"oauth2";

@end
