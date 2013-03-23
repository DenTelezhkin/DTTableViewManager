//
//  UIView+Laoding.m
//  WorldlifeNMP
//
//  Created by Evgeniy Kirpichenko on 7/13/12.
//  Copyright (c) 2012 MLS. All rights reserved.
//

#import "UIView+Loading.h"

@implementation UIView (Loading)

+ (id) loadFromXibNamed:(NSString *) xibName {
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:xibName 
                                                             owner:nil 
                                                           options:nil];
    for(id currentObject in topLevelObjects) {
        if([currentObject isKindOfClass:self]) {
            return currentObject;
        }           
    }
    return nil;
}

+ (id) loadFromXib {
    return [self loadFromXibNamed:NSStringFromClass(self)];
}

@end