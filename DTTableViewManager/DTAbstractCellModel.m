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
                  reuseIdentifier:(NSString *)reuseIdentifier
               configurationBlock:(DTCellConfigurationBlock)configurationBlock
{
    if (![cellClass isSubclassOfClass:[UITableViewCell class]])
    {
        NSString *reason = [NSString stringWithFormat:@"class '%@' is not a subclass of UITableViewCell",
                            cellClass];
        @throw [NSException exceptionWithName:@"API misuse"
                                       reason:reason userInfo:nil];
    }
    
    DTAbstractCellModel * model = [self new];
    model.cellClass = cellClass;
    model.reuseIdentifier = reuseIdentifier;
    model.cellConfigurationBlock = configurationBlock;
    
    return model;
}

@end
