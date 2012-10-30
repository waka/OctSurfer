//
//  OrganizationCell.m
//  OctSurfer
//
//  Copyright (c) 2012 yo_waka. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "OrganizationCell.h"
#import "CCColor.h"
#import "CCImageCache.h"


@interface OrganizationCell ()

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIImageView *avatarView;

@end


@implementation OrganizationCell

- (id) initWithStyle: (UITableViewCellStyle)style reuseIdentifier: (NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (!self) {
        return nil;
    }
    
    _avatarView = [[UIImageView alloc] initWithFrame: CGRectZero];
    _avatarView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
    
    _nameLabel = [[UILabel alloc] initWithFrame: CGRectZero];
    _nameLabel.font = [UIFont systemFontOfSize: 16.0f];
    _nameLabel.textColor = [UIColor blackColor];
    _nameLabel.backgroundColor = [UIColor clearColor];
    _nameLabel.highlightedTextColor = [UIColor whiteColor];
    
    [self.contentView addSubview: _avatarView];
    [self.contentView addSubview: _nameLabel];
    
    return self;
}

- (void) layoutSubviews
{
    [super layoutSubviews];
    
    CGRect bounds = self.contentView.bounds;

    self.avatarView.frame = CGRectMake(10.0, 10.0, 30, 30);
    self.nameLabel.frame = CGRectMake(60.0, 10.0, bounds.size.width - 70, 30);
}

- (void) drawRect: (CGRect)rect
{
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.bounds;
    gradient.colors = @[(id)[[CCColor hexToUIColor: @"FFFFFF" alpha: 1.0] CGColor], (id)[[CCColor hexToUIColor: @"E8E8E8" alpha: 1.0] CGColor]];
    [self.layer insertSublayer: gradient atIndex: 0];
}

- (void) update: (NSString *)name
          image: (NSString *)imagePath
{
    self.nameLabel.text = name;
    
    __weak OrganizationCell *_self = self;
    self.avatarView.image = [[CCImageCache sharedInstance] imageWithURL: imagePath
                                                           defaultImage: [UIImage imageNamed: @"gravatar-user-default.png"]
                                                                  block: ^(UIImage *image, NSError *error) {
                                                                      if (!error) {
                                                                          self.avatarView.image = image;
                                                                          [_self setNeedsDisplay];
                                                                      }
                                                                  }];
}

@end
