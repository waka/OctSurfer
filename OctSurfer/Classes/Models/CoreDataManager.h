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
- (BOOL) isRequiredMigration;
- (BOOL) doMigration;

- (AuthEntity *) insertNewAuth;
- (AuthEntity *) findAuth;
- (void) deleteAuth: (AuthEntity *)auth;

- (ApiEntity *) insertNewApi;
- (ApiEntity *) findApiByURL: (NSString *)url;
- (NSArray *) findApiByPath: (NSString *)path;
- (void) deleteApiByURL: (NSString *)url;
- (void) deleteApiByPath: (NSString *)path;

@end
