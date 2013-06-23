//
//  ControllerCell.m
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 23.06.13.
//  Copyright (c) 2013 Denys Telezhkin. All rights reserved.
//

#import "ControllerCell.h"
#import "ControllerModel.h"

@implementation ControllerCell

-(void)updateWithModel:(id)model
{
    self.textLabel.text = [(ControllerModel *)model title];
}

@end
