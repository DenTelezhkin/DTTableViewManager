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
    example.someText = someText;
    example.details = details;
    return [example autorelease];
}
@end
