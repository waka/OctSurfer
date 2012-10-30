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
#import "ApiUrl.h"
#import "CCHttpClient.h"


@interface RepositoryViewController ()

@property (nonatomic, weak) RepositoryInfoView *infoView;
@property (nonatomic, weak) UIView *tableBgView;
@property (nonatomic, weak) UITableView *tableView;

@property (nonatomic, assign) NSInteger treeIndex;
@property (nonatomic, strong) NSString *currentTreePath;
@property (nonatomic, strong) NSString *prevTreePath;
@property (nonatomic, strong) NSArray *blobs;
@property (nonatomic, assign) Boolean isUpside;

@end


@implementation RepositoryViewController

- (id) init
{
    self = [super init];
    if (self) {
        _treeIndex = -1;
        _prevTreePath = nil;
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
    tableView.contentInset = UIEdgeInsetsMake(0, 0, 100, 0);
    tableView.scrollEnabled = YES;
    tableView.delegate = self;
    tableView.dataSource = self;
    [tableBgView addSubview: tableView];
    
    // Set self property
    self.title = self.name;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithBarButtonSystemItem: UIBarButtonSystemItemRefresh
                                              target: self
                                              action: @selector(handleRefreshClicked:)];
    self.infoView = infoView;
    self.tableBgView = tableBgView;
    self.tableView = tableView;
    
    [self getInfoData];
}

- (void) handleRefreshClicked: (id)sender
{
    [self getInfoData];
}

- (void) getInfoData
{
    NSString *url = [ApiUrl masterBranch: self.owner repository: self.name];
    CCHttpClient *client = [CCHttpClient clientWithUrl: url];
    [client getJsonWithDelegate: self success: @selector(handleGetInfoDataSuccess:) failure: nil];
}

- (void) handleGetInfoDataSuccess: (NSDictionary *)json
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
    
    [self getTreeData: data[@"commit"][@"tree"][@"url"]];
}

- (void) getTreeData: (NSString *)url
{
    self.currentTreePath = url;
    CCHttpClient *client = [CCHttpClient clientWithUrl: url];
    [client getJsonWithDelegate: self success: @selector(handleGetTreeSuccess:) failure: nil];
}

- (void) handleGetTreeSuccess: (NSDictionary *)json
{
    self.blobs = (NSArray *)json[@"tree"];
    if (self.isUpside) {
        self.treeIndex -= 1;
    } else {
        self.treeIndex += 1;
    }
    if (self.treeIndex == 0) {
        self.prevTreePath = nil;
    }
    self.isUpside = NO;
    
    [self.tableView reloadData];
}


#pragma mark - Table view delegate

- (void) tableView: (UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.treeIndex > 0 && indexPath.row == 0) {
        self.isUpside = YES;
        [self getTreeData: self.prevTreePath];
        return;
    }
    
    NSDictionary *data = nil;
    if (self.treeIndex > 0) {
        data = (self.blobs)[indexPath.row - 1];
    } else {
        data = (self.blobs)[indexPath.row];
    }
    
    if ([data[@"type"] isEqualToString: @"blob"]) {
        SourceViewController *sourceView = [[SourceViewController alloc] init];
        sourceView.name = data[@"path"];
        sourceView.url = data[@"url"];
        [self.navigationController pushViewController: sourceView animated: YES];
    } else if ([data[@"type"] isEqualToString: @"tree"]) {
        self.prevTreePath = self.currentTreePath;
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
    NSInteger blobCount = [self.blobs count];
    if (blobCount == 0) {
        return 0;
    } else {
        return [self.blobs count] + 1;
    }
}

- (UITableViewCell *) tableView: (UITableView *)tableView cellForRowAtIndexPath: (NSIndexPath *)indexPath
{
    BlobTreeCell *cell = [tableView dequeueReusableCellWithIdentifier: @"BlobTreeCell"];
    if (!cell) {
        // Configure the cell...
        cell = [[BlobTreeCell alloc]
                initWithStyle: UITableViewCellStyleDefault reuseIdentifier: @"BlobTreeCell"];
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
    treeCell.nameLabel.text = name;
}

- (void) updateMoveToParentCell: (UITableViewCell *)cell atIndexPath: (NSIndexPath *)indexPath
{
    BlobTreeCell *treeCell = (BlobTreeCell *)cell;
    treeCell.accessoryType = UITableViewCellAccessoryNone;
    treeCell.nameLabel.text = @"..";
}

@end
