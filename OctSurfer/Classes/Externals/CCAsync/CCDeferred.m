//
//  CCDeferred.m
//  Async
//
//  Copyright (c) 2012 yo_waka. All rights reserved.
//

#import "CCDeferred.h"


/**
 * Prototype of private properties and methods.
 */

@interface CCDeferred()

// Using ARC properties

@property (nonatomic, strong) id result;
@property (nonatomic, unsafe_unretained) DeferredState state;
@property (nonatomic, strong) NSMutableArray *chain;

- (void) fire: (id)valueObject;

@end


/**
 * Deferred implementation.
 */

@implementation CCDeferred

- (id) init
{
    self = [super init];
    if (self) {
        self.result = nil;
        self.state = Unresolved;
        self.chain = [NSMutableArray array];
    }
    return self;
}

+ (CCDeferred *) defer
{
    return [[self alloc] init];
}

- (void) resolve: (id)valueObject
{
    self.state = Resolved;
    [self fire: valueObject];
}

- (void) reject: (id)valueObject
{
    self.state = Rejected;
    [self fire: valueObject];
}

- (CCDeferred *) then: (CallbackBlock)cb
{
    return [self then: cb failure: nil];
}

- (CCDeferred *) then: (CallbackBlock)cb failure: (ErrBackBlock)eb
{
    NSMutableArray *arr = [NSMutableArray array];
    if (cb) {
        [arr addObject: cb];
    } else {
        [arr addObject: [NSNull null]];
    }
    if (eb) {
        [arr addObject: eb];
    } else {
        [arr addObject: [NSNull null]];
    }
    [self.chain addObject: arr];
    
    if (self.state != Unresolved) {
        [self fire: nil];
    }
    return self;
}

- (CCDeferred *) next: (CallbackBlock)cb
{
    return [self next: cb failure: nil];
}

- (CCDeferred *) next: (CallbackBlock)cb failure:(ErrBackBlock)eb
{
    CCDeferred *deferred = [CCDeferred defer];
    __weak CCDeferred *wd = deferred;
    
    [self then: ^id(id resultObject) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [wd resolve: cb(resultObject)];
        });
        return resultObject;
    } failure: ^id(id resultObject) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [wd reject: eb(resultObject)];
        });
        return resultObject;
    }];
    
    return deferred;
}

- (BOOL) isResolved
{
    return self.state == Resolved;
}

- (BOOL) isRejected
{
    return self.state == Rejected;
}

- (void) fire: (id)valueObject
{
    id res = self.result = (valueObject != nil) ? valueObject : self.result;
    
    while ([self.chain count] > 0) {
        NSArray *entry = self.chain[0];
        [self.chain removeObjectAtIndex: 0];
        
        CallbackBlock fn = [self isRejected] ? entry[1] : entry[0];
        if (fn) {
            @try {
                res = self.result = fn(res);
            }
            @catch (NSException *ex) {
                self.state = Rejected;
                res = self.result = ex;
            }
        }
    }
}

@end
