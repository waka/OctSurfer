//
//  BlobTreeCell.h
//  OctSurfer
//
//  Copyright (c) 2012 yo_waka. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface BlobTreeCell : UITableViewCell

@property (nonatomic, strong) UILabel *nameLabel;
- (void) update: (NSString *)name type: (NSString *)type;

@end
