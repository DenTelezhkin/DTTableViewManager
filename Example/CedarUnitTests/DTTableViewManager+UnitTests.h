//
//  DTTableViewManager+UnitTests.h
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 12/26/12.
//  Copyright (c) 2012 Denys Telezhkin. All rights reserved.
//

#import "DTTableViewManager.h"

@interface DTTableViewManager (UnitTests)

-(BOOL)verifyTableItem:(id)item atIndexPath:(NSIndexPath *)path;
@end
