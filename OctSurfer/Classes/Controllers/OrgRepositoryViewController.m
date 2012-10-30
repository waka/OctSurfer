//
//  OrgRepositoryViewController.m
//  OctSurfer
//
//  Copyright (c) 2012 yo_waka. All rights reserved.
//

#import "OrgRepositoryViewController.h"
#import "ApiCache.h"
#import "ApiUrl.h"
#import "CCDateTime.h"
#import "CCHttpClient.h"
#import "RepositoryViewController.h"
#import "RepositoryCell.h"
#import "SVProgressHUD.h"


@interface OrgRepositoryViewController ()

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, strong) NSArray *repositories;

@end


@implementation OrgRepositoryViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect bounds = [[UIScreen mainScreen] applicationFrame];
    
    // Add tableview
    UITableView *tableView = [[UITableView alloc]
                              initWithFrame: CGRectMake(0.0, 0.0,
                                                        bounds.size.width, bounds.size.height)];
    tableView.rowHeight = 60;
    tableView.scrollEnabled = YES;
    tableView.showsVerticalScrollIndicator = NO;
    tableView.contentInset = UIEdgeInsetsMake(0, 0, 100, 0);
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview: tableView];
    
    // Set self property
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithBarButtonSystemItem: UIBarButtonSystemItemRefresh
                                              target: self
                                              action: @selector(handleRefreshClicked:)];
    self.tableView = tableView;
    
    [self getOrgRepositories: NO];
}

- (void) handleRefreshClicked: (id)sender
{
    [self getOrgRepositories: YES];
}

- (void) getOrgRepositories: (BOOL)forceUpdate
{
    if (!forceUpdate) {
        id json = [ApiCache get: [ApiUrl orgRepositories: self.name calling: NO]];
        if (json) {
            [self showOrgRepositories: json];
            return;
        }
    }
    NSString *url = [ApiUrl orgRepositories: self.name calling: YES];
    CCHttpClient *client = [CCHttpClient clientWithUrl: url];
    [client getJsonWithDelegate: nil
                        headers: nil
                       delegate: self
                        success: @selector(handleGetOrgRepositoriesSuccess:result:)
                        failure: @selector(handleGetOrgRepositoriesFailure:error:)];
}

- (void) handleGetOrgRepositoriesSuccess: (NSHTTPURLResponse *) res result: (NSData *)result
{
    id json = [CCHttpClient responseJSON: result];
    [self showOrgRepositories: json];
    
    NSString *url = [ApiUrl orgRepositories: self.name calling: NO];
    [ApiCache set: url path: nil value: json];
}

- (void) handleGetOrgRepositoriesFailure: (NSHTTPURLResponse *) res error: (NSError *)error
{
    [SVProgressHUD showErrorWithStatus: @"Load error, please refresh."];
}

- (void) showOrgRepositories: (id)json
{
    NSArray *data = (NSArray *)json;
    self.repositories = data;
    [self.tableView reloadData];
}

- (void) viewWillAppear: (BOOL)animated
{
	[super viewWillAppear: animated];
    
    NSIndexPath *selection = [self.tableView indexPathForSelectedRow];
	if (selection) {
		[self.tableView deselectRowAtIndexPath: selection animated: YES];
    }
	[self.tableView reloadData];
}

- (void) viewDidAppear: (BOOL)animated
{
    [super viewDidAppear: animated];
    
	//	The scrollbars won't flash unless the tableview is long enough.
	[self.tableView flashScrollIndicators];
}


#pragma mark - Table view delegate

- (void) tableView: (UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    // Pass the selected object to the new view controller.
    // [self.navigationController pushViewController:detailViewController animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    RepositoryViewController *repositoryController = [[RepositoryViewController alloc] init];
    NSDictionary *data = (self.repositories)[indexPath.row];
    repositoryController.name = data[@"name"];
    repositoryController.owner = data[@"owner"][@"login"];
    
    [self pushToNavigationController: repositoryController];
}


#pragma mark - Table view data source

- (NSInteger) numberOfSectionsInTableView: (UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger) tableView: (UITableView *)tableView numberOfRowsInSection: (NSInteger)section
{
    // Return the number of rows in the section.
    return [self.repositories count];
}

- (UITableViewCell *) tableView: (UITableView *)tableView cellForRowAtIndexPath: (NSIndexPath *)indexPath
{
    RepositoryCell *cell = [tableView dequeueReusableCellWithIdentifier: @"RepositoryCell"];
    if (!cell) {
        // Configure the cell...
        cell = [[RepositoryCell alloc]
                initWithStyle: UITableViewCellStyleDefault reuseIdentifier: @"RepositoryCell"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    [self updateCell: cell atIndexPath: indexPath];
    return cell;
}

- (void) updateCell: (UITableViewCell *)cell atIndexPath: (NSIndexPath *)indexPath
{
    RepositoryCell *repositoryCell = (RepositoryCell *)cell;
    NSDictionary *data = nil;
    if (indexPath.row < [self.repositories count]) {
        data = (self.repositories)[indexPath.row];
    }
    
    NSString *name = [NSString stringWithFormat:@"%@ / %@", data[@"owner"][@"login"], data[@"name"]];
    NSString *date = [CCDateTime prettyPrint: [CCDateTime dateFromString: data[@"pushed_at"]]];
    
    repositoryCell.nameLabel.text = name;
    repositoryCell.descriptionLabel.text = data[@"description"];
    repositoryCell.starsLabel.text = [NSString stringWithFormat: @"%@ watchers", data[@"watchers"]];
    repositoryCell.lastActivityLabel.text = [NSString stringWithFormat: @"last activity %@", date];
}

@end
