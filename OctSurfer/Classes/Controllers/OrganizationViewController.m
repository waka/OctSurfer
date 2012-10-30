//
//  OrganizationViewController.m
//  OctSurfer
//
//  Copyright (c) 2012 yo_waka. All rights reserved.
//

#import "OrganizationViewController.h"
#import "OrganizationCell.h"
#import "OrgRepositoryViewController.h"
#import "ApiCache.h"
#import "ApiUrl.h"
#import "CCDateTime.h"
#import "CCHttpClient.h"
#import "SVProgressHUD.h"


@interface OrganizationViewController ()

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, strong) NSArray *orgs;

@end


@implementation OrganizationViewController

- (id) init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    CGRect bounds = [[UIScreen mainScreen] applicationFrame];
    
    // Add tableview
    UITableView *tableView = [[UITableView alloc]
                              initWithFrame: CGRectMake(0.0, 0.0,
                                                        bounds.size.width, bounds.size.height)];
    tableView.rowHeight = 50;
    tableView.scrollEnabled = YES;
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview: tableView];
    
    // Set self property
    self.title = @"Organizations";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithBarButtonSystemItem: UIBarButtonSystemItemRefresh
                                              target: self
                                              action: @selector(handleRefreshClicked:)];
    self.tableView = tableView;
    
    [self getAuthenticatedUserOrgs: NO];
}

- (void) handleRefreshClicked: (id)sender
{
    [self getAuthenticatedUserOrgs: YES];
}

- (void) getAuthenticatedUserOrgs: (BOOL)forceUpdate
{
    if (!forceUpdate) {
        id json = [ApiCache get: [ApiUrl authenticatedUserOrganizations: NO]];
        if (json) {
            [self showAuthenticatedUserOrgs: json];
            return;
        }
    }
    NSString *url = [ApiUrl authenticatedUserOrganizations: YES];
    CCHttpClient *client = [CCHttpClient clientWithUrl: url];
    [client getJsonWithDelegate: nil
                        headers: nil
                       delegate: self
                        success: @selector(handleGetAuthenticatedUserOrgsSuccess:result:)
                        failure: @selector(handleGetAuthenticatedUserOrgsFailure:error:)];
}

- (void) handleGetAuthenticatedUserOrgsSuccess: (NSHTTPURLResponse *) res result: (NSData *)result
{
    id json = [CCHttpClient responseJSON: result];
    [self showAuthenticatedUserOrgs: json];
    
    NSString *url = [ApiUrl authenticatedUserOrganizations: NO];
    [ApiCache set: url path: nil value: json];
}

- (void) handleGetAuthenticatedUserOrgsFailure: (NSHTTPURLResponse *) res error: (NSError *)error
{
    [SVProgressHUD showErrorWithStatus: @"Load error, please refresh."];
}

- (void) showAuthenticatedUserOrgs: (id)json
{
    NSArray *data = (NSArray *)json;
    self.orgs = data;
    [self.tableView reloadData];
}


#pragma mark - Table view delegate

- (void) tableView: (UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    OrgRepositoryViewController *repositoryController = [[OrgRepositoryViewController alloc] init];
    NSDictionary *data = (self.orgs)[indexPath.row];
    repositoryController.title = data[@"login"];
    repositoryController.name = data[@"login"];
    
    [self pushToNavigationController: repositoryController];
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


#pragma mark - Table view data source

- (NSInteger) numberOfSectionsInTableView: (UITableView *)tableView
{
    return 1;
}

- (NSInteger) tableView: (UITableView *)tableView numberOfRowsInSection: (NSInteger)section
{
    return [self.orgs count];
}

- (UITableViewCell *) tableView: (UITableView *)tableView cellForRowAtIndexPath: (NSIndexPath *)indexPath
{
    OrganizationCell *cell = [tableView dequeueReusableCellWithIdentifier: @"OrganizationCell"];
    if (!cell) {
        // Configure the cell...
        cell = [[OrganizationCell alloc]
                initWithStyle: UITableViewCellStyleDefault reuseIdentifier: @"OrganizationCell"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    [self updateCell: cell atIndexPath: indexPath];
    return cell;
}

- (void) updateCell: (UITableViewCell *)cell atIndexPath: (NSIndexPath *)indexPath
{
    OrganizationCell *organizationCell = (OrganizationCell *)cell;
    NSDictionary *data = nil;
    if (indexPath.row < [self.orgs count]) {
        data = (self.orgs)[indexPath.row];
    }
    
    [organizationCell update: data[@"login"] image: data[@"avatar_url"]];
}

@end