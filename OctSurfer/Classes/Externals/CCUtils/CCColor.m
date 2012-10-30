//
//  CCColor.m
//  OctSurfer
//
//  Copyright (c) 2012 yo_waka. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "CCColor.h"


@implementation CCColor

+ (UIColor*) hexToUIColor: (NSString *)hex alpha: (CGFloat)a
{
	NSScanner *colorScanner = [NSScanner scannerWithString: hex];
	unsigned int color;
	[colorScanner scanHexInt:&color];
	CGFloat r = ((color & 0xFF0000) >> 16) / 255.0f;
	CGFloat g = ((color & 0x00FF00) >> 8) / 255.0f;
	CGFloat b =  (color & 0x0000FF) / 255.0f;
	return [UIColor colorWithRed: r green: g blue: b alpha: a];
}

@end
