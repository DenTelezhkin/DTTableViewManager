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

+(Example *)exampleWithController:(Class)controllerClass andText:(NSString *)text
{
    Example * example = [[Example alloc] init];
    example.text = text;
    example.controllerClass = controllerClass;
    return example;
}

-(BOOL)shouldShowInSearchResultsForSearchString:(NSString *)searchString
                                   inScopeIndex:(int)scope
{
    
}

@end
