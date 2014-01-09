//
//  BanksCoreDataStorage.h
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 08.12.13.
//  Copyright (c) 2013 Denys Telezhkin. All rights reserved.
//

#import "DTCoreDataStorage.h"

@interface BanksCoreDataStorage : DTCoreDataStorage

+(NSFetchedResultsController *)banksFetchControllerWithPredicate:(NSPredicate *)predicate;

@end
