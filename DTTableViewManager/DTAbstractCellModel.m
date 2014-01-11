//
//  DTAbstractCellModel.m
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 11.01.14.
//  Copyright (c) 2014 Denys Telezhkin. All rights reserved.
//

#import "DTAbstractCellModel.h"

@implementation DTAbstractCellModel

+(instancetype)modelWithCellClass:(Class)cellClass
{
    if (![cellClass isSubclassOfClass:[UITableViewCell class]])
    {
        NSString *reason = [NSString stringWithFormat:@"class '%@' is not a subclass of UITableViewCell",
                            cellClass];
        @throw [NSException exceptionWithName:@"API misuse"
                                       reason:reason userInfo:nil];
    }
    
    DTAbstractCellModel * cellModel = [self new];
    
    cellModel.cellClass = cellClass;
    
    return cellModel;
}

+(instancetype)modelWithCellClass:(Class)cellClass configurationBlock:(DTCellConfigurationBlock)configurationBlock
{
    DTAbstractCellModel * model = [self modelWithCellClass:cellClass];
    
    model.cellConfigurationBlock = configurationBlock;
    
    return model;
}

@end
