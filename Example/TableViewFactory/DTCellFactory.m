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
                               forModel:(id)model
                        reuseIdentifier:(NSString *)reuseIdentifier;

- (UITableViewCell *)cellWithModel:(id)model
                   reuseIdentifier:(NSString *)reuseIdentifier;

@property (nonatomic,retain) NSMutableDictionary * mappingsDictionary;

@end



@implementation DTCellFactory

SYNTHESIZE_SINGLETON_FOR_CLASS(DTCellFactory)

@synthesize classMappingDictionary = _classMappingDictionary;


- (NSMutableDictionary *)mappingsDictionary
{
    if (!_mappingsDictionary)
        _mappingsDictionary = [[NSMutableDictionary alloc] init];
    return _mappingsDictionary;
}

- (NSDictionary *)classMappingDictionary
{
    return [[self.mappingsDictionary copy] autorelease];
}

#pragma mark - Init and destroy

- (void)dealloc
{
    self.mappingsDictionary = nil;
    [super dealloc];
}

#pragma mark - class mapping

- (void)addCellClassMapping:(Class)cellClass forModelClass:(Class)modelClass
{
    [self.mappingsDictionary setObject:NSStringFromClass(cellClass)
                                forKey:NSStringFromClass(modelClass)];
}

- (void)addObjectMappingDictionary:(NSDictionary *)mappingDictionary
{
    [self.mappingsDictionary addEntriesFromDictionary:mappingDictionary];
}

#pragma mark - actions

- (UITableViewCell *)cellForModel:(NSObject *)model
                          inTable:(UITableView *)table
                  reuseIdentifier:(NSString *)reuseIdentifier
{
    UITableViewCell *cell = [self reuseCellFromTable:table
                                            forModel:model
                                     reuseIdentifier:reuseIdentifier];

    return cell ? cell : [self cellWithModel:model reuseIdentifier:reuseIdentifier];
}

- (Class)cellClassForModel:(NSObject *)model
{
    NSString *modelClassName = NSStringFromClass([model class]);
    if ([self.mappingsDictionary objectForKey:modelClassName])
    {
        return NSClassFromString([self.mappingsDictionary objectForKey:modelClassName]);
    }
    else
    {
        NSString *reason = [NSString stringWithFormat:@"DTCellFactory does not have mapping for %@ class",
                            [model class]];
        @throw [NSException exceptionWithName:@"API misuse"
                                       reason:reason userInfo:nil];
    }
}

#pragma mark -

-(NSString *)classStringForModel:(id)model
{
    return NSStringFromClass([model class]);
}

- (UITableViewCell *)reuseCellFromTable:(UITableView *)table
                               forModel:(id)model
                        reuseIdentifier:(NSString *)reuseIdentifier
{
    UITableViewCell <TableViewModelProtocol> * cell =  [table dequeueReusableCellWithIdentifier:
                                                                reuseIdentifier];
    [cell updateWithModel:model];
    return cell;
}

- (UITableViewCell *)cellWithModel:(id)model reuseIdentifier:(NSString *)reuseIdentifier
{
    Class cellClass = [self cellClassForModel:model];
    
    if ([cellClass conformsToProtocol:@protocol(TableViewModelProtocol)])
    {
        UITableViewCell<TableViewModelProtocol> * cell;

        cell = [(UITableViewCell <TableViewModelProtocol>  *)[cellClass alloc]
                                                initWithStyle:UITableViewCellStyleSubtitle
                                              reuseIdentifier:reuseIdentifier];
        [cell updateWithModel:model];
        
        return [cell autorelease];
    }
    NSString *reason = [NSString stringWithFormat:@"cell class '%@' does not conform TableViewModelProtocol",
                        cellClass];
    @throw [NSException exceptionWithName:@"API misuse"
                                   reason:reason userInfo:nil];
    
    return nil;
}

@end
