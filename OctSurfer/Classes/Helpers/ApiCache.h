//
//  ApiCache.h
//  OctSurfer
//
//  Copyright (c) 2012 yo_waka. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ApiCache : NSObject

+ (id) get: (NSString *)url;
+ (void) set: (NSString *)url path: (NSString *)path value: (id)data;

@end
