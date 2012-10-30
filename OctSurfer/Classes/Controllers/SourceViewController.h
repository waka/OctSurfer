//
//  SourceViewController.h
//  OctSurfer
//
//  Copyright (c) 2012 yo_waka. All rights reserved.
//

#import "AbstractViewController.h"


@interface SourceViewController : AbstractViewController <UIWebViewDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *url;

@end
