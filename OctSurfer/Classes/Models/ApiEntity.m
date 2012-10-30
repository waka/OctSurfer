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
@dynamic type;
@dynamic name;
@dynamic url;
@dynamic content;

- (void) setContent: (NSDictionary *)content {
    [self willChangeValueForKey:@"setContent"];
    
    NSData *data = [content messagePack];
    [self setPrimitiveValue: data forKey: @"content"];
    
    [self didChangeValueForKey: @"setContent"];
}

- (NSDictionary *) content {
    NSData *data = [self primitiveValueForKey: @"content"];
    if (!data) {
        return nil;
    }
    return [data messagePackParse];
}

@end
