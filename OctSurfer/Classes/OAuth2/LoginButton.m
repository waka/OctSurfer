//
//  LoginButton.m
//  OctSurfer
//
//  Copyright (c) 2012 yo_waka. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "LoginButton.h"
#import "CCColor.h"


@implementation LoginButton

- (id)initWithFrame: (CGRect)frame
{
    self = [super initWithFrame: frame];
    if (self) {
        self.titleLabel.font = [UIFont boldSystemFontOfSize: 14];
        self.titleLabel.shadowOffset = CGSizeMake(0.0, 1.0);
        [self setTitleColor: [UIColor grayColor] forState: UIControlStateNormal];
        [self setTitleShadowColor: [UIColor whiteColor] forState: UIControlStateNormal];
        [self setTitleColor: [UIColor grayColor] forState: UIControlStateHighlighted];
        [self setTitleShadowColor: [UIColor whiteColor] forState: UIControlStateHighlighted];
    }
    return self;
}

- (void)drawRect: (CGRect)rect
{
    [self.layer setMasksToBounds: YES];
    [self.layer setCornerRadius: 10.0f];
    [self.layer setBorderColor: [CCColor hexToUIColor: @"AAAAAA" alpha: 1.0].CGColor];
    [self.layer setBorderWidth: 1.0];
    
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGFloat w = self.bounds.size.width;
    CGFloat h = self.bounds.size.height;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextSaveGState(c);
    CGContextSetShouldAntialias(c, true);
    
    // CGGradientを生成する
    // 生成するためにCGColorSpaceと色データの配列が必要になるので適当に用意する
    CGFloat locations[2] = {0.0, 1.0};
    size_t num_locations = 2;
    CGGradientRef gradient;
    if (self.state && (UIControlStateSelected || UIControlStateHighlighted)) {
        CGFloat components[8] = {0.85, 0.85, 0.85, 1.0, 0.68, 0.68, 0.68, 1.0};
        gradient = CGGradientCreateWithColorComponents(colorSpace, components, locations, num_locations);
    } else {
        CGFloat components[8] = {0.9, 0.9, 0.9, 1.0, 0.73, 0.73, 0.73, 1.0};
        gradient = CGGradientCreateWithColorComponents(colorSpace, components, locations, num_locations);
    }
    
    // 生成したCGGradientを描画する
    // 始点と終点を指定してやると、その間に直線的なグラデーションが描画される。
    CGPoint startPoint = CGPointMake(w / 2, 0.0);
    CGPoint endPoint = CGPointMake(w / 2, h);
    CGContextDrawLinearGradient(c, gradient, startPoint, endPoint, 0);
    
    CGContextRestoreGState(c);
    
    [super drawRect: rect];
}

- (void) setHighlighted: (BOOL)value
{
    [super setHighlighted: value];
    [self setNeedsDisplay];
}

- (void) setSelected: (BOOL)value
{
    [super setSelected: value];
    [self setNeedsDisplay];
}

@end
