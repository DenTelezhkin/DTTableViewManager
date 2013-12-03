//
//  StoryboardController.m
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 23.10.13.
//  Copyright (c) 2013 Denys Telezhkin. All rights reserved.
//

#import "StoryboardController.h"
#import "PrototypedCell.h"

@implementation StoryboardController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self registerCellClass:[PrototypedCell class]
              forModelClass:[NSString class]];
    
    [(DTTableViewMemoryStorage *)self.dataStorage addTableItems:@[@"Row 1", @"Row 2", @"Row 3"]];
}

@end
