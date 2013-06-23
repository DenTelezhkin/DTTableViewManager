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

-(BOOL)shouldShowInSearchResultsForSearchString:(NSString *)searchString
                                   inScopeIndex:(int)scope
{
    if ([self.text rangeOfString:searchString].location == NSNotFound &&
        [self.details rangeOfString:searchString].location == NSNotFound)
    {
        return NO;
    }
    
    return YES;
}

@end
