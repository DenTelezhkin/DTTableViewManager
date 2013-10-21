//
//  ControllerModel.m
//  DTTableViewController
//
//  Created by Denys Telezhkin on 23.06.13.
//  Copyright (c) 2013 Denys Telezhkin. All rights reserved.
//

#import "ControllerModel.h"

@implementation ControllerModel

+(instancetype)modelWithClass:(Class)controllerClass andTitle:(NSString *)title
{
    ControllerModel * model = [[self alloc] init];
    model.title = title;
    model.controllerClass = controllerClass;
    return model;
}

@end
