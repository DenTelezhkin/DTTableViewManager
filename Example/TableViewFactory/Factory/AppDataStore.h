//
//  GameDataStore.h
//  VirusWar
//
//  Created by Belkevich Alexey on 10/28/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppDataStore : NSObject
{
    NSMutableDictionary *store;
}

// push/pop values
- (void)pushObject:(id)object forKey:(NSString *)key;
- (id)popObjectForKey:(NSString *)key;
// key-object support
- (id)objectForKey:(NSString *)key;
- (void)setObject:(id)object forKey:(NSString *)key;

@end
