//
//  SingletonProtocol.h
//  DonetskAR
//
//  Created by Denys Telezhkin on 4/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SingletonProtocol <NSObject>

+ (id)sharedInstance;

@end
