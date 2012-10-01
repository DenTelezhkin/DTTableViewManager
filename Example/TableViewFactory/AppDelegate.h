//
//  AppDelegate.h
//  TableViewFactory
//
//  Created by Denys Telezhkin on 9/28/12.
//  Copyright (c) 2012 Denys Telezhkin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDataStore.h"

@class ExampleTableViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) ExampleTableViewController *viewController;

@property (nonatomic, readonly) AppDataStore *dataStore;

@end
