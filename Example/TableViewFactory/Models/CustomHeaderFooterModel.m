//
//  CustomHeaderFooterModel.m
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 24.03.13.
//  Copyright (c) 2013 Denys Telezhkin. All rights reserved.
//

#import "CustomHeaderFooterModel.h"

@implementation CustomHeaderFooterModel

+(CustomHeaderFooterModel *)headerModel
{
    CustomHeaderFooterModel * model = [[self alloc] init];
    model.viewKind = kHeaderKind;
    return model;
}

+(CustomHeaderFooterModel *)footerModel
{
    CustomHeaderFooterModel * model = [[self alloc] init];
    model.viewKind = kFooterKind;
    return model;
}

@end
