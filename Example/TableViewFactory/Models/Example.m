//
//  Example.m
//  TableViewFactory
//
//  Created by Denys Telezhkin on 10/1/12.
//  Copyright (c) 2012 Denys Telezhkin. All rights reserved.
//

#import "Example.h"

@implementation Example

+(Example *)exampleWithText:(NSString *)someText andDetails:(NSString *)details
{
    Example * example = [[Example alloc] init];
    example.text = someText;
    example.details = details;
    return example;
}

+(DTModelSearchingBlock)exampleSearchingBlock
{
    DTModelSearchingBlock block = ^BOOL(id model,NSString * searchString, NSInteger searchScope, DTSectionModel * section)
    {
        Example * example  = model;
        if ([example.text rangeOfString:searchString].location == NSNotFound &&
            [example.details rangeOfString:searchString].location == NSNotFound)
        {
            return NO;
        }
        return YES;
    };
    
    return [block copy];
}

@end
