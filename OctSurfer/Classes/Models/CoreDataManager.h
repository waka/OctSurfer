//
//  CoreDataManager.h
//  OctSurfer
//
//  Copyright (c) 2012 yo_waka. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@class AuthEntity;
@class ApiEntity;


@interface CoreDataManager : NSObject

/**
 * Class methods
 */

+ (CoreDataManager *) sharedManager;


/**
 * Instance methods
 */

- (NSManagedObjectContext *) getManagedObjectContext;
- (void) save;

- (AuthEntity *) insertNewAuth;
- (AuthEntity *) findAuth;
- (void) deleteAuth;

- (ApiEntity *) insertNewApi;
- (ApiEntity *) findApi: (NSString *)type name: (NSString *)name url: (NSString *)url;
- (void) deleteApi: (NSString *) type name: (NSString *)name;

@end
