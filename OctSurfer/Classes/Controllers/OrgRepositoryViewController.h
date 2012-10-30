//
//  OrgRepositoryViewController.h
//  OctSurfer
//
//  Copyright (c) 2012 yo_waka. All rights reserved.
//

#import "AbstractViewController.h"


@interface OrgRepositoryViewController : AbstractViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSString *name;

@end
