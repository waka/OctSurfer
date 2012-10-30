//
//  FirstView.m
//  OctSurfer
//
//  Copyright (c) 2012 yo_waka. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "OAuthFirstView.h"
#import "LoginButton.h"
#import "CCColor.h"


@interface OAuthFirstView ()

@property (nonatomic, strong) UILabel *logoLabel;
@property (nonatomic, strong) LoginButton *loginButton;
@property (nonatomic, strong) UILabel *messageLabel;

@end


@implementation OAuthFirstView

- (id)initWithFrame: (CGRect)frame
{
    self = [super initWithFrame: frame];
    if (!self) {
        return nil;
    }
    
    _logoLabel = [[UILabel alloc] initWithFrame: CGRectZero];
    _logoLabel.backgroundColor = [UIColor clearColor];
    _logoLabel.font = [UIFont fontWithName: @"Helvetica" size: 36.0f];
    _logoLabel.textColor = [UIColor blackColor];
    _logoLabel.text = @"OctSurfer";
    _logoLabel.textAlignment = UITextAlignmentCenter;
    
    _loginButton = [LoginButton buttonWithType: UIButtonTypeCustom];
    [_loginButton setTitle: @"Login with GitHub" forState: UIControlStateNormal];
    [_loginButton addTarget: self action: @selector(loginAction:) forControlEvents: UIControlEventTouchUpInside];

    _messageLabel = [[UILabel alloc] initWithFrame: CGRectZero];
    _messageLabel.backgroundColor = [UIColor clearColor];
    _messageLabel.font = [UIFont systemFontOfSize: 14.0f];
    _messageLabel.textColor = [UIColor grayColor];
    _messageLabel.text = @"Login to OctSurfer with your GitHub account and get instant access to OctSurfer, including repository search, source-viewing, starred-viewing, and more!";
    _messageLabel.numberOfLines = 0;
    
    [self addSubview: _logoLabel];
    [self addSubview: _loginButton];
    [self addSubview: _messageLabel];
    
    return self;
}

- (void) layoutSubviews
{
    [super layoutSubviews];
    
    CGRect bounds = self.bounds;
    self.logoLabel.frame = CGRectMake(20.0, 50.0, bounds.size.width - 40, 50);
    self.loginButton.frame = CGRectMake(20.0, 160.0, bounds.size.width - 40, 50);
    self.messageLabel.frame = CGRectMake(20.0, 170.0, bounds.size.width - 40, bounds.size.height - 190);
}


#pragma mark - Button actions

- (void) loginAction: (LoginButton *)sender
{
    // call delegate method
    [self.delegate loginButtonClicked: sender];
}

@end
