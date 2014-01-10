//
//  DTTableViewController+UnitTests.h
//  DTTableViewController
//
//  Created by Denys Telezhkin on 12/26/12.
//  Copyright (c) 2012 Denys Telezhkin. All rights reserved.
//

#import "DTTableViewController.h"

@interface DTTableViewController (UnitTests)

-(BOOL)verifyTableItem:(id)item atIndexPath:(NSIndexPath *)path;
-(void)verifySection:(NSArray *)section withSectionNumber:(NSInteger)sectionNumber;
@end
