//
//  Bank.m
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 07.12.13.
//  Copyright (c) 2013 Denys Telezhkin. All rights reserved.
//

#import "Bank.h"

@implementation Bank

@dynamic name;
@dynamic city;
@dynamic zip;
@dynamic state;

+(instancetype)insertBankWithInfo:(NSDictionary *)info
           inManagedObjectContext:(NSManagedObjectContext *)context
{
    Bank * newBank = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([self class])
                                                   inManagedObjectContext:context];
    [newBank fillBankWithInfo:info];
    return newBank;
}

-(void)fillBankWithInfo:(NSDictionary *)info
{
    self.name = info[@"name"];
    self.city = info[@"city"];
    self.zip = info[@"zip"];
    self.state = info[@"state"];
}

@end
