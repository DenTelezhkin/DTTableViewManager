//
//  CellsFactory.h
//  TableViewFactory
//
//  Created by Denys Telezhkin on 6/20/12.
//  Copyright (c) 2012 MLSDev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SingletonProtocol.h"


@interface CellFactory : NSObject <SingletonProtocol>

// actions
- (UITableViewCell *)cellForModel:(NSObject *)model inTable:(UITableView *)table;
- (Class)cellClassForModel:(NSObject *)model;

@end
