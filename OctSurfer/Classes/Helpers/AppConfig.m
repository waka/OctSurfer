//
//  AppConfig.m
//  OctSurfer
//
//  Copyright (c) 2012 yo_waka. All rights reserved.
//

#import "AppConfig.h"
#import "CoreDataManager.h"
#import "AuthEntity.h"


@interface AppConfig ()

@property (nonatomic, strong) NSMutableDictionary *map;

@end


@implementation AppConfig

+ (AppConfig *) getSingleton
{
    static AppConfig *sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[AppConfig alloc] init];
        sharedInstance.map = [NSMutableDictionary dictionary];
    });
    return sharedInstance;
}

+ (void) set: (NSString *)key value: (NSString *)value
{
    AppConfig *ac = [AppConfig getSingleton];
    [ac.map setObject: value forKey: key];
}

+ (id) get: (NSString *)key
{
    AppConfig *ac = [AppConfig getSingleton];
    return [ac.map objectForKey: key];
}

+ (void) remove: (NSString *)key
{
    AppConfig *ac = [AppConfig getSingleton];
    [ac.map removeObjectForKey: key];
}

+ (NSString *) getAccessToken
{
    NSString *accessToken = [AppConfig get: @"accessToken"];
    if (accessToken) {
        return accessToken;
    }
    
    AuthEntity *auth = [[CoreDataManager sharedManager] findAuth];
    if (auth) {
        [AppConfig set: @"accessToken" value: auth.accessToken];
        return auth.accessToken;
    } else {
        return nil;
    }
}


@end
