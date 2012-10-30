//
//  CCDeferred.h
//  Async
//
//  Copyright (c) 2012 yo_waka. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 * Callback blocks.
 */

typedef id (^CallbackBlock)(id resultObject);
typedef id (^ErrBackBlock)(id resultObject);


/**
 * Definition of Promise/A interface.
 */

@protocol Promise

@required
- (void) resolve: (id)valueObject;
- (void) reject: (id)valueObject;
- (id) then: (CallbackBlock)cb failure: (ErrBackBlock)eb;

@end


/**
 * Deferred states.
 */

typedef enum {
    Unresolved,
    Resolved,
    Rejected
} DeferredState;


/**
 * Deferred must be implemented Promise/A interface.
 */

@interface CCDeferred : NSObject<Promise>

// Class methods

+ (CCDeferred *) defer;

// Instance methods

- (CCDeferred *) then: (CallbackBlock)cb;
- (CCDeferred *) next: (CallbackBlock)cb;
- (CCDeferred *) next: (CallbackBlock)cb failure: (ErrBackBlock)eb;
- (BOOL) isResolved;
- (BOOL) isRejected;

@end
