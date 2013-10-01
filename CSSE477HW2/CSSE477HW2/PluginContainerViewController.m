//
//  PluginContainerViewController.m
//  CSSE477HW2
//
//  Created by David Savrda on 9/30/13.
//  Copyright (c) 2013 David Savrda. All rights reserved.
//

#import "PluginContainerViewController.h"
#import "CSBundle.h"

@interface PluginContainerViewController () {
    dispatch_source_t _source;
    NSArray *_listOfPlugins;
    UIViewController *_statusItem;
}

@end

@implementation PluginContainerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]))
    {
        _statusItem = [[UIViewController alloc]init];
        _statusItem.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Status" image:nil tag:0];
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
    [viewControllers addObject:_statusItem];
    for (NSBundle *plugin in _listOfPlugins)
    {
        NSString *bundleName = [plugin objectForInfoDictionaryKey:(__bridge NSString *)kCFBundleNameKey];
        UIViewController <CSBundle> *viewController = [[[plugin principalClass] alloc] init];
        [viewController setBundle:plugin];
        
        NSString *iconName = [plugin objectForInfoDictionaryKey:@"CFBundleIconFile"];
        NSString *iconPath = [plugin pathForResource:iconName.stringByDeletingPathExtension ofType:iconName.pathExtension];
        UIImage *pluginIcon = [UIImage imageWithCGImage:[UIImage imageWithContentsOfFile:iconPath].CGImage scale:2 orientation:UIImageOrientationUp];
        viewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:bundleName image:pluginIcon tag:0];
        
        [viewControllers addObject:viewController];
    }
    
    [self setViewControllers:viewControllers];
}

- (void)updatePluginList
{
    NSError *__autoreleasing fileError;
    NSArray *pluginFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:pluginsDirectoryPath() error:&fileError];
    
    NSMutableArray *plugins = [NSMutableArray array];
    for (NSString *pluginFilename in pluginFiles)
    {
        NSBundle *plugin = [[NSBundle alloc] initWithPath:[pluginsDirectoryPath() stringByAppendingPathComponent:pluginFilename]];
        if (!plugin)
            continue;
        
        NSError *__autoreleasing error;
        [plugin loadAndReturnError:&error];
        [plugins addObject:plugin];
    }
    
    _listOfPlugins = plugins;
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
