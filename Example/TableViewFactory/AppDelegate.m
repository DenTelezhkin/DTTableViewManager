//
//  AppDelegate.m
//  TableViewFactory
//
//  Created by Denys Telezhkin on 9/28/12.
//  Copyright (c) 2012 Denys Telezhkin. All rights reserved.
//

#import "AppDelegate.h"
#import "ExampleTableViewController.h"
#import "BanksCoreDataManager.h"
@import CoreData;

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    ExampleTableViewController * exampleController = [[ExampleTableViewController alloc] init];

    UINavigationController * navController = [[UINavigationController alloc]
                                                    initWithRootViewController:exampleController];
    self.window.rootViewController = navController;
    [self.window makeKeyAndVisible];
    
    [[BanksCoreDataManager sharedInstance] preloadData];
    
    return YES;
}

-(void)applicationWillTerminate:(UIApplication *)application
{
    [[BanksCoreDataManager sharedInstance] saveContext];
}

@end
