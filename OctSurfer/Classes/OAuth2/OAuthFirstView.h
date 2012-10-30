//
//  OAuthFirstView.h
//  OctSurfer
//
//  Copyright (c) 2012 yo_waka. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OAuthFirstViewDelegate.h"


@interface OAuthFirstView : UIView

@property (nonatomic, weak) id<OAuthFirstViewDelegate> delegate;

@end
