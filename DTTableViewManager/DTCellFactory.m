//
//  DTCellFactory.m
//  DTTableViewManager
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
#import "DTTableViewModelTransfer.h"
#import "UIView+Loading.h"

@interface DTCellFactory ()

@property (nonatomic,strong) NSMutableDictionary * cellMappingsDictionary;
@property (nonatomic,strong) NSMutableDictionary * headerMappingsDictionary;
@property (nonatomic,strong) NSMutableDictionary * footerMappingsDictionary;

@end

@implementation DTCellFactory

- (NSMutableDictionary *)cellMappingsDictionary
{
    if (!_cellMappingsDictionary)
        _cellMappingsDictionary = [[NSMutableDictionary alloc] init];
    return _cellMappingsDictionary;
}

-(NSMutableDictionary *)headerMappingsDictionary
{
    if (!_headerMappingsDictionary)
        _headerMappingsDictionary = [[NSMutableDictionary alloc] init];
    return _headerMappingsDictionary;
}

-(NSMutableDictionary *)footerMappingsDictionary
{
    if (!_footerMappingsDictionary)
        _footerMappingsDictionary = [[NSMutableDictionary alloc] init];
    return _footerMappingsDictionary;
}

#pragma mark - class mapping

- (void)setCellClassMapping:(Class)cellClass forModelClass:(Class)modelClass
{
    [self.cellMappingsDictionary setObject:NSStringFromClass(cellClass)
                                    forKey:NSStringFromClass(modelClass)];
}

-(void)setHeaderClassMapping:(Class)headerClass forModelClass:(Class)modelClass
{
    [self.headerMappingsDictionary setObject:NSStringFromClass(headerClass)
                                      forKey:NSStringFromClass(modelClass)];
}

-(void)setFooterClassMapping:(Class)footerClass forModelClass:(Class)modelClass
{
    [self.footerMappingsDictionary setObject:NSStringFromClass(footerClass)
                                      forKey:NSStringFromClass(modelClass)];
}

#pragma mark - reuse

- (UITableViewCell *)reuseCellFromTable:(UITableView *)table
                               forModel:(id)model
                        reuseIdentifier:(NSString *)reuseIdentifier
{
    UITableViewCell <DTTableViewModelTransfer> * cell =  [table dequeueReusableCellWithIdentifier:
                                                          reuseIdentifier];
    [cell updateWithModel:model];
    return cell;
}


//This method should return nil if no class is registered
-(UIView *)reuseHeaderFooterViewFromTable:(UITableView *)table
                                  forModel:(id)model
                           reuseIdentifier:(NSString *)reuseIdentifier
{
   if ([table respondsToSelector:@selector(dequeueReusableHeaderFooterViewWithIdentifier:)])
   {
       UIView <DTTableViewModelTransfer> * view =
       [table dequeueReusableHeaderFooterViewWithIdentifier:reuseIdentifier];
       
       [view updateWithModel:model];
       
       return view;
   }
    return nil;
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

-(UIView *)headerViewForModel:(id)model
                  inTableView:(UITableView *)tableView
              reuseIdentifier:(NSString *)reuseIdentifier
{
    UIView * view = [self reuseHeaderFooterViewFromTable:tableView
                                                forModel:model
                                         reuseIdentifier:reuseIdentifier];
    return view ? view : [self headerViewForModel:model inTableView:tableView];
}

-(UIView *)footerViewForModel:(id)model
                  inTableView:(UITableView *)tableView
              reuseIdentifier:(NSString *)reuseIdentifier
{
    UIView * view = [self reuseHeaderFooterViewFromTable:tableView forModel:model
                                         reuseIdentifier:reuseIdentifier];
    
    return view? view : [self footerViewForModel:model inTableView:tableView];
}

- (Class)cellClassForModel:(NSObject *)model
{
    NSString *modelClassName = [self classStringForModel:model];
    if ([self.cellMappingsDictionary objectForKey:modelClassName])
    {
        return NSClassFromString([self.cellMappingsDictionary objectForKey:modelClassName]);
    }
    else
    {
        NSString *reason = [NSString stringWithFormat:@"DTCellFactory does not have cell mapping for %@ class",
                            [model class]];
        @throw [NSException exceptionWithName:@"API misuse"
                                       reason:reason userInfo:nil];
    }
}

-(Class)headerClassForModel:(id)model
{
    NSString *modelClassName = NSStringFromClass([model class]);
    if ([self.headerMappingsDictionary objectForKey:modelClassName])
    {
        return NSClassFromString([self.headerMappingsDictionary objectForKey:modelClassName]);
    }
    else {
        NSString *reason = [NSString stringWithFormat:@"DTCellFactory does not have header mapping for %@ class",
                            [model class]];
        @throw [NSException exceptionWithName:@"API misuse"
                                       reason:reason userInfo:nil];
    }
}

-(Class)footerClassForModel:(id)model
{
    NSString *modelClassName = NSStringFromClass([model class]);
    if ([self.footerMappingsDictionary objectForKey:modelClassName])
    {
        return NSClassFromString([self.footerMappingsDictionary objectForKey:modelClassName]);
    }
    else {
        NSString *reason = [NSString stringWithFormat:@"DTCellFactory does not have footer mapping for %@ class",
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

- (UITableViewCell *)cellWithModel:(id)model reuseIdentifier:(NSString *)reuseIdentifier
{
    Class cellClass = [self cellClassForModel:model];
    
    if ([cellClass conformsToProtocol:@protocol(DTTableViewModelTransfer)])
    {
        UITableViewCell<DTTableViewModelTransfer> * cell;

        cell = [(UITableViewCell <DTTableViewModelTransfer>  *)[cellClass alloc]
                                                initWithStyle:UITableViewCellStyleSubtitle
                                              reuseIdentifier:reuseIdentifier];
        [cell updateWithModel:model];
        
        return cell;
    }
    NSString *reason = [NSString stringWithFormat:@"cell class '%@' does not conform DTTableViewModelProtocol",
                        cellClass];
    @throw [NSException exceptionWithName:@"API misuse"
                                   reason:reason userInfo:nil];
    
    return nil;
}

-(UIView *)headerViewForModel:(id)model
                  inTableView:(UITableView *)tableView
{
    Class headerClass = [self headerClassForModel:model];
    
    if([headerClass conformsToProtocol:@protocol(DTTableViewModelTransfer)])
    {
        UIView <DTTableViewModelTransfer> * headerView;
        
        headerView = [headerClass loadFromXib];
        [headerView updateWithModel:model];
        
        return headerView;
    }
    NSString *reason = [NSString stringWithFormat:@"header class '%@' does not conform DTTableViewModelProtocol",
                        headerClass];
    @throw [NSException exceptionWithName:@"API misuse"
                                   reason:reason userInfo:nil];
    
    return nil;
}

-(UIView *)footerViewForModel:(id)model inTableView:(UITableView *)tableView
{
    Class footerClass = [self footerClassForModel:model];
    
    if([footerClass conformsToProtocol:@protocol(DTTableViewModelTransfer)])
    {
        UIView <DTTableViewModelTransfer> * footerView;
        
        footerView = [footerClass loadFromXib];
        [footerView updateWithModel:model];
        
        return footerView;
    }
    NSString *reason = [NSString stringWithFormat:@"footer class '%@' does not conform DTTableViewModelProtocol",
                        footerClass];
    @throw [NSException exceptionWithName:@"API misuse"
                                   reason:reason userInfo:nil];
    
    return nil;
}

@end
