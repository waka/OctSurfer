//
//  ApiCache.m
//  OctSurfer
//
//  Copyright (c) 2012 yo_waka. All rights reserved.
//

#import "ApiCache.h"
#import "CoreDataManager.h"
#import "ApiEntity.h"


@implementation ApiCache

+ (id) get: (NSString *)url
{
    ApiEntity *entity = [[CoreDataManager sharedManager] findApiByURL: url];
    if (entity) {
        return [entity content];
    } else {
        return nil;
    }
}

+ (void) set: (NSString *)url path:(NSString *)path value: (id)data
{
    [[CoreDataManager sharedManager] deleteApiByURL: url];
    [[CoreDataManager sharedManager] save];
    
    ApiEntity *entity = [[CoreDataManager sharedManager] insertNewApi];
    entity.url = url;
    if (path) {
        entity.path = path;
    }
    [entity setContent: data];
    [[CoreDataManager sharedManager] save];
}

@end
