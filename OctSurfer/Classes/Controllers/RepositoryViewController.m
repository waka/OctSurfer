//
//  RepositoryViewController.m
//  OctSurfer
//
//  Copyright (c) 2012 yo_waka. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "RepositoryViewController.h"
#import "RepositoryInfoView.h"
#import "BlobTreeCell.h"
#import "SourceViewController.h"
#import "ApiCache.h"
#import "ApiUrl.h"
#import "CCHttpClient.h"
#import "SVProgressHUD.h"


@interface RepositoryViewController ()

@property (nonatomic, assign) BOOL starred;

@property (nonatomic, weak) RepositoryInfoView *infoView;
@property (nonatomic, weak) UIView *tableBgView;
@property (nonatomic, weak) UITableView *tableView;

@property (nonatomic, assign) NSInteger treeIndex;
@property (nonatomic, strong) NSMutableArray *treePaths;
@property (nonatomic, strong) NSArray *blobs;
@property (nonatomic, assign) Boolean isUpside;

@end


@implementation RepositoryViewController

- (id) init
{
    self = [super init];
    if (self) {
        _treeIndex = -1;
        _treePaths = [NSMutableArray array];
        _blobs = @[];
        _isUpside = NO;
    }
    return self;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    CGRect bounds = [[UIScreen mainScreen] applicationFrame];
    
    // Add infoView
    RepositoryInfoView *infoView = [[RepositoryInfoView alloc]
                                    initWithFrame: CGRectMake(0.0, 0.0, bounds.size.width, 90)];
    [self.view addSubview: infoView];
    [self setScrollGesture: infoView];
    
    // Add bgView for tableview
    UIView *tableBgView = [[UIView alloc]
                           initWithFrame: CGRectMake(0.0, 90.0,
                                                     bounds.size.width, bounds.size.height - 90.0)];
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
    UITableView *tableView = [[UITableView alloc]
                              initWithFrame: CGRectMake(0.0, 5.0,
                                                        tableBgView.bounds.size.width, tableBgView.bounds.size.height)];
    tableView.rowHeight = 50;
    tableView.scrollEnabled = YES;
    tableView.showsVerticalScrollIndicator = NO;
    tableView.delegate = self;
    tableView.dataSource = self;
    [tableBgView addSubview: tableView];
    
    // Set self property
    self.title = self.name;
    self.infoView = infoView;
    self.tableBgView = tableBgView;
    self.tableView = tableView;
    
    [self getStarred];
    [self getInfoData: NO];
}


#pragma mark - Navigation buttons

- (void) getStarred
{
    NSString *url = [ApiUrl starred: self.owner repository: self.name calling: YES];
    CCHttpClient *client = [CCHttpClient clientWithUrl: url];
    [client getWithDelegate: nil
                    headers: nil
                   delegate: self
                    success: @selector(handleGetStarredSuccess:result:)
                    failure: @selector(handleGetStarredFailure:error:)];
}

- (void) handleGetStarredSuccess: (NSHTTPURLResponse *)response result: (NSData *)result
{
    [self setNavigationBarButtons: YES];
}

- (void) handleGetStarredFailure: (NSHTTPURLResponse *)response error: (NSError *)error
{
    if (response.statusCode == 404) {
        [self setNavigationBarButtons: NO];
    } else {
        [SVProgressHUD showErrorWithStatus: @"Get starred info error, please refresh."];
        UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc]
                                          initWithBarButtonSystemItem: UIBarButtonSystemItemRefresh
                                          target: self
                                          action: @selector(handleRefreshClicked:)];
        self.navigationItem.rightBarButtonItem = refreshButton;
    }
}

- (void) setNavigationBarButtons: (BOOL)starred
{
    self.starred = starred;
    
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc]
                                      initWithBarButtonSystemItem: UIBarButtonSystemItemRefresh
                                      target: self
                                      action: @selector(handleRefreshClicked:)];
    
    UIBarButtonItem *starButton = [[UIBarButtonItem alloc]
                                   initWithImage: [UIImage imageNamed: @"starred"]
                                           style: UIBarButtonItemStylePlain
                                          target: self
                                          action: @selector(handleStarClicked:)];
    if (starred) {
        [starButton setEnabled: NO];
    }
    
    [self.navigationController.navigationBar.topItem setRightBarButtonItems: @[refreshButton, starButton]];
}

- (void) handleStarClicked: (id)sender
{
    NSString *url = [ApiUrl starred: self.owner repository: self.name calling: YES];
    CCHttpClient *client = [CCHttpClient clientWithUrl: url];
    [client putWithDelegate: nil
                   delegate: self
                    success: @selector(handlePutStarredSuccess:result:)
                    failure: @selector(handlePutStarredFailure:error:)];
}

- (void) handlePutStarredSuccess: (NSHTTPURLResponse *)response result: (NSData *)result
{
    [SVProgressHUD showSuccessWithStatus: @"Succeed to add starred"];
    [self setNavigationBarButtons: YES];
}

- (void) handlePutStarredFailure: (NSHTTPURLResponse *)response error: (NSError *)error
{
    [SVProgressHUD showErrorWithStatus: @"Failed to add starred, please retry"];
}

- (void) handleRefreshClicked: (id)sender
{
    self.treeIndex = -1;
    self.treePaths = [NSMutableArray array];
    self.blobs = @[];
    self.isUpside = NO;
    [self getInfoData: YES];
}


#pragma mark - Infomation

- (void) getInfoData: (BOOL)forceUpdate
{
    if (!forceUpdate) {
        id json = [ApiCache get: [ApiUrl masterBranch: self.owner repository: self.name calling: NO]];
        if (json) {
            [self showRepositoryInfo: json];
            return;
        }
    }
    NSString *url = [ApiUrl masterBranch: self.owner repository: self.name calling: YES];
    CCHttpClient *client = [CCHttpClient clientWithUrl: url];
    [client getJsonWithDelegate: nil
                        headers: nil
                       delegate: self
                        success: @selector(handleGetInfoDataSuccess:result:)
                        failure: @selector(handleGetInfoDataFailure:error:)];
}

- (void) handleGetInfoDataSuccess: (NSHTTPURLResponse *) res result: (NSData *)result
{
    id json = [CCHttpClient responseJSON: result];
    [self showRepositoryInfo: json];
    
    NSString *url = [ApiUrl masterBranch: self.owner repository: self.name calling: NO];
    [ApiCache set: url path: nil value: json];
}

- (void) handleGetInfoDataFailure: (NSHTTPURLResponse *) res error: (NSError *)error
{
    [SVProgressHUD showErrorWithStatus: @"Load error, please refresh."];
}

- (void) showRepositoryInfo: (id)json
{
    NSDictionary *data = (NSDictionary *)json[@"commit"];
    
    NSString *imageURL;
    if ([data[@"author"] isKindOfClass: [NSDictionary class]] && [[data[@"author"] allKeys] containsObject: @"avatar_url"]) {
        imageURL = data[@"author"][@"avatar_url"];
    } else {
        imageURL = nil;
    }
    [self.infoView update: self.name
                    image: imageURL
                    owner: self.owner
                  message: data[@"commit"][@"message"]];
    
    [self.treePaths addObject: data[@"commit"][@"tree"][@"url"]];
    [self getTreeData: data[@"commit"][@"tree"][@"url"]];
}


#pragma mark - Repository tree

- (void) getTreeData: (NSString *)url
{
    CCHttpClient *client = [CCHttpClient clientWithUrl: url];
    [client getJsonWithDelegate: nil
                        headers: nil
                       delegate: self
                        success: @selector(handleGetTreeSuccess:result:)
                        failure: @selector(handleGetTreeFailure:error:)];
}

- (void) handleGetTreeSuccess: (NSHTTPURLResponse *) res result: (NSData *)result
{
    NSDictionary *json = [CCHttpClient responseJSON: result];
    self.blobs = (NSArray *)json[@"tree"];
    
    if (self.isUpside) {
        [self tableScrollRightAndReload];
    } else {
        [self tableScrollLeftAndReload];
    }
    self.isUpside = NO;
}

- (void) handleGetTreeFailure: (NSHTTPURLResponse *) res error: (NSError *)error
{
    [SVProgressHUD showErrorWithStatus: @"Load error, please refresh."];
}

/**
 * Left to Right
 */
- (void) tableScrollLeftAndReload
{
    self.treeIndex += 1;
    
    CGRect bgFrame = self.tableBgView.frame;
    if (self.treeIndex > 0) {
        [UIView beginAnimations: nil context: nil];
        [UIView setAnimationDuration: 0.2];
        [UIView setAnimationCurve: UIViewAnimationCurveLinear];
        [UIView setAnimationDelegate: self];
        [UIView setAnimationDidStopSelector: @selector(didTableScrollFinished:finished:context:)];
        self.tableView.frame = CGRectMake(-(bgFrame.size.width), 5.0, bgFrame.size.width, bgFrame.size.height);
        [UIView commitAnimations];
    } else {
        // Only first load
        [self.tableView reloadData];
    }
}

- (void) tableScrollRightAndReload
{
    self.treeIndex -= 1;
    
    CGRect bgFrame = self.tableBgView.frame;
    [UIView beginAnimations: nil context: nil];
    [UIView setAnimationDuration: 0.2];
    [UIView setAnimationCurve: UIViewAnimationCurveLinear];
    [UIView setAnimationDelegate: self];
    [UIView setAnimationDidStopSelector: @selector(didTableScrollFinished:finished:context:)];
    self.tableView.frame = CGRectMake(bgFrame.size.width, 5.0, bgFrame.size.width, bgFrame.size.height);
    [UIView commitAnimations];
}

- (void) didTableScrollFinished: (NSString *)animation finished: (BOOL)finished context: (void *)context
{
    [self.tableView reloadData];
    
    CGRect bgFrame = self.tableBgView.frame;
    self.tableView.frame = CGRectMake(0.0, 5.0, bgFrame.size.width, bgFrame.size.height);
}


#pragma mark - Table view delegate

- (void) tableView: (UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath: indexPath animated: YES];
    
    if (self.treeIndex > 0 && indexPath.row == 0) {
        self.isUpside = YES;
        [self.treePaths removeLastObject];
        [self getTreeData: [self.treePaths objectAtIndex: [self.treePaths count] - 1]];
        return;
    }
    
    NSDictionary *data = nil;
    if (self.treeIndex > 0) {
        data = (self.blobs)[indexPath.row - 1];
    } else {
        data = (self.blobs)[indexPath.row];
    }
    
    if ([data[@"type"] isEqualToString: @"blob"]) {
        SourceViewController *sourceController = [[SourceViewController alloc] init];
        sourceController.name = data[@"path"];
        sourceController.url = data[@"url"];
        
        [self pushToNavigationController: sourceController];
    } else if ([data[@"type"] isEqualToString: @"tree"]) {
        [self.treePaths addObject: data[@"url"]];
        [self getTreeData: data[@"url"]];
    } else {
        NSLog(@"%@", @"External module");
    }
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
    [super viewDidAppear:animated];
    
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
    if (1 > self.treeIndex) {
        return [self.blobs count];
    } else {
        return [self.blobs count] + 1;
    }
}

- (UITableViewCell *) tableView: (UITableView *)tableView cellForRowAtIndexPath: (NSIndexPath *)indexPath
{
    BlobTreeCell *cell;
    if (self.treeIndex > 0 && indexPath.row == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier: @"BlobBackCell"];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier: @"BlobTreeCell"];
    }
    if (!cell) {
        if (self.treeIndex > 0 && indexPath.row == 0) {
            cell = [[BlobTreeCell alloc]
                    initWithStyle: UITableViewCellStyleDefault reuseIdentifier: @"BlobBackCell"];
        } else {
            cell = [[BlobTreeCell alloc]
                    initWithStyle: UITableViewCellStyleDefault reuseIdentifier: @"BlobTreeCell"];
        }
    }
    
    if (self.treeIndex > 0 && indexPath.row == 0) {
        [self updateMoveToParentCell: cell atIndexPath: indexPath];
    } else {
        [self updateCell: cell atIndexPath: indexPath];
    }
    return cell;
}

- (void) updateCell: (UITableViewCell *)cell atIndexPath: (NSIndexPath *)indexPath
{
    BlobTreeCell *treeCell = (BlobTreeCell *)cell;
    
    NSDictionary *data = nil;
    NSInteger row = indexPath.row;
    if (self.treeIndex > 0) {
        row -= 1;
    }
    
    if ([self.blobs count] > row) {
        data = (self.blobs)[row];
    }
    
    if ([data[@"type"] isEqualToString: @"tree"]) {
        treeCell.accessoryType = UITableViewCellAccessoryNone;
    } else {
        treeCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    NSString *name = [NSString stringWithFormat:@"%@", data[@"path"]];
    [treeCell update: name type: data[@"type"]];
}

- (void) updateMoveToParentCell: (UITableViewCell *)cell atIndexPath: (NSIndexPath *)indexPath
{
    BlobTreeCell *treeCell = (BlobTreeCell *)cell;
    treeCell.accessoryType = UITableViewCellAccessoryNone;
    treeCell.nameLabel.text = @"..";
    [treeCell update: @".." type: nil];
}

@end
