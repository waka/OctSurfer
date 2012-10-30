//
//  ApiEntity.m
//  OctSurfer
//
//  Copyright (c) 2012 yo_waka. All rights reserved.
//

#import "ApiEntity.h"
#import "MessagePack.h"


@implementation ApiEntity

@dynamic identifier;
@dynamic url;
@dynamic path;
@dynamic content;

- (void) setContent: (id)content {
    [self willChangeValueForKey: @"setContent"];
    
    NSData *data = [content messagePack];
    [self setPrimitiveValue: data forKey: @"content"];
    [self didChangeValueForKey: @"setContent"];
}

- (id) content {
    NSData *data = [self primitiveValueForKey: @"content"];
    if (!data) {
        return nil;
    }
    return [data messagePackParse];
}

@end
