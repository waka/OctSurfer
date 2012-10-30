//
//  CCBase64.h
//  OctSurfer
//
//  Copyright (c) 2012 yo_waka. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CCBase64 : NSObject

+ (NSString *) encode: (NSString *)src;
+ (NSString *) decode: (NSString *)src;

@end

@interface CCBase64Codec

+ (NSData *) dataFromBase64String: (NSString *)base64String;
+ (NSString *) base64StringFromData: (NSData *)data;

@end