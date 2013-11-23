//
//  DTTableViewSectionProtocol.h
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 23.11.13.
//  Copyright (c) 2013 Denys Telezhkin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/Coredata.h>

/**
 This protocol is designed to be compatible with NSFetchedResultsController and extend it.
 */

@protocol DTTableViewSectionProtocol <NSFetchedResultsSectionInfo>

@optional

-(id)headerModel;
-(id)footerModel;

@end
