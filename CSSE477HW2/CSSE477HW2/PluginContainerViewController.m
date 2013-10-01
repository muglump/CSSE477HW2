//
//  PluginContainerViewController.m
//  CSSE477HW2
//
//  Created by David Savrda on 9/30/13.
//  Copyright (c) 2013 David Savrda. All rights reserved.
//

#import "PluginContainerViewController.h"

@interface PluginContainerViewController () {
    dispatch_source_t _source;
    NSArray *_listOfPlugins;
}

@end

@implementation PluginContainerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]))
    {
        [self beginWatchingPluginDirectory];
        [self updatePluginList];
    }
    
    return self;
}

static inline NSString *pluginsDirectoryPath()
{
    NSString *libraryDirectory = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES).firstObject;
    NSString *pluginsDirectory = [libraryDirectory stringByAppendingPathComponent:@"Plugins"];
    
    return pluginsDirectory;
}

#pragma mark - UI Updates

- (void)updateTabBar
{
    NSMutableArray *viewControllers = [NSMutableArray array];
    for (NSString *plugin in _listOfPlugins)
    {
        UIViewController *viewController = [[UIViewController alloc] init];
        viewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:plugin image:nil tag:0];
        [viewControllers addObject:viewController];
    }
    
    [self setViewControllers:viewControllers];
}

- (void)updatePluginList
{
    NSError *__autoreleasing fileError;
    _listOfPlugins = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:pluginsDirectoryPath() error:&fileError];
    
    [self updateTabBar];
}

#pragma mark - Plugin Directory Monitoring

- (void)beginWatchingPluginDirectory
{
    NSError *__autoreleasing fileError;
    [[NSFileManager defaultManager] createDirectoryAtPath:pluginsDirectoryPath() withIntermediateDirectories:YES attributes:nil error:&fileError];
    
    int fileDescriptor = open([pluginsDirectoryPath() fileSystemRepresentation], O_EVTONLY);
    _source = dispatch_source_create(DISPATCH_SOURCE_TYPE_VNODE, fileDescriptor, DISPATCH_VNODE_WRITE, dispatch_get_main_queue());
    
    dispatch_source_set_event_handler(_source, ^{
        [self updatePluginList];
    });
    
    dispatch_source_set_cancel_handler(_source, ^{
        close(fileDescriptor);
    });
    
    dispatch_resume(_source);
}

- (void)stopWatchingPluginDirectory
{
    dispatch_source_cancel(_source);
    _source = nil;
}

@end
