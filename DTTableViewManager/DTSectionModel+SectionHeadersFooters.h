//
//  DTSectionModel+SectionHeadersFooters.h
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 12.10.14.
//  Copyright (c) 2014 Denys Telezhkin. All rights reserved.
//

#import <DTModelStorage/DTMemoryStorage.h>
#import "DTMemoryStorage_DTTableViewManagerAdditions.h"

#if __has_feature(nullability) // Xcode 6.3+
#pragma clang assume_nonnull begin
#else
#define nullable
#define __nullable
#endif

/**
 Category, providing getters and setters for section headers and footers
 */
@interface DTSectionModel (SectionHeadersFooters)

/**
 Retrieve table header model for current section. 
 
 @return header model
 */
-(nullable id)tableHeaderModel;

/**
 Retrieve table header model for current section.
 
 @return footer model
 */
-(nullable id)tableFooterModel;

/**
 Header model for current section.
 
 @param headerModel footer model for current section
 */
-(void)setTableSectionHeader:(nullable id)headerModel;

/**
 Footer model for current section.
 
 @param footerModel footer model for current section
 */
-(void)setTableSectionFooter:(nullable id)footerModel;

@end

#if __has_feature(nullability)
#pragma clang assume_nonnull end
#endif