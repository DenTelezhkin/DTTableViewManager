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
@dynamic closeDate;
@dynamic zip;

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
    self.closeDate = [self dateFromString:info[@"closeDate"]
                               withFormat:@"dd/MM/yy"];
}

-(NSDate *)dateFromString:(NSString*)stringDate withFormat:(NSString *)format
{
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:format];
    return [dateFormatter dateFromString:stringDate];
}

@end
