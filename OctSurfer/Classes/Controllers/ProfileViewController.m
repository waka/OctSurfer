//
//  ProfileViewController.m
//  OctSurfer
//
//  Copyright (c) 2012 yo_waka. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ProfileViewController.h"
#import "UserInfoView.h"
#import "RepositoryViewController.h"
#import "RepositoryCell.h"
#import "CoreDataManager.h"
#import "AuthEntity.h"
#import "AppConfig.h"
#import "ApiCache.h"
#import "ApiUrl.h"
#import "CCDateTime.h"
#import "CCHttpClient.h"
#import "SVProgressHUD.h"


@interface ProfileViewController ()

@property (nonatomic, weak) UserInfoView *infoView;
@property (nonatomic, strong) NSArray *stars;
@property (nonatomic, weak) UITableView *tableView;

@end


@implementation ProfileViewController

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
    
    // Add infoView
    UserInfoView *infoView = [[UserInfoView alloc]
                                    initWithFrame: CGRectMake(0.0, 0.0, bounds.size.width, 60)];
    [self.view addSubview: infoView];
    [self setScrollGesture: infoView];
    
    // Add bgView for tableview
    UIView *tableBgView = [[UIView alloc]
                           initWithFrame: CGRectMake(0.0, 60.0,
                                                     bounds.size.width, bounds.size.height - 60.0)];
    // Add shadow in bgView
    CALayer* subLayer = [CALayer layer];
    subLayer.frame = tableBgView.bounds;
    [tableBgView.layer addSublayer: subLayer];
    subLayer.masksToBounds = YES;
    UIBezierPath* path = [UIBezierPath bezierPathWithRect:
                          CGRectMake(-10.0, -10.0, subLayer.bounds.size.width + 10.0, 10.0)];
    
    subLayer.shadowOffset = CGSizeMake(2.5, 2.5);
    subLayer.shadowColor = [[UIColor blackColor] CGColor];
    subLayer.shadowOpacity = 0.5;
    subLayer.shadowPath = [path CGPath];
    [self.view addSubview: tableBgView];
    
    // Add tableView
    UITableView *tableView;
    tableView= [[UITableView alloc]
                initWithFrame: CGRectMake(0.0, 0.0,
                                          tableBgView.bounds.size.width, tableBgView.bounds.size.height)];
    tableView.rowHeight = 60;
    tableView.scrollEnabled = YES;
    tableView.showsVerticalScrollIndicator = NO;
    tableView.delegate = self;
    tableView.dataSource = self;
    [tableBgView addSubview: tableView];
    

    // Set self property
    self.title = @"You";
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemRefresh
                                                                                   target: self
                                                                                   action: @selector(handleRefreshClicked:)];
    UIBarButtonItem *logoutButton = [[UIBarButtonItem alloc] initWithTitle: @"Logout"
                                                                     style: UIBarButtonItemStylePlain
                                                                    target: self
                                                                    action: @selector(logoutDidPress:)];
    [self.navigationController.navigationBar.topItem setRightBarButtonItems: @[refreshButton, logoutButton]];
    
    self.infoView = infoView;
    self.tableView = tableView;
    
    [self getUserInfo: NO];
    [self getUserStarred: NO];
}

- (void) logoutDidPress: (id)sender
{
    // do logout and move search
    AuthEntity *auth = [[CoreDataManager sharedManager] findAuth];
    if (auth) {
        [AppConfig remove: @"accessToken"];
        [[CoreDataManager sharedManager] deleteAuth: auth];
        [[CoreDataManager sharedManager] save];
    }
    
    [self showLogin: YES];
}

- (void) handleRefreshClicked: (id)sender
{
    self.stars = @[];
    [self getUserStarred: YES];
}

- (void) getUserInfo: (BOOL)forceUpdate
{
    if (!forceUpdate) {
        id json = [ApiCache get: [ApiUrl authenticatedUser: NO]];
        if (json) {
            [self showUserInfo: json];
            return;
        }
    }
    NSString *url = [ApiUrl authenticatedUser: YES];
    CCHttpClient *client = [CCHttpClient clientWithUrl: url];
    [client getJsonWithDelegate: nil
                        headers: nil
                       delegate: self
                        success: @selector(handleGetUserInfoSuccess:result:)
                        failure: @selector(handleGetUserStarredFailure:error:)];
}

- (void) handleGetUserInfoSuccess: (NSHTTPURLResponse *) res result: (NSData *)result
{
    id json = [CCHttpClient responseJSON: result];
    [self showUserInfo: json];
    
    NSString *url = [ApiUrl authenticatedUser: NO];
    [ApiCache set: url path: nil value: json];
}

- (void) handleGetUserInfoFailure: (NSHTTPURLResponse *) res error: (NSError *)error
{
    [SVProgressHUD showErrorWithStatus: @"Load error, please refresh."];
}

- (void) showUserInfo: (id)json
{
    NSDictionary *data = (NSDictionary *)json;
    NSString *name = [NSString stringWithFormat: @"%@ (%@)", data[@"login"], data[@"name"]];
    [self.infoView update: name image: data[@"avatar_url"]];
}

- (void) getUserStarred: (BOOL)forceUpdate
{
    if (!forceUpdate) {
        id json = [ApiCache get: [ApiUrl authenticatedUserStarred: NO]];
        if (json) {
            [self showUserStarred: json];
            return;
        }
    }
    NSString *url = [ApiUrl authenticatedUserStarred: YES];
    CCHttpClient *client = [CCHttpClient clientWithUrl: url];
    [client getJsonWithDelegate: nil
                        headers: nil
                       delegate: self
                        success: @selector(handleGetUserStarredSuccess:result:)
                        failure: @selector(handleGetUserStarredFailure:error:)];
}

- (void) handleGetUserStarredSuccess: (NSHTTPURLResponse *) res result: (NSData *)result
{
    id json = [CCHttpClient responseJSON: result];
    [self showUserStarred: json];
    
    NSString *url = [ApiUrl authenticatedUserStarred: NO];
    [ApiCache set: url path: nil value: json];
}

- (void) handleGetUserStarredFailure: (NSHTTPURLResponse *) res error: (NSError *)error
{
    [SVProgressHUD showErrorWithStatus: @"Load error, please refresh."];
}

- (void) showUserStarred: (id)json
{
    NSArray *data = (NSArray *)json;
    self.stars = data;
    [self.tableView reloadData];
}


#pragma mark - Table view delegate

- (void) tableView: (UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath: indexPath animated: YES];

    RepositoryViewController *repositoryController = [[RepositoryViewController alloc] init];
    NSDictionary *data = (self.stars)[indexPath.row];
    repositoryController.name = data[@"name"];
    repositoryController.owner = data[@"owner"][@"login"];
    
    [self pushToNavigationController: repositoryController];
}

- (void)tableView: (UITableView *)tableView commitEditingStyle: (UITableViewCellEditingStyle)editingStyle forRowAtIndexPath: (NSIndexPath *)indexPath {
    NSDictionary *data = (self.stars)[indexPath.row];
    
    NSString *url = [ApiUrl starred: data[@"owner"][@"login"] repository: data[@"name"] calling: YES];
    CCHttpClient *client = [CCHttpClient clientWithUrl: url];
    [client deleteWithDelegate: nil
                      delegate: self
                       success: @selector(handleDeleteStarredSuccess:result:)
                       failure: @selector(handleDeleteStarredFailure:error:)];
}

- (void) handleDeleteStarredSuccess: (NSURLResponse *)response result: (NSData *)result
{
    [SVProgressHUD showWithStatus: @"Succeed to delete starred"];
    [self getUserStarred: YES]; // Refersh data and coredata
}

- (void) handleDeleteStarredFailure: (NSURLResponse *)res error: (NSError *)error
{
    [SVProgressHUD showErrorWithStatus: @"Failed to delete starred, please retry"];
}


#pragma mark - Table view data source

- (NSInteger) numberOfSectionsInTableView: (UITableView *)tableView
{
    return 1;
}

- (NSString *) tableView: (UITableView *)tableView titleForHeaderInSection: (NSInteger)section {
    return @"Starred";
}

- (NSInteger) tableView: (UITableView *)tableView numberOfRowsInSection: (NSInteger)section
{
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
