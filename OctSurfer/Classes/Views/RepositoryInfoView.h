//
//  RepositoryInfoView.h
//  OctSurfer
//
//  Copyright (c) 2012 yo_waka. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface RepositoryInfoView : UIView

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIImageView *avatarView;
@property (nonatomic, strong) UILabel *ownerLabel;
@property (nonatomic, strong) UILabel *messageLabel;

- (void) update: (NSString *)name
          image: (NSString *)image
          owner: (NSString *)owner
        message: (NSString *)message;

@end
