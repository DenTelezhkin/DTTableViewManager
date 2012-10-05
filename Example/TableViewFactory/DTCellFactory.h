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

@property (nonatomic,retain) NSDictionary * classMappingDictionary;

SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(DTCellFactory)

// actions
- (UITableViewCell *)cellForModel:(NSObject *)model inTable:(UITableView *)table;
- (Class)cellClassForModel:(NSObject *)model;

-(void)addObjectMappingDictionary:(NSDictionary *)mapping;
-(void)addCellClassMapping:(Class)cellClass forModel:(id)model;

@end
