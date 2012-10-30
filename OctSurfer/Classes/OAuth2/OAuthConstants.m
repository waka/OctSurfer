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
NSString *CLIENT_ID         = @"41ae81cfa9970b917d75";
NSString *CLIENT_SECRET     = @"6c12ea4f83e93ff837bd593020c62ad3aa0141ec";
NSString *SCOPE             = @"user,repo";
NSString *CUSTOM_URL_SCHEME = @"octsurfer";
NSString *CALLBACK_HOST     = @"oauth2";

@end
