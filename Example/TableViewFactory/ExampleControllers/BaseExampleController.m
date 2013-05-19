//
//  BaseExampleController.m
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 19.05.13.
//  Copyright (c) 2013 Denys Telezhkin. All rights reserved.
//

#import "BaseExampleController.h"

@interface BaseExampleController ()

@end

@implementation BaseExampleController

- (id)init
{
    if (self = [super init])
    {
        [self setClassMappingforCellClass:[ExampleCell class]
                               modelClass:[Example class]];
    }
    return self;
}

@end
