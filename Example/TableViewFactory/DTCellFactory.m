//
//  CellsFactory.m
//  TableViewFactory
//
//  Created by Denys Telezhkin on 6/20/12.
//  Copyright (c) 2012 MLSDev. All rights reserved.
//

#import "DTCellFactory.h"

#import "Example.h"
#import "ExampleCell.h"
#import "TableViewModelProtocol.h"




@interface DTCellFactory ()
- (UITableViewCell *)reuseCellFromTable:(UITableView *)table
                             identifier:(NSString *)identifier
                               andModel:(id)model;
- (UITableViewCell *)cellWithIdentifier:(NSString *)identifier
                                      andModel:(id)model;
- (Class)cellClassWithIdentifier:(NSString *)identifier;

@property (nonatomic,retain) NSMutableDictionary * mappingsDictionary;

@end



@implementation DTCellFactory

SYNTHESIZE_SINGLETON_FOR_CLASS(DTCellFactory)

@synthesize classMappingDictionary = _classMappingDictionary;


-(NSMutableDictionary *)mappingsDictionary
{
    if (!_mappingsDictionary)
        _mappingsDictionary = [[NSMutableDictionary alloc] init];
    return _mappingsDictionary;
}

-(NSDictionary *)classMappingDictionary
{
    return [self.mappingsDictionary copy];
}

#pragma mark - Init and destroy

- (void)dealloc
{
    self.mappingsDictionary = nil;
    [super dealloc];
}

#pragma mark - class mapping

-(void)addCellClassMapping:(Class)cellClass forModel:(id)model
{
    [self.mappingsDictionary setObject:NSStringFromClass(cellClass)
                                forKey:NSStringFromClass([model class])];
}

-(void)addObjectMappingDictionary:(NSDictionary *)mappingDictionary
{
    [self.mappingsDictionary addEntriesFromDictionary:mappingDictionary];
}

#pragma mark - actions

- (UITableViewCell *)cellForModel:(NSObject *)model inTable:(UITableView *)table
{
    NSString *modelClassName = NSStringFromClass([model class]);
    UITableViewCell *cell = [self reuseCellFromTable:table
                                          identifier:modelClassName
                                            andModel:model];
    return cell ? cell : [self cellWithIdentifier:modelClassName andModel:model];
}

- (Class)cellClassForModel:(NSObject *)model
{
    NSString *modelClassName = NSStringFromClass([model class]);
    return NSClassFromString([self.mappingsDictionary objectForKey:modelClassName]);
}

#pragma mark -
#pragma mark private

#warning TODO add option not to reuse cells

- (UITableViewCell *)reuseCellFromTable:(UITableView *)table
                             identifier:(NSString *)identifier
                               andModel:(id)model
{
    UITableViewCell <TableViewModelProtocol> * cell =  [table dequeueReusableCellWithIdentifier:identifier];
    [cell updateWithModel:model];
    return cell;
}

- (UITableViewCell *)cellWithIdentifier:(NSString *)identifier andModel:(id)model
{
    Class cellClass = [self cellClassForModel:model];
    
    if ([cellClass conformsToProtocol:@protocol(TableViewModelProtocol)])
    {
        UITableViewCell<TableViewModelProtocol> * cell = [(UITableViewCell <TableViewModelProtocol>  *)[cellClass alloc]
                                                          initWithStyle:UITableViewCellStyleSubtitle
                                                          reuseIdentifier:identifier];
        [cell updateWithModel:model];
        
        return [cell autorelease];
    }
    NSString *reason = [NSString stringWithFormat:@"cell class '%@' does not conform TableViewModelProtocol",
                        cellClass];
    @throw [NSException exceptionWithName:@"API misuse"
                                   reason:reason userInfo:nil];
    
    return nil;
}

- (Class)cellClassWithIdentifier:(NSString *)identifier
{
    NSString *cellClassName = [self.classMappingDictionary valueForKey:identifier];
    Class cellClass = NSClassFromString(cellClassName);
    if (!cellClass)
    {
        NSString *reason = [NSString stringWithFormat:@"No cell class for model '%@'",
                            identifier];
        @throw [NSException exceptionWithName:@"No cell class for model" 
                                       reason:reason userInfo:nil];
    }
    return cellClass;
}

@end
