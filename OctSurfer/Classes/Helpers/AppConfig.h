//
//  AppConfig.h
//  OctSurfer
//
//  Copyright (c) 2012 yo_waka. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface AppConfig : NSObject

/**
 * Class methods
 */

+ (void) set: (NSString *)key value: (NSString *)value;
+ (id) get: (NSString *)key;
+ (void) remove: (NSString *)key;

+ (NSString *) getAccessToken;

@end
