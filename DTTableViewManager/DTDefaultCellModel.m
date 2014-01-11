//
//  DTDefaultCellModel.m
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 11.01.14.
//  Copyright (c) 2014 Denys Telezhkin. All rights reserved.
//

#import "DTDefaultCellModel.h"

@implementation DTDefaultCellModel

+(instancetype)modelWithCellStyle:(UITableViewCellStyle)style
                  reuseIdentifier:(NSString *)reuseIdentifier
               configurationBlock:(DTCellConfigurationBlock)configurationBlock
{
    DTDefaultCellModel * model = [self new];
    model.cellStyle = style;
    model.reuseIdentifier = reuseIdentifier;
    model.cellConfigurationBlock = configurationBlock;
    return model;
}
@end
