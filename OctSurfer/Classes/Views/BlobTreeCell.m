//
//  BlobTreeCell.m
//  OctSurfer
//
//  Copyright (c) 2012 yo_waka. All rights reserved.
//

#import "BlobTreeCell.h"

@implementation BlobTreeCell

- (id) initWithStyle: (UITableViewCellStyle)style reuseIdentifier: (NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (!self) {
        return nil;
    }
    
    _nameLabel = [[UILabel alloc] initWithFrame: CGRectZero];
    _nameLabel.font = [UIFont systemFontOfSize: 16.0f];
    _nameLabel.textColor = [UIColor blackColor];
    _nameLabel.backgroundColor = [UIColor clearColor];
    _nameLabel.highlightedTextColor = [UIColor whiteColor];
    
    [self.contentView addSubview: _nameLabel];
    
    return self;
}

- (void) layoutSubviews
{
    [super layoutSubviews];
    
    CGRect bounds = self.contentView.bounds;
    
    self.nameLabel.frame = CGRectMake(10.0, 13.0, bounds.size.width - 20, 24);
}

@end
