//
//  Bank.h
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 07.12.13.
//  Copyright (c) 2013 Denys Telezhkin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface Bank : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSNumber * zip;
@property (nonatomic, strong) NSString * state;


+(instancetype)insertBankWithInfo:(NSDictionary *)info
           inManagedObjectContext:(NSManagedObjectContext *)context;

@end
