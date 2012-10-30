//
//  RepositoryInfoView.m
//  OctSurfer
//
//  Copyright (c) 2012 yo_waka. All rights reserved.
//

#import "RepositoryInfoView.h"
#import "CCImageCache.h"
#import "CCColor.h"


@implementation RepositoryInfoView

- (id)initWithFrame: (CGRect)frame
{
    self = [super initWithFrame: frame];
    if (!self) {
        return nil;
    }
    
    self.backgroundColor = [CCColor hexToUIColor: @"EEEEEE" alpha: 1.0];
    
    _nameLabel = [[UILabel alloc] initWithFrame: CGRectZero];
    _nameLabel.font = [UIFont boldSystemFontOfSize: 16.0f];
    _nameLabel.textColor = [UIColor blackColor];
    _nameLabel.backgroundColor = [UIColor clearColor];
    
    _avatarView = [[UIImageView alloc] initWithFrame: CGRectZero];
    _avatarView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
    
    _ownerLabel = [[UILabel alloc] initWithFrame: CGRectZero];
    _ownerLabel.font = [UIFont systemFontOfSize: 14.0f];
    _ownerLabel.textColor = [CCColor hexToUIColor: @"333333" alpha: 1.0];
    _ownerLabel.backgroundColor = [UIColor clearColor];
    
    _messageLabel = [[UILabel alloc] initWithFrame: CGRectZero];
    _messageLabel.font = [UIFont systemFontOfSize: 12.0f];
    _messageLabel.textColor = [CCColor hexToUIColor: @"333333" alpha: 1.0];
    _messageLabel.backgroundColor = [UIColor clearColor];
    
    [self addSubview: _nameLabel];
    [self addSubview: _avatarView];
    [self addSubview: _ownerLabel];
    [self addSubview: _messageLabel];
    
    return self;
}

- (void) layoutSubviews
{
    [super layoutSubviews];
    
    CGRect bounds = self.bounds;
    self.nameLabel.frame = CGRectMake(10.0, 5.0, bounds.size.width - 20, 24);
    self.avatarView.frame = CGRectMake(10.0, 32.0, 28, 28);
    self.ownerLabel.frame = CGRectMake(45.0, 32.0, 100, 28);
    self.messageLabel.frame = CGRectMake(10.0, 60.0, bounds.size.width - 20, 30);
}

- (void) update: (NSString *)name
          image: (NSString *)imagePath
          owner: (NSString *)owner
        message: (NSString *)message
{
    self.nameLabel.text = name;
    
    __weak RepositoryInfoView *_self = self;
    self.avatarView.image = [[CCImageCache sharedInstance] imageWithURL: imagePath
                                                           defaultImage: [UIImage imageNamed: @"gravatar-user-default.png"]
                                                                  block: ^(UIImage *image, NSError *error) {
                                                                      if (!error) {
                                                                          _self.avatarView.image = image;
                                                                          [_self setNeedsDisplay];
                                                                      }
                                                                  }];
    self.ownerLabel.text = owner;
    self.messageLabel.text = message;
}

@end
