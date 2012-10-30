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
@property (nonatomic, strong) NSManagedObjectModel *managedObjectModel;

@end


@implementation CoreDataManager

static NSString * const DB_NAME = @"Model";

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
    
    // Create managed object context
    self.managedObjectContext = [[NSManagedObjectContext alloc] init];
    
    // Set persistent store coordinator
    [self.managedObjectContext setPersistentStoreCoordinator: [self getPersistentStoreCoordinator]];
    
    return self.managedObjectContext;
}

- (NSManagedObjectModel *) getManagedObjectModel
{
    if (self.managedObjectModel) {
        return self.managedObjectModel;
    }
    
    NSString *modelPath = [[NSBundle mainBundle] pathForResource: DB_NAME ofType: @"momd"];
    if (modelPath) {
        NSURL *modelURL = [NSURL fileURLWithPath: modelPath];
        self.managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL: modelURL];
    } else {
        self.managedObjectModel = [NSManagedObjectModel mergedModelFromBundles: nil];
    }
    
    return self.managedObjectModel;
}

- (NSPersistentStoreCoordinator *) getPersistentStoreCoordinator
{
    // Create persistent store coordinator
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc]
                                  initWithManagedObjectModel: [self getManagedObjectModel]];
    
    NSError *error;
    
    // Add persistent store
    NSPersistentStore*  persistentStore;
    persistentStore = [persistentStoreCoordinator addPersistentStoreWithType: NSSQLiteStoreType
                                                               configuration: nil
                                                                         URL: [self getStoreURL]
                                                                     options: nil
                                                                       error: &error];
    // Check has occured error
    if (!persistentStore && error) {
        NSLog(@"Failed to create add persitent store, %@", [error localizedDescription]);
        abort();
    }
    
    return persistentStoreCoordinator;
}

- (NSURL *) getStoreURL
{
    NSURL *appDocumentURL = [[[NSFileManager defaultManager] URLsForDirectory: NSDocumentDirectory inDomains: NSUserDomainMask] lastObject];
    NSURL *storeURL = [appDocumentURL URLByAppendingPathComponent: @"OctSurfer.sqlite"];
    return storeURL;
}

- (void) save
{
    NSError *error;
    NSManagedObjectContext *context = [self getManagedObjectContext];
    if (context != nil) {
        if (![context save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

- (BOOL) isRequiredMigration
{
    NSError *error;
    
    NSDictionary* sourceMetaData;
    sourceMetaData = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType: NSSQLiteStoreType
                                                                                URL: [self getStoreURL]
                                                                              error: &error];
    
    if (sourceMetaData == nil) {
        return NO;
    } else if (error) {
        NSLog(@"Checking migration was failed (%@, %@)", error, [error userInfo]);
        abort();
    }
    
    BOOL isCompatible = [[self getManagedObjectModel] isConfiguration: nil
                                          compatibleWithStoreMetadata: sourceMetaData];
    return !isCompatible;
}

- (BOOL) doMigration
{
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc]
                                  initWithManagedObjectModel: [self getManagedObjectModel]];
    
    NSPersistentStore*  persistentStore;
    NSError *error;
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    persistentStore = [persistentStoreCoordinator addPersistentStoreWithType: NSSQLiteStoreType
                                                               configuration: nil
                                                                         URL: [self getStoreURL]
                                                                     options: options
                                                                       error: &error];
    // Check has occured error
    if (!persistentStore && error) {
        NSLog(@"Failed to create add persitent store, %@", [error localizedDescription]);
        return NO;
    } else {
        return YES;
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
    NSError *error;
    if (![resultsController performFetch: &error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }

    NSArray *fetchedArray = [resultsController fetchedObjects];
    if (fetchedArray.count > 0) {
        AuthEntity *result = fetchedArray[0];
        return result;
    } else {
        return nil;
    }
}

- (void) deleteAuth: (AuthEntity *)auth
{
    NSManagedObjectContext *context = [self getManagedObjectContext];
    [context deleteObject: auth];
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

- (ApiEntity *) findApiByURL: (NSString *)url
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
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"url = %@", url];
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
    NSError *error;
    if (![resultsController performFetch: &error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    NSArray *fetchedArray = [resultsController fetchedObjects];
    if (fetchedArray.count > 0) {
        ApiEntity *result = fetchedArray[0];
        return result;
    } else {
        return nil;
    }
}

- (NSArray *) findApiByPath: (NSString *)path
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
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"path = %@", path];
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
    NSError *error;
    if (![resultsController performFetch: &error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    NSArray *fetchedArray = [resultsController fetchedObjects];
    return fetchedArray;
}

- (void) deleteApiByURL: (NSString *)url
{
    ApiEntity *entity = [self findApiByURL: url];
    if (entity) {
        [[self getManagedObjectContext] deleteObject: entity];
        [self save];
    }
}

- (void) deleteApiByPath: (NSString *)path
{
    NSArray *entities = [self findApiByPath: path];
    if (entities.count > 0) {
        for (ApiEntity *entity in entities) {
            [[self getManagedObjectContext] deleteObject: entity];
        }
        [self save];
    }
}

@end
