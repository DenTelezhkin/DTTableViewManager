//
//  GameDataStore.m
//  VirusWar
//
//  Created by Belkevich Alexey on 10/28/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AppDataStore.h"

@implementation AppDataStore

#pragma mark -
#pragma mark main routine

- (id)init
{
    self = [super init];
    if (self)
    {
        store = [NSMutableDictionary new];
    }
    return self;
}

- (void)dealloc
{
    [store release];
    [super dealloc];
}

#pragma mark -
#pragma mark push/pop values

- (void)pushObject:(id)object forKey:(NSString *)key
{
    [self setObject:object forKey:key];
}

- (id)popObjectForKey:(NSString *)key
{
    NSObject *object = (NSObject *)[self objectForKey:key];
    [object retain];
    [store removeObjectForKey:key];
    return [object autorelease];
}

#pragma mark -
#pragma mark key-object support

- (id)objectForKey:(NSString *)key
{
    return [store objectForKey:key];
}
  
- (void)setObject:(id)object forKey:(NSString *)key
{
    [store setObject:object forKey:key];
}

@end
