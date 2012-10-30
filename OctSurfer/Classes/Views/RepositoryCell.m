//
//  RepositoryCell.m
//  OctSurfer
//
//  Copyright (c) 2012 yo_waka. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "RepositoryCell.h"
#import "CCColor.h"


@implementation RepositoryCell

- (id) initWithStyle: (UITableViewCellStyle)style reuseIdentifier: (NSString *)reuseIdentifier
{
    self = [super initWithStyle: style reuseIdentifier: reuseIdentifier];
    if (!self) {
        return nil;
    }
    
    _nameLabel = [[UILabel alloc] initWithFrame: CGRectZero];
    _nameLabel.font = [UIFont boldSystemFontOfSize: 16.0f];
    _nameLabel.textColor = [UIColor blackColor];
    _nameLabel.backgroundColor = [UIColor clearColor];
    
    _descriptionLabel = [[UILabel alloc] initWithFrame: CGRectZero];
    _descriptionLabel.font = [UIFont systemFontOfSize: 12.0f];
    _descriptionLabel.textColor = [UIColor grayColor];
    _descriptionLabel.backgroundColor = [UIColor clearColor];
    
    _starsLabel = [[UILabel alloc] initWithFrame: CGRectZero];
    _starsLabel.font = [UIFont systemFontOfSize: 12.0f];
    _starsLabel.textColor = [UIColor grayColor];
    _starsLabel.backgroundColor = [UIColor clearColor];
    
    _lastActivityLabel = [[UILabel alloc] initWithFrame: CGRectZero];
    _lastActivityLabel.font = [UIFont systemFontOfSize: 12.0f];
    _lastActivityLabel.textColor = [UIColor grayColor];
    _lastActivityLabel.backgroundColor = [UIColor clearColor];
    
    [self.contentView addSubview: _nameLabel];
    [self.contentView addSubview: _descriptionLabel];
    [self.contentView addSubview: _starsLabel];
    [self.contentView addSubview: _lastActivityLabel];
    
    return self;
}

- (void) layoutSubviews
{
    [super layoutSubviews];
    
    CGRect bounds = self.contentView.bounds;
    
    self.nameLabel.frame = CGRectMake(10.0, 3.0, bounds.size.width - 20, 24);
    self.descriptionLabel.frame = CGRectMake(10.0, 27.0, bounds.size.width - 20, 15);
    self.starsLabel.frame = CGRectMake(10.0, 42.0, 100, 15);
    self.lastActivityLabel.frame = CGRectMake(110.0, 42.0, bounds.size.width - 120, 15);
}

- (void) drawRect: (CGRect)rect
{
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.bounds;
    gradient.colors = @[(id)[[CCColor hexToUIColor: @"FFFFFF" alpha: 1.0] CGColor], (id)[[CCColor hexToUIColor: @"E8E8E8" alpha: 1.0] CGColor]];
    [self.layer insertSublayer: gradient atIndex: 0];
}

@end
