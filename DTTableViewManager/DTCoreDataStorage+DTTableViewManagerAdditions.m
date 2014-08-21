//
//  DTCoreDataStorage+DTTableViewManagerAdditions.m
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 21.08.14.
//  Copyright (c) 2014 Denys Telezhkin. All rights reserved.
//

#import "DTCoreDataStorage+DTTableViewManagerAdditions.h"

@implementation DTCoreDataStorage (DTTableViewManagerAdditions)

-(id)headerModelForSectionIndex:(NSInteger)index
{
    id <NSFetchedResultsSectionInfo> section = [self.fetchedResultsController sections][index];
    return section.name;
}

@end
