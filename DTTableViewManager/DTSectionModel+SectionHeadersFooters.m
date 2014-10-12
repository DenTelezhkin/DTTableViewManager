//
//  DTSectionModel+SectionHeadersFooters.m
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 12.10.14.
//  Copyright (c) 2014 Denys Telezhkin. All rights reserved.
//

#import "DTSectionModel+SectionHeadersFooters.h"

@implementation DTSectionModel (SectionHeadersFooters)

-(id)tableHeaderModel
{
    return [self supplementaryModelOfKind:DTTableViewElementSectionHeader];
}

-(id)tableFooterModel
{
    return [self supplementaryModelOfKind:DTTableViewElementSectionFooter];
}

-(void)setTableSectionHeader:(id)model
{
    [self setSupplementaryModel:model forKind:DTTableViewElementSectionHeader];
}

-(void)setTableSectionFooter:(id)model
{
    [self setSupplementaryModel:model forKind:DTTableViewElementSectionFooter];
}

@end
