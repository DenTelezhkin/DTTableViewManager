//
//  DTSectionModel+HeaderFooterModel.h
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 10.01.14.
//  Copyright (c) 2014 Denys Telezhkin. All rights reserved.
//

#import "DTSectionModel.h"

static NSString * const DTTableViewElementSectionHeader = @"DTTableViewElementSectionHeader";
static NSString * const DTTableViewElementSectionFooter = @"DTTableViewElementSectionFooter";

/**
 This category adds ability to set and get section footer and header model for current section.
 */

@interface DTSectionModel (HeaderFooterModel)

/**
 Set header model for current section. Header presentation depends on `DTTableViewController` sectionHeaderStyle property.
 
@param headerModel headerModel for current section
 */
-(void)setHeaderModel:(id)headerModel;

/**
 Footer model for current section. Footer presentation depends on `DTTableViewController` sectionFooterStyle property.
 
 @param footerModel footer model for current section
 */
-(void)setFooterModel:(id)footerModel;

/**
 Header model for current section.
 
 @return headerModel
 */
-(id)headerModel;

/**
 Footer model for current section.
 
 @return footerModel
 */
-(id)footerModel;

@end
