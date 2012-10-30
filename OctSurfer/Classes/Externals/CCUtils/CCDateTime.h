//
//  CCDateTime.h
//  OctSurfer
//
//  Copyright (c) 2012 yo_waka. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CCDateTime : NSObject

+ (NSString *) prettyPrint: (NSDate *)dt;
+ (NSDate *) dateFromString: (NSString *)dateStr;

@end
