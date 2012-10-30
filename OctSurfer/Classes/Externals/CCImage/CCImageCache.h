//
//  CCImageCache.h
//  OctSurfer
//
//  Copyright (c) 2012 yo_waka. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef void (^ImageResultBlock)(UIImage *image, NSError *error);


/**
 * UIImage *cachedIconImage = [[CCImageCache sharedInstance] imageWithURL: userIconURL
 *                                                           defaultImage: [UIImage imageNamed:@"loading.png"]
 *                                                                  block: ^(UIImage *image, NSError *error) {
 *                                                                      if (error) {
 *                                                                          cell.userIcon = [UIImage imageNamed:@"defaultIcon.png"];
 *                                                                      } else {
 *                                                                          cell.userIcon = image;
 *                                                                      }
 *                                                                  }];
 *
 * cell.userIcon = cachedIconImage;
 */
@interface CCImageCache : NSObject

+ (CCImageCache *) sharedInstance;

- (UIImage *) imageWithURL: (NSString *)url block: (ImageResultBlock)block;
- (UIImage *) imageWithURL: (NSString *)url defaultImage: (UIImage *)defaultImage block: (ImageResultBlock)block;

- (void) clearMemoryCache;
- (void) deleteAllCacheFiles;

@end
