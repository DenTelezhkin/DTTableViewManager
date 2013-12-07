//
//  DTTableViewCoreDataStorage.h
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 07.12.13.
//  Copyright (c) 2013 Denys Telezhkin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DTTableViewDataStorage.h"
#import <CoreData/CoreData.h>

@interface DTTableViewCoreDataStorage : NSObject <DTTableViewDataStorage,NSFetchedResultsControllerDelegate>

+(instancetype)storageWithFetchResultsController:(NSFetchedResultsController *)controller;

@property (nonatomic, weak) id <DTTableViewDataStorageUpdating> delegate;

@property (nonatomic, strong) NSFetchedResultsController * fetchedResultsController;

@end
