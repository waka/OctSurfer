//
//  filetypes.m
//  OctSurfer
//
//  Copyright (c) 2012 yo_waka. All rights reserved.
//

#import "FileTypes.h"


@implementation FileTypes

static NSDictionary *typeMap;

+ (NSString *) get: (NSString *)path
{
    if (!typeMap) {
        NSBundle *bundle = [NSBundle mainBundle];
        NSString *pfile = [bundle pathForResource: @"FileMap" ofType: @"plist"];
        if (pfile) {
            typeMap = [NSDictionary dictionaryWithContentsOfFile: pfile];
        } else {
            typeMap = nil;
        }
    }
    NSString *ft = @"generic";
    for (id key in typeMap) {
        for (id ext in typeMap[key]) {
            if ([path hasSuffix: ext]) {
                ft = (NSString *)key;
                break;
            }
        }
    }
    return ft;
}

@end
