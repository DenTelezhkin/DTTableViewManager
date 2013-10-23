//
//  StoryboardController.m
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 23.10.13.
//  Copyright (c) 2013 Denys Telezhkin. All rights reserved.
//

#import "StoryboardController.h"
#import "TextCell.h"

@implementation StoryboardController


- (void)viewDidLoad
{
    [super viewDidLoad];
	
    [self registerCellClass:[TextCell class]
              forModelClass:[NSString class]];
    
    [self addTableItems:@[@"Row 1", @"Row 2", @"Row 3"]];
}

@end
