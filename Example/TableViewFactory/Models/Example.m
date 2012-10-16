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
    return [example autorelease];
}

+(Example *)exampleWithController:(Class)controllerClass andText:(NSString *)text
{
    Example * example = [[Example alloc] init];
    example.text = text;
    example.controllerClass = controllerClass;
    return [example autorelease];
}

-(void)dealloc
{
    self.text = nil;
    self.details = nil;
    [super dealloc];
}
@end
