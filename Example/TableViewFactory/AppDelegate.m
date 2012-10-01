//
//  AppDelegate.m
//  TableViewFactory
//
//  Created by Denys Telezhkin on 9/28/12.
//  Copyright (c) 2012 Denys Telezhkin. All rights reserved.
//

#import "AppDelegate.h"

#import "ExampleTableViewController.h"

@implementation AppDelegate

@synthesize dataStore = _dataStore;

- (void)dealloc
{
    [_window release];
    [_viewController release];
    [super dealloc];
}

#pragma mark -
#pragma mark data store

- (AppDataStore *)dataStore
{
    if (!_dataStore)
    {
        _dataStore = [AppDataStore new];
    }
    return _dataStore;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    self.viewController = [[[ExampleTableViewController alloc] init] autorelease];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    return YES;
}

@end
