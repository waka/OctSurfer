//
//  CCImageCache.m
//  OctSurfer
//
//  Copyright (c) 2012 yo_waka. All rights reserved.
//

#import <CommonCrypto/CommonHMAC.h>
#import "CCImageCache.h"


@interface CCImageCache ()

@property (nonatomic, strong) NSFileManager *fileManager;
@property (nonatomic, strong) NSString *cacheDirectory;
@property (nonatomic, strong) NSCache *cache;
@property (nonatomic, strong) NSOperationQueue *networkQueue;

@end


@implementation CCImageCache

+ (CCImageCache *) sharedInstance
{
    static CCImageCache *sharedInstance;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        sharedInstance = [[CCImageCache alloc] init];
    });
    
    return sharedInstance;
}

- (id) init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(didReceiveMemoryWarning:)
                                                     name: UIApplicationDidReceiveMemoryWarningNotification
                                                   object: nil];
        
        _cache = [[NSCache alloc] init];
        _cache.countLimit = 20;
        
        _fileManager = [[NSFileManager alloc] init];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        _cacheDirectory = [[paths lastObject] stringByAppendingPathComponent: @"Images"];
        
        [self createDirectories];
        
        _networkQueue = [[NSOperationQueue alloc] init];
        [_networkQueue setMaxConcurrentOperationCount: 1];
    }
    return self;
}

- (void) didReceiveMemoryWarning: (NSNotification *)notification
{
    [self clearMemoryCache];
}

- (void) createDirectories
{
    BOOL isDirectory = NO;
    BOOL exists = [self.fileManager fileExistsAtPath: self.cacheDirectory
                                         isDirectory: &isDirectory];
    if (!exists || !isDirectory) {
        [self.fileManager createDirectoryAtPath: self.cacheDirectory
                    withIntermediateDirectories: YES
                                     attributes: nil
                                          error: nil];
    }
    for (int i = 0; i < 16; i++) {
        for (int j = 0; j < 16; j++) {
            NSString *subDir = [NSString stringWithFormat:@"%@/%X%X", self.cacheDirectory, i, j];
            BOOL isDir = NO;
            BOOL existsSubDir = [self.fileManager fileExistsAtPath: subDir isDirectory: &isDir];
            if (!existsSubDir || !isDir) {
                [self.fileManager createDirectoryAtPath: subDir
                            withIntermediateDirectories: YES
                                             attributes: nil
                                                  error: nil];
            }
        }
    }
}


#pragma mark -

+ (NSString *) keyForURL: (NSString *)url
{
	if ([url length] == 0) {
		return nil;
	}
	const char *cStr = [url UTF8String];
	unsigned char result[16];
	CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
	return [NSString stringWithFormat: @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],result[12], result[13], result[14], result[15]];
}

- (NSString *) pathForKey: (NSString *)key
{
    NSString *path = [NSString stringWithFormat: @"%@/%@/%@", self.cacheDirectory, [key substringToIndex: 2], key];
    return path;
}


#pragma mark -

- (UIImage *) cachedImageWithURL: (NSString *)url
{
    NSString *key = [CCImageCache keyForURL: url];
    UIImage *cachedImage = [self.cache objectForKey: key];
    if (cachedImage) {
        return cachedImage;
    }
    
    cachedImage = [UIImage imageWithContentsOfFile: [self pathForKey: key]];
    if (cachedImage) {
        [self.cache setObject: cachedImage forKey: key];
    }
    
    return cachedImage;
}


#pragma mark -

- (void) storeImage: (UIImage *)image data: (NSData *)data URL: (NSString *)url
{
    NSString *key = [CCImageCache keyForURL: url];
    [self.cache setObject: image forKey: key];
    
    [data writeToFile: [self pathForKey: key] atomically: NO];
}

- (void) clearMemoryCache
{
    [self.cache removeAllObjects];
}

- (void) deleteAllCacheFiles
{
    [self.cache removeAllObjects];
    
    if ([self.fileManager fileExistsAtPath: self.cacheDirectory]) {
        if ([self.fileManager removeItemAtPath: self.cacheDirectory error: nil]) {
            [self createDirectories];
        }
    }
    
    BOOL isDirectory = NO;
    BOOL exists = [self.fileManager fileExistsAtPath: self.cacheDirectory isDirectory: &isDirectory];
    if (!exists || !isDirectory) {
        [self.fileManager createDirectoryAtPath: self.cacheDirectory
                    withIntermediateDirectories: YES
                                     attributes: nil
                                          error: nil];
    }
}


#pragma mark -

- (UIImage *) imageWithURL: (NSString *)url block: (ImageResultBlock)block
{
    return [self imageWithURL: url defaultImage: nil block: (ImageResultBlock)block];
}

- (UIImage *) imageWithURL: (NSString *)url defaultImage: (UIImage *)defaultImage block: (ImageResultBlock)block
{
    if (!url) {
        return defaultImage;
    }
    
    UIImage *cachedImage = [self cachedImageWithURL: url];
    if (cachedImage) {
        return cachedImage;
    }
    
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL: [NSURL URLWithString: url]];
    [NSURLConnection sendAsynchronousRequest: req
                                       queue: self.networkQueue
                           completionHandler: ^(NSURLResponse *response, NSData *data, NSError *error) {
                               UIImage *image = [UIImage imageWithData: data];
                               if (image) {
                                   [self storeImage: image data: data URL: url];
                                   block(image, nil);
                               } else {
                                   block(nil, [NSError errorWithDomain: @"ImageCacheErrorDomain" code: 0 userInfo: nil]);
                               }
                           }];

    return defaultImage;
}

@end
