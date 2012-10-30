//
//  UserInfoView.m
//  OctSurfer
//
//  Copyright (c) 2012 yo_waka. All rights reserved.
//

#import "UserInfoView.h"
#import "CCColor.h"
#import "CCImageCache.h"


@interface UserInfoView ()

@property (nonatomic, strong) UIImageView *avatarView;
@property (nonatomic, strong) UILabel *nameLabel;

@end


@implementation UserInfoView

- (id)initWithFrame: (CGRect)frame
{
    self = [super initWithFrame: frame];
    if (!self) {
        return nil;
    }
    
    self.backgroundColor = [CCColor hexToUIColor: @"EEEEEE" alpha: 1.0];
    
    _avatarView = [[UIImageView alloc] initWithFrame: CGRectZero];
    _avatarView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
    
    _nameLabel = [[UILabel alloc] initWithFrame: CGRectZero];
    _nameLabel.font = [UIFont systemFontOfSize: 28.0f];
    _nameLabel.textColor = [CCColor hexToUIColor: @"333333" alpha: 1.0];
    _nameLabel.backgroundColor = [UIColor clearColor];
    
    [self addSubview: _avatarView];
    [self addSubview: _nameLabel];
    
    return self;
}

- (void) layoutSubviews
{
    [super layoutSubviews];

    CGRect bounds = self.bounds;
    self.avatarView.frame = CGRectMake(10.0, 10.0, 40, 40);
    self.nameLabel.frame = CGRectMake(60.0, 10.0, bounds.size.width - 60, 40);
}

- (void) update: (NSString *)name image: (NSString *)imagePath
{
    self.avatarView.image = [[CCImageCache sharedInstance] imageWithURL: imagePath
                                                           defaultImage: [UIImage imageNamed: @"gravatar-user-default.png"]
                                                                  block: ^(UIImage *image, NSError *error) {
                                                                      if (!error) {
                                                                          self.avatarView.image = image;
                                                                      }
                                                                  }];
    self.nameLabel.text = name;
}

@end
