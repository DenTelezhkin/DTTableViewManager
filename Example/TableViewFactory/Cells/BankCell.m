//
//  BankCell.m
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 08.12.13.
//  Copyright (c) 2013 Denys Telezhkin. All rights reserved.
//

#import "BankCell.h"
#import "Bank.h"

@implementation BankCell

-(void)updateWithModel:(id)model
{
    Bank * bank = model;
    self.textLabel.text = bank.name;
    self.detailTextLabel.text = bank.city;
}

@end
