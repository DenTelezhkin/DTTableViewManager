//
//  DTHeaderFooterModel.m
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 12.01.14.
//  Copyright (c) 2014 Denys Telezhkin. All rights reserved.
//

#import "DTDefaultHeaderFooterModel.h"

@implementation DTDefaultHeaderFooterModel

+(instancetype)modelWithReuseIdentifier:(NSString *)reuseIdentifier
                     configurationBlock:(DTViewConfigurationBlock)configurationBlock
{
    DTDefaultHeaderFooterModel * model = [self new];
    model.reuseIdentifier = reuseIdentifier;
    model.viewConfigurationBlock = configurationBlock;
    return model;
}

@end
