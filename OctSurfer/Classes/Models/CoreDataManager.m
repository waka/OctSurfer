//
//  CoreDataManager.m
//  OctSurfer
//
//  Copyright (c) 2012 yo_waka. All rights reserved.
//

#import "CoreDataManager.h"
#import "AuthEntity.h"
#import "ApiEntity.h"


@interface CoreDataManager ()

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end


@implementation CoreDataManager

+ (CoreDataManager *) sharedManager
{
    static CoreDataManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[CoreDataManager alloc] init];
    });
    return sharedInstance;
}

- (NSManagedObjectContext *) getManagedObjectContext
{
    if (self.managedObjectContext) {
        return self.managedObjectContext;
    }
    
    // Create managed object model
    NSManagedObjectModel *managedObjectModel = [NSManagedObjectModel mergedModelFromBundles: nil];
    
    // Create persistent store coordinator
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc]
                                  initWithManagedObjectModel: managedObjectModel];
    
    // Decide saved file
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = nil;
    if ([paths count] > 0) {
        path = [paths objectAtIndex: 0];
        path = [path stringByAppendingPathComponent: @"octsurfer"];
        path = [path stringByAppendingPathComponent: @"octsurfer.db"];
    }
    
    if (!path) {
        return nil;
    }
    
    NSError __autoreleasing *error;
    
    // Make directory
    NSString *dirPath = [path stringByDeletingLastPathComponent];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:dirPath]) {
        if (![fileManager createDirectoryAtPath: dirPath
                    withIntermediateDirectories: YES
                                     attributes: nil
                                          error: &error]) {
            NSLog(@"Failed to create directory at path %@, erro %@", dirPath, [error localizedDescription]);
        }
    }
    
    // Make store url
    NSURL *url = [NSURL fileURLWithPath: path];
    
    // Add persistent store
    NSPersistentStore*  persistentStore;
    persistentStore = [persistentStoreCoordinator addPersistentStoreWithType: NSSQLiteStoreType
                                                               configuration: nil
                                                                         URL: url
                                                                     options: nil
                                                                       error: &error];
    if (!persistentStore && error) {
        NSLog(@"Failed to create add persitent store, %@", [error localizedDescription]);
    }
    
    // Create managed object context
    self.managedObjectContext = [[NSManagedObjectContext alloc] init];
    
    // Set persistent store coordinator
    [self.managedObjectContext setPersistentStoreCoordinator: persistentStoreCoordinator];
    
    return self.managedObjectContext;
}

- (void) save
{
    NSManagedObjectContext *context = [self getManagedObjectContext];
    NSError __autoreleasing *error;
    if (![context save: &error]) {
        NSLog(@"Error, %@", error);
    }
}


#pragma mark - Auth entity

- (AuthEntity *) insertNewAuth
{
    NSManagedObjectContext *context = [self getManagedObjectContext];
    
    // Create Auth entity
    AuthEntity *auth = [NSEntityDescription insertNewObjectForEntityForName: @"AuthEntity"
                                               inManagedObjectContext: context];
    
    // Create identifier
    CFUUIDRef uuid = CFUUIDCreate(NULL);
    NSString *identifier = (__bridge NSString *)CFUUIDCreateString(NULL, uuid);
    CFRelease(uuid);
    auth.identifier = identifier;
    
    return auth;
}

- (AuthEntity *) findAuth
{
    NSManagedObjectContext *context = [self getManagedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];

    // Set entity for getting
    NSEntityDescription *entityDescription;
    entityDescription = [NSEntityDescription entityForName: @"AuthEntity" inManagedObjectContext: context];
    [fetchRequest setEntity: entityDescription];
    
    // Set sort descriptor
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey: @"identifier" ascending: YES];
    [fetchRequest setSortDescriptors: @[sort]];

    // Set limit
    [fetchRequest setFetchBatchSize: 1];

    // Create fetched controller
    NSFetchedResultsController *resultsController;
    resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest: fetchRequest
                                                            managedObjectContext: context
                                                              sectionNameKeyPath: nil
                                                                       cacheName: @"AuthEntity"];

    // Get from DB
    NSError __autoreleasing *error;
    if (![resultsController performFetch: &error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }

    NSArray *fetchedArray = [resultsController fetchedObjects];
    if (fetchedArray.count > 1) {
        AuthEntity *result = fetchedArray[0];
        return result;
    } else {
        return nil;
    }
}

- (void) deleteAuth
{
    // ToDo implemention
}


#pragma mark - Api entity

- (ApiEntity *) insertNewApi
{
    NSManagedObjectContext *context = [self getManagedObjectContext];
    
    // Create Auth entity
    ApiEntity *api = [NSEntityDescription insertNewObjectForEntityForName: @"ApiEntity"
                                                   inManagedObjectContext: context];
    
    // Create identifier
    CFUUIDRef uuid = CFUUIDCreate(NULL);
    NSString *identifier = (__bridge NSString *)CFUUIDCreateString(NULL, uuid);
    CFRelease(uuid);
    api.identifier = identifier;
    
    return api;
}

- (ApiEntity *) findApi: (NSString *)type name: (NSString *)name url: (NSString *)url
{
    NSManagedObjectContext *context = [self getManagedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // Set entity for getting
    NSEntityDescription *entityDescription;
    entityDescription = [NSEntityDescription entityForName: @"ApiEntity" inManagedObjectContext: context];
    [fetchRequest setEntity: entityDescription];
    
    // Set sort descriptor
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey: @"identifier" ascending: YES];
    [fetchRequest setSortDescriptors: @[sort]];
    
    // Set condition
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"type = %@ and name = %@ and url = %@", type, name, url];
    [fetchRequest setPredicate: pred];
    
    // Set limit
    [fetchRequest setFetchBatchSize: 1];
    
    // Create fetched controller
    NSFetchedResultsController *resultsController;
    resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest: fetchRequest
                                                            managedObjectContext: context
                                                              sectionNameKeyPath: nil
                                                                       cacheName: @"ApiEntity"];
    
    // Get from DB
    NSError __autoreleasing *error;
    if (![resultsController performFetch: &error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    NSArray *fetchedArray = [resultsController fetchedObjects];
    if (fetchedArray.count > 1) {
        ApiEntity *result = fetchedArray[0];
        return result;
    } else {
        return nil;
    }
}

- (void) deleteApi: (NSString *) type name: (NSString *)name
{
    // ToDo implemention
}

@end
