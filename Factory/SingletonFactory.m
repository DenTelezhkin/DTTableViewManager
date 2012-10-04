//
//  SingletonFactory.m
//  DonetskAR
//
//  Created by Denys Telezhkin on 4/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SingletonFactory.h"
#import "SingletonProtocol.h"
#import "AppDelegate.h"
#import "AppDataStore.h"

@implementation SingletonFactory

+ (id)sharedInstanceOfClass:(Class)theClass
{
    if ([theClass conformsToProtocol:@protocol(SingletonProtocol)])
    {
        AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        AppDataStore *dataStore = delegate.dataStore;
        NSString *className = NSStringFromClass(theClass);
        id instance = [dataStore objectForKey:className];
        if (!instance)
        {
            instance = [theClass new];
            [dataStore setObject:instance forKey:className];
            [instance autorelease];
        }
        return instance;
    }
    return nil;
}

@end
