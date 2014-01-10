//
//  DTSectionModel+HeaderFooterModel.m
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 10.01.14.
//  Copyright (c) 2014 Denys Telezhkin. All rights reserved.
//

#import "DTSectionModel+HeaderFooterModel.h"

@implementation DTSectionModel (HeaderFooterModel)

-(void)setHeaderModel:(id)headerModel
{
    [self setSupplementaryModel:headerModel forKind:DTTableViewElementSectionHeader];
}

-(void)setFooterModel:(id)footerModel
{
    [self setSupplementaryModel:footerModel forKind:DTTableViewElementSectionFooter];
}

-(id)headerModel
{
    return [self supplementaryModelOfKind:DTTableViewElementSectionHeader];
}

-(id)footerModel
{
    return [self supplementaryModelOfKind:DTTableViewElementSectionFooter];
}

@end
