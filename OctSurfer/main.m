//
//  main.m
//  OctSurfer
//
//  Copyright (c) 2012 yo_waka. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"


#if !__has_feature(objc_arc)
#error OctSurfer must be built with ARC.
// You can turn on ARC for only OctSurfer files by adding -fobjc-arc
// to the build phase for each of its files.
#endif


int main(int argc, char *argv[])
{
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
