//
//  StarViewController.m
//  OctSurfer
//
//  Copyright (c) 2012 yo_waka. All rights reserved.
//

#import "StarViewController.h"
#import "RepositoryCell.h"
#import "RepositoryViewController.h"
#import "ApiUrl.h"
#import "CCDateTime.h"
#import "CCHttpClient.h"


@interface StarViewController ()

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, strong) NSArray *stars;

@end


@implementation StarViewController

- (id) init
{
    self = [super init];
    if (!self) {
        return nil;
    }
    return self;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view.
    
    CGRect bounds = [[UIScreen mainScreen] applicationFrame];
    
    // Add tableview
    UITableView *tableView = [[UITableView alloc]
                              initWithFrame: CGRectMake(0.0, 0.0,
                                                        bounds.size.width, bounds.size.height)];
    tableView.rowHeight = 60;
    tableView.scrollEnabled = YES;
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview: tableView];
    
    // Set self property
    self.title = @"Your starred";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithBarButtonSystemItem: UIBarButtonSystemItemRefresh
                                              target: self
                                              action: @selector(handleRefreshClicked:)];
    self.tableView = tableView;
    
    [self getStarred];
}

- (void) getStarred
{
    NSString *url = [ApiUrl starredRepository];
    CCHttpClient *client = [CCHttpClient clientWithUrl: url];
    [client getJsonWithDelegate: self success: @selector(handleGetStarredSuccess:) failure: nil];
}

- (void) handleGetStarredSuccess: (NSDictionary *)json
{
    self.stars = (NSArray *)json;
    [self.tableView reloadData];
}

- (void) handleRefreshClicked: (id)sender
{
    [self getStarred];
}


#pragma mark - Table view delegate

- (void) tableView: (UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    // Pass the selected object to the new view controller.
    // [self.navigationController pushViewController:detailViewController animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    RepositoryViewController *repositoryController = [[RepositoryViewController alloc] init];
    NSDictionary *data = (self.stars)[indexPath.row];
    repositoryController.name = data[@"name"];
    repositoryController.owner = data[@"owner"][@"login"];
    [self.navigationController pushViewController: repositoryController animated: YES];
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
    // Return the number of sections.
    return 1;
}

- (NSInteger) tableView: (UITableView *)tableView numberOfRowsInSection: (NSInteger)section
{
    // Return the number of rows in the section.
    return [self.stars count];
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
    if (indexPath.row < [self.stars count]) {
        data = (self.stars)[indexPath.row];
    }
    
    NSString *name = [NSString stringWithFormat:@"%@ / %@", data[@"owner"][@"login"], data[@"name"]];
    NSString *date = [CCDateTime prettyPrint: [CCDateTime dateFromString: data[@"pushed_at"]]];
    
    repositoryCell.nameLabel.text = name;
    repositoryCell.descriptionLabel.text = data[@"description"];
    repositoryCell.starsLabel.text = [NSString stringWithFormat: @"%@ stars", data[@"watchers"]];
    repositoryCell.lastActivityLabel.text = [NSString stringWithFormat: @"last activity %@", date];
}

@end
