//
//  RepositoryCell.h
//  OctSurfer
//
//  Copyright (c) 2012 yo_waka. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface RepositoryCell : UITableViewCell

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *descriptionLabel;
@property (nonatomic, strong) UILabel *starsLabel;
@property (nonatomic, strong) UILabel *lastActivityLabel;

@end
