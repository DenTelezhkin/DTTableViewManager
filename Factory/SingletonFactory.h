//
//  SingletonFactory.h
//  DonetskAR
//
//  Created by Alexey Belkevich on 4/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SingletonFactory : NSObject

+ (id)sharedInstanceOfClass:(Class)theClass;

@end
