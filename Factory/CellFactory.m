//
//  CellsFactory.m
//  ainifinity
//
//  Created by Alexey Belkevich on 6/20/12.
//  Copyright (c) 2012 MLSDev. All rights reserved.
//

#import "CellFactory.h"
#import "SingletonFactory.h"
#import "BaseTableViewCell.h"


@interface CellFactory ()
- (UITableViewCell *)reuseCellFromTable:(UITableView *)table
                             identifier:(NSString *)identifier
                               andModel:(id)model;
- (UITableViewCell *)cellWithIdentifier:(NSString *)identifier
                                      andModel:(id)model;
- (Class)cellClassWithIdentifier:(NSString *)identifier;

@property (nonatomic,retain) NSDictionary * classMappingDictionary;
@end

@implementation CellFactory
@synthesize classMappingDictionary = _classMappingDictionary;
#pragma mark -
#pragma mark main routine

- (id)init
{
    self = [super init];
    if (self)
    {
        self.classMappingDictionary =
                    @{ // NSStringFromClass([Status class]) : NSStringFromClass([StatusCell class])
                    };
    }
    return self;
}

- (void)dealloc
{
    self.classMappingDictionary = nil;
    [super dealloc];
}

#pragma mark -
#pragma mark singleton protocol implementation

+ (id)sharedInstance
{
    return [SingletonFactory sharedInstanceOfClass:[self class]];
}

#pragma mark -
#pragma mark actions

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
    return [self cellClassWithIdentifier:modelClassName];
}

#pragma mark -
#pragma mark private

- (UITableViewCell *)reuseCellFromTable:(UITableView *)table
                             identifier:(NSString *)identifier
                               andModel:(id)model
{
    BaseTableViewCell * cell =  [table dequeueReusableCellWithIdentifier:identifier];
    [cell updateWithModel:model];
    return cell;
}

- (UITableViewCell *)cellWithIdentifier:(NSString *)identifier andModel:(id)model
{
    Class cellClass = [self cellClassWithIdentifier:identifier];
    return [[(BaseTableViewCell *)[cellClass alloc] initWithStyle:UITableViewCellStyleSubtitle
                                                  reuseIdentifier:identifier
                                                         andModel:model] autorelease];

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
