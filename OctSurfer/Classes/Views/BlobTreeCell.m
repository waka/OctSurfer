//
//  BlobTreeCell.m
//  OctSurfer
//
//  Copyright (c) 2012 yo_waka. All rights reserved.
//

#import "BlobTreeCell.h"


@interface BlobTreeCell ()

@property (nonatomic, strong) UIImageView *typeView;

@end

@implementation BlobTreeCell

- (id) initWithStyle: (UITableViewCellStyle)style reuseIdentifier: (NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (!self) {
        return nil;
    }
    
    _typeView = [[UIImageView alloc] initWithFrame: CGRectZero];
    _typeView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
    
    _nameLabel = [[UILabel alloc] initWithFrame: CGRectZero];
    _nameLabel.font = [UIFont systemFontOfSize: 16.0f];
    _nameLabel.textColor = [UIColor blackColor];
    _nameLabel.backgroundColor = [UIColor clearColor];
    _nameLabel.highlightedTextColor = [UIColor whiteColor];
    
    [self.contentView addSubview: _typeView];
    [self.contentView addSubview: _nameLabel];
    
    return self;
}

- (void) layoutSubviews
{
    [super layoutSubviews];
    
    CGRect bounds = self.contentView.bounds;
    
    self.typeView.frame = CGRectMake(10.0, 13.0, 24, 24);
    self.nameLabel.frame = CGRectMake(50.0, 10.0, bounds.size.width - 60, 30);
}

- (void) update: (NSString *)name type: (NSString *)type
{
    self.nameLabel.text = name;
    
    if (type == nil) {
        [self.typeView removeFromSuperview];
        CGRect bounds = self.contentView.bounds;
        self.nameLabel.frame = CGRectMake(10.0, 10.0, bounds.size.width - 20, 30);
    } else {
        if ([type isEqualToString: @"tree"]) {
            self.typeView.image = [UIImage imageNamed: @"folder.png"];
        } else {
            self.typeView.image = [UIImage imageNamed: @"file.png"];
        }
    }
}

@end
