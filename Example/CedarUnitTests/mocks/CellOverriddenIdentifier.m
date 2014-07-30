//
//  StrangeTableViewCell.m
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 30.07.14.
//  Copyright (c) 2014 Denys Telezhkin. All rights reserved.
//

#import "CellOverriddenIdentifier.h"

@implementation CellOverriddenIdentifier

-(void)updateWithModel:(id)model
{
    
}

+(NSString *)reuseIdentifier
{
    return @"foobar";
}

@end
