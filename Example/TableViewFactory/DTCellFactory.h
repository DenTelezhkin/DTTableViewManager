//
//  CellsFactory.h
//  TableViewFactory
//
//  Created by Denys Telezhkin on 6/20/12.
//  Copyright (c) 2012 MLSDev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SynthesizeSingleton.h"



@interface DTCellFactory : NSObject

@property (readonly) NSDictionary * classMappingDictionary;

SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(DTCellFactory)

// actions
- (UITableViewCell *)cellForModel:(NSObject *)model inTable:(UITableView *)table;
- (Class)cellClassForModel:(NSObject *)model;

///////////////////////
// Mapping
// 

// Designated mapping method:
-(void)addCellClassMapping:(Class)cellClass forModelClass:(Class)modelClass;

// Dictionary should contain NSStringFromClass values and keys
-(void)addObjectMappingDictionary:(NSDictionary *)mappingDictionary;

@end
