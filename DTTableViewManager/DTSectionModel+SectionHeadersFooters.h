//
//  DTSectionModel+SectionHeadersFooters.h
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 12.10.14.
//  Copyright (c) 2014 Denys Telezhkin. All rights reserved.
//

#import "DTSectionModel.h"
#import "DTMemoryStorage_DTTableViewManagerAdditions.h"
#import "DTMemoryStorage.h"

/**
 Category, providing getters and setters for section headers and footers
 */
@interface DTSectionModel (SectionHeadersFooters)

/**
 Retrieve table header model for current section. 
 
 @return header model
 */
-(id)tableHeaderModel;

/**
 Retrieve table header model for current section.
 
 @return footer model
 */
-(id)tableFooterModel;

/**
 Header model for current section.
 
 @param headerModel footer model for current section
 */
-(void)setTableSectionHeader:(id)headerModel;

/**
 Footer model for current section.
 
 @param footerModel footer model for current section
 */
-(void)setTableSectionFooter:(id)footerModel;

@end
