//
//  DTCellFactory.m
//  DTTableViewController
//
//  Created by Denys Telezhkin on 6/19/12.
//  Copyright (c) 2012 MLSDev. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "DTCellFactory.h"
#import "DTTableViewModelProtocol.h"

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
    NSString *modelClassName = [self classStringForModel:model];
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
    UITableViewCell <DTTableViewModelProtocol> * cell =  [table dequeueReusableCellWithIdentifier:
                                                                reuseIdentifier];
    [cell updateWithModel:model];
    return cell;
}

- (UITableViewCell *)cellWithModel:(id)model reuseIdentifier:(NSString *)reuseIdentifier
{
    Class cellClass = [self cellClassForModel:model];
    
    if ([cellClass conformsToProtocol:@protocol(DTTableViewModelProtocol)])
    {
        UITableViewCell<DTTableViewModelProtocol> * cell;

        cell = [(UITableViewCell <DTTableViewModelProtocol>  *)[cellClass alloc]
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
