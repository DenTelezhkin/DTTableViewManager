//
//  EventCell.m
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 08.12.13.
//  Copyright (c) 2013 Denys Telezhkin. All rights reserved.
//

#import "EventCell.h"
#import "Event.h"

@implementation EventCell

-(void)updateWithModel:(id)model
{
    Event * event = model;
    
    self.textLabel.text = event.timeStamp.description;
}

@end
