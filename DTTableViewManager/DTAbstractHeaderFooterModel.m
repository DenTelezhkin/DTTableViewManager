//
//  DTAbstractHeaderFooterModel.m
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 12.01.14.
//  Copyright (c) 2014 Denys Telezhkin. All rights reserved.
//

#import "DTAbstractHeaderFooterModel.h"

@implementation DTAbstractHeaderFooterModel

+(instancetype)modelWithHeaderFooterClass:(Class)headerFooterClass
{
    if (![headerFooterClass isSubclassOfClass:[UIView class]])
    {
        NSString *reason = [NSString stringWithFormat:@"class '%@' is not a subclass of UIView",
                            headerFooterClass];
        @throw [NSException exceptionWithName:@"API misuse"
                                       reason:reason userInfo:nil];
    }
    
    DTAbstractHeaderFooterModel * viewModel = [self new];
    
    viewModel.headerFooterClass = headerFooterClass;
    
    return viewModel;
}

+(instancetype)modelWithHeaderFooterClass:(Class)headerFooterClass
                          reuseIdentifier:(NSString *)reuseIdentifier
                       configurationBlock:(DTViewConfigurationBlock)configurationBlock
{
    DTAbstractHeaderFooterModel * model = [self modelWithHeaderFooterClass:headerFooterClass];
    model.reuseIdentifier = reuseIdentifier;
    model.viewConfigurationBlock = configurationBlock;
    return model;
}

@end
