//
//  AppleCoreDataExampleController.m
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 08.12.13.
//  Copyright (c) 2013 Denys Telezhkin. All rights reserved.
//

#import "AppleCoreDataExampleController.h"
#import "BanksCoreDataManager.h"
#import "Event.h"
#import "EventCell.h"

@implementation AppleCoreDataExampleController

#pragma mark - view lifecycle

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem * barItem = [[UIBarButtonItem alloc]
                                 initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                 target:self
                                 action:@selector(addButtonTapped)];
    self.navigationItem.rightBarButtonItem = barItem;
    
    [self registerCellClass:[EventCell class] forModelClass:[Event class]];
    DTCoreDataStorage * storage = [DTCoreDataStorage storageWithFetchResultsController:[self timeStampFetchedResultsController]];
    self.storage = storage;
}

#pragma mark - actions

-(void)addButtonTapped
{
    DTCoreDataStorage * storage = (DTCoreDataStorage *)self.storage;
    
    NSManagedObjectContext *context = [storage.fetchedResultsController managedObjectContext];
    NSEntityDescription *entity = [[storage.fetchedResultsController fetchRequest] entity];
    
    Event * event = [NSEntityDescription insertNewObjectForEntityForName:[entity name]
                                                  inManagedObjectContext:context];
    event.timeStamp = [NSDate date];
    
    [context save:nil];
}

#pragma mark - FetchedResultsController

- (NSFetchedResultsController *)timeStampFetchedResultsController
{
    NSFetchedResultsController * controller = nil;
    NSManagedObjectContext * context = [[BanksCoreDataManager sharedInstance] managedObjectContext];
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([Event class])];
    [fetchRequest setFetchBatchSize:20];
    [fetchRequest setSortDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"timeStamp" ascending:NO]]];
    
    controller = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                     managedObjectContext:context
                                                       sectionNameKeyPath:nil
                                                                cacheName:@"timeStamp"];
    [controller performFetch:nil];
    return controller;
}

#pragma mark - UITableViewDelegate

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        DTCoreDataStorage * storage = (DTCoreDataStorage *)self.storage;
        NSManagedObjectContext *context = [storage.fetchedResultsController managedObjectContext];
        [context deleteObject:[storage.fetchedResultsController objectAtIndexPath:indexPath]];
        
        [context save:nil];
    }
}
@end
