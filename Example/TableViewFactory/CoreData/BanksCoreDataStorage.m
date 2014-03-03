//
//  BanksCoreDataStorage.m
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 08.12.13.
//  Copyright (c) 2013 Denys Telezhkin. All rights reserved.
//

#import "BanksCoreDataStorage.h"
#import "Bank.h"
#import "BanksCoreDataManager.h"

@implementation BanksCoreDataStorage

+(NSFetchedResultsController *)banksFetchControllerWithPredicate:(NSPredicate *)predicate
{
    NSFetchedResultsController * controller = nil;
    
    NSManagedObjectContext * context = [[BanksCoreDataManager sharedInstance] managedObjectContext];
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([Bank class])];
    [fetchRequest setFetchBatchSize:20];
    [fetchRequest setSortDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"zip"
                                                                   ascending:YES]]];
    if (predicate)
    {
       [fetchRequest setPredicate:predicate];
    }
    
    controller = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                     managedObjectContext:context
                                                       sectionNameKeyPath:@"state"
                                                                cacheName:nil];
    [controller performFetch:nil];
    return controller;
}

#pragma mark DTTableViewStorage protocol

-(id)headerModelForSectionIndex:(NSUInteger)index
{
    id <NSFetchedResultsSectionInfo> section = [self.fetchedResultsController sections][index];
    return section.name;
}

-(instancetype)searchingStorageForSearchString:(NSString *)searchString inSearchScope:(NSInteger)searchScope
{
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"name contains %@ OR city contains %@ OR state contains %@",searchString,searchString,searchString];

    return [[self class] storageWithFetchResultsController:[[self class] banksFetchControllerWithPredicate:predicate]];
}

@end
