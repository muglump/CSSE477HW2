//
//  StatusViewController.m
//  CSSE477HW2
//
//  Created by David Savrda on 10/1/13.
//  Copyright (c) 2013 David Savrda. All rights reserved.
//

#import "StatusViewController.h"
#import "CSBundle.h"

@interface StatusViewController (){
    NSMutableArray *_statuses;
    NSUInteger _lastSeenStatusesCount;
}

@end

@implementation StatusViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
    {
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Status" image:[UIImage imageNamed:@"Dashboard"] tag:0];
        self.navigationItem.title = @"Status";
        
        _statuses = [[NSMutableArray alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNewStatus:)
                                                     name:CSBundlePostStatusUpdateNotification object:nil];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.rowHeight = 88;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    _lastSeenStatusesCount = _statuses.count;
    [self updateTabBarItem];
}

- (void)updateTabBarItem
{
    self.tabBarItem.badgeValue = (_lastSeenStatusesCount == _statuses.count) ? nil : [NSString stringWithFormat:@"%lu", _statuses.count - _lastSeenStatusesCount];
}

- (void)handleNewStatus:(NSNotification *)notification
{
    [_statuses addObject:notification];
    [self.tableView reloadData];
    
    if (self.tabBarController.selectedViewController == self)
        _lastSeenStatusesCount = _statuses.count;
    [self updateTabBarItem];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _statuses.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"standard"];
    if (!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"standard"];
    
    NSNotification *notification = _statuses[indexPath.row];
    NSBundle *plugin = notification.object;
    
    cell.detailTextLabel.text = notification.userInfo[CSBundlePostStatusUpdateMessageKey];
    cell.textLabel.text = [plugin objectForInfoDictionaryKey:(__bridge NSString *)kCFBundleNameKey];
    
    NSString *iconName = [plugin objectForInfoDictionaryKey:@"CFBundleIconFile"];
    NSString *iconPath = [plugin pathForResource:iconName.stringByDeletingPathExtension ofType:iconName.pathExtension];
    UIImage *pluginIcon = [UIImage imageWithCGImage:[UIImage imageWithContentsOfFile:iconPath].CGImage scale:2 orientation:UIImageOrientationUp];
    cell.imageView.image = [pluginIcon imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle != UITableViewCellEditingStyleDelete)
        return;
    
    [_statuses removeObjectAtIndex:indexPath.row];
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

@end
