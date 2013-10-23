//
//  TextCell.m
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 23.10.13.
//  Copyright (c) 2013 Denys Telezhkin. All rights reserved.
//

#import "TextCell.h"

@implementation TextCell

-(void)updateWithModel:(id)model
{
    self.textLabel.text = model;
}

@end
