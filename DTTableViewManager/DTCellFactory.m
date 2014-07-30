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
#import "DTModelTransfer.h"
#import "UIView+DTLoading.h"
#import "DTDefaultCellModel.h"
#import "DTDefaultHeaderFooterModel.h"

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

#pragma mark - check for features

-(BOOL)nibExistsWIthNibName:(NSString *)nibName
{
    NSString *path = [[NSBundle mainBundle] pathForResource:nibName
                                                     ofType:@"nib"];
    if (path)
    {
        return YES;
    }
    return NO;
}

#pragma mark - class mapping

-(void)registerCellClass:(Class)cellClass forModelClass:(Class)modelClass
{
    NSString * reuseIdentifier = [self reuseIdentifierFromClass:cellClass];
    UITableViewCell * tableCell = [[self.delegate tableView] dequeueReusableCellWithIdentifier:reuseIdentifier];
    
    if (!tableCell)
    {
        // Storyboard prototype cell
        [[self.delegate tableView] registerClass:cellClass
                          forCellReuseIdentifier:reuseIdentifier];
        
        if ([self nibExistsWIthNibName:NSStringFromClass(cellClass)])
        {
            [self registerNibNamed:NSStringFromClass(cellClass)
                      forCellClass:cellClass
                        modelClass:modelClass];
        }
    }

    [self.cellMappingsDictionary setObject:NSStringFromClass(cellClass)
                                    forKey:[self modelClassStringForClass:modelClass]];
}

-(void)registerNibNamed:(NSString *)nibName
           forCellClass:(Class)cellClass
             modelClass:(Class)modelClass
{
    NSAssert([self nibExistsWIthNibName:nibName], @"Nib should exist for registerNibNamed method");
    
    [[self.delegate tableView] registerNib:[UINib nibWithNibName:nibName bundle:nil]
                    forCellReuseIdentifier:[self reuseIdentifierFromClass:cellClass]];
    
    [self.cellMappingsDictionary setObject:NSStringFromClass(cellClass)
                                    forKey:[self modelClassStringForClass:modelClass]];
}

-(void)registerHeaderClass:(Class)headerClass forModelClass:(Class)modelClass
{
    [self registerNibNamed:NSStringFromClass(headerClass)
            forHeaderClass:headerClass
                modelClass:modelClass];
}

-(void)registerNibNamed:(NSString *)nibName forHeaderClass:(Class)headerClass
             modelClass:(Class)modelClass
{
    NSAssert([self nibExistsWIthNibName:nibName], @"Nib should exist for registerNibNamed method");
    
    if ([headerClass isSubclassOfClass:[UITableViewHeaderFooterView class]])
    {
        [[self.delegate tableView] registerNib:[UINib nibWithNibName:nibName bundle:nil]
            forHeaderFooterViewReuseIdentifier:[self reuseIdentifierFromClass:headerClass]];
    }
    
    [self.headerMappingsDictionary setObject:NSStringFromClass(headerClass)
                                      forKey:[self modelClassStringForClass:modelClass]];
}

-(void)registerFooterClass:(Class)footerClass forModelClass:(Class)modelClass
{
    [self registerNibNamed:NSStringFromClass(footerClass)
            forFooterClass:footerClass
                modelClass:modelClass];
}

-(void)registerNibNamed:(NSString *)nibName forFooterClass:(Class)footerClass
             modelClass:(Class)modelClass
{
    NSAssert([self nibExistsWIthNibName:nibName], @"Nib should exist for registerNibNamed method");
    
    if ([footerClass isSubclassOfClass:[UITableViewHeaderFooterView class]])
    {
        [[self.delegate tableView] registerNib:[UINib nibWithNibName:nibName bundle:nil]
            forHeaderFooterViewReuseIdentifier:[self reuseIdentifierFromClass:footerClass]];
    }
    
    [self.footerMappingsDictionary setObject:NSStringFromClass(footerClass)
                                      forKey:[self modelClassStringForClass:modelClass]];
}

-(void)setFooterClassMapping:(Class)footerClass forModelClass:(Class)modelClass
{
    [self.footerMappingsDictionary setObject:NSStringFromClass(footerClass)
                                      forKey:[self modelClassStringForClass:modelClass]];
}

#pragma mark - actions

-(UITableViewCell *)cellForReuseIdentifier:(NSString *)reuseIdentifier
                                     style:(UITableViewCellStyle)style
                                 cellClass:(Class)cellClass
                        configurationBlock:(DTCellConfigurationBlock)configurationBlock
{
    UITableViewCell * cell = nil;
    
    if (reuseIdentifier)
    {
        cell = [[self.delegate tableView] dequeueReusableCellWithIdentifier:reuseIdentifier];
    }
    if (!cell)
    {
        cell = [[cellClass alloc] initWithStyle:style reuseIdentifier:reuseIdentifier];
    }
    if (configurationBlock)
    {
        configurationBlock(cell);
    }
    return cell;
}

- (UITableViewCell *)cellForModel:(id)model
{
    if ([model isKindOfClass:[DTDefaultCellModel class]])
    {
        DTDefaultCellModel * defaultModel = model;
        return [self cellForReuseIdentifier:defaultModel.reuseIdentifier
                                      style:defaultModel.cellStyle
                                  cellClass:[UITableViewCell class]
                         configurationBlock:defaultModel.cellConfigurationBlock];
    }
    
    Class cellClass = [self cellClassForModel:model];
    
    UITableViewCell <DTModelTransfer> *cell = (id)[self cellForReuseIdentifier:[self reuseIdentifierFromClass:cellClass]
                                                                         style:UITableViewCellStyleDefault
                                                                     cellClass:cellClass
                                                            configurationBlock:nil];
    [cell updateWithModel:model];
    
    return cell;
}

-(UIView *)headerFooterViewForReuseIdentifier:(NSString *)reuseIdentifier
                                    viewClass:(Class)viewClass
                           configurationBlock:(DTHeaderFooterViewConfigurationBlock)configurationBlock
{
    UIView * view = nil;
    
    if (reuseIdentifier)
    {
        view = [[self.delegate tableView] dequeueReusableHeaderFooterViewWithIdentifier:reuseIdentifier];
    }
    if (!view && (viewClass == [UITableViewHeaderFooterView class]))
    {
        view = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:reuseIdentifier];
    }
    if (!view)
    {
        view = [viewClass dt_loadFromXib];
    }
    if (configurationBlock)
    {
        configurationBlock((UITableViewHeaderFooterView *)view);
    }
    return view;
}

-(UIView *)headerViewForModel:(id)model
{
    if ([model isKindOfClass:[DTDefaultHeaderFooterModel class]])
    {
        DTDefaultHeaderFooterModel * headerFooter = model;
        return [self headerFooterViewForReuseIdentifier:headerFooter.reuseIdentifier
                                              viewClass:[UITableViewHeaderFooterView class]
                                     configurationBlock:headerFooter.viewConfigurationBlock];
    }
    
    Class headerClass = [self headerClassForModel:model];
    
    UIView <DTModelTransfer> * view = (id)[self headerFooterViewForReuseIdentifier:[self reuseIdentifierFromClass:headerClass]
                                                                         viewClass:headerClass
                                                                configurationBlock:nil];
    [view updateWithModel:model];

    return view;
}

-(UIView *)footerViewForModel:(id)model
{
    if ([model isKindOfClass:[DTDefaultHeaderFooterModel class]])
    {
        DTDefaultHeaderFooterModel * headerFooter = model;
        return [self headerFooterViewForReuseIdentifier:headerFooter.reuseIdentifier
                                              viewClass:[UITableViewHeaderFooterView class]
                                     configurationBlock:headerFooter.viewConfigurationBlock];
    }
    
    Class footerClass = [self footerClassForModel:model];
    
    UIView <DTModelTransfer> * view = (id)[self headerFooterViewForReuseIdentifier:[self reuseIdentifierFromClass:footerClass]
                                                                         viewClass:footerClass
                                                                configurationBlock:nil];
    [view updateWithModel:model];
    
    return view;
}

- (Class)cellClassForModel:(NSObject *)model
{
    NSString *modelClassName = [self modelClassStringForClass:[model class]];
    
    NSString * cellClassString = [self.cellMappingsDictionary objectForKey:modelClassName];
    
    NSAssert(cellClassString, @"DTTableViewManager does not have cell mapping for model class: %@",[model class]);
    
    return NSClassFromString(cellClassString);
}

-(Class)headerClassForModel:(id)model
{
    NSString *modelClassName = [self modelClassStringForClass:[model class]];
    
    NSString * headerClassString = [self.headerMappingsDictionary objectForKey:modelClassName];
    
    NSAssert(headerClassString, @"DTCellFactory does not have header mapping for model class: %@",[model class]);
    
    return NSClassFromString(headerClassString);
}

-(Class)footerClassForModel:(id)model
{
    NSString *modelClassName = [self modelClassStringForClass:[model class]];
    
    NSString * footerClassString = [self.footerMappingsDictionary objectForKey:modelClassName];
    
    NSAssert(footerClassString, @"DTCellFactory does not have footer mapping for model class: %@",[model class]);
    
    return NSClassFromString(footerClassString);
}

-(NSString *)reuseIdentifierFromClass:(Class)klass
{
    NSString * reuseIdentifier = NSStringFromClass(klass);
    
    if ([klass respondsToSelector:@selector(reuseIdentifier)])
    {
        reuseIdentifier = [klass reuseIdentifier];
    }
    return reuseIdentifier;
}

#pragma mark - helpers

-(NSString *)modelClassStringForClass:(Class)class
{
    NSString * classString = NSStringFromClass(class);
    
    if ([classString isEqualToString:@"__NSCFConstantString"] ||
        [classString isEqualToString:@"__NSCFString"] ||
        class == [NSMutableString class])
    {
        return @"NSString";
    }
    if ([classString isEqualToString:@"__NSCFNumber"] ||
        [classString isEqualToString:@"__NSCFBoolean"])
    {
        return @"NSNumber";
    }
    if ([classString isEqualToString:@"__NSDictionaryI"] ||
        [classString isEqualToString:@"__NSDictionaryM"] ||
        class == [NSMutableDictionary class])
    {
        return @"NSDictionary";
    }
    if ([classString isEqualToString:@"__NSArrayI"] ||
        [classString isEqualToString:@"__NSArrayM"] ||
        class == [NSMutableArray class])
    {
        return @"NSArray";
    }
    if ([classString isEqualToString:@"__NSDate"] || class == [NSDate class])
    {
        return @"NSDate";
    }
    return classString;
}

@end
