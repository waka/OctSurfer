//
//  RepositoryViewController.h
//  OctSurfer
//
//  Copyright (c) 2012 yo_waka. All rights reserved.
//

#import "AbstractViewController.h"


@interface RepositoryViewController : AbstractViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *owner;

@end
