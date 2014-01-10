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

@interface DTSectionModel (HeaderFooterModel)

-(void)setHeaderModel:(id)headerModel;
-(void)setFooterModel:(id)footerModel;

-(id)headerModel;
-(id)footerModel;

@end
