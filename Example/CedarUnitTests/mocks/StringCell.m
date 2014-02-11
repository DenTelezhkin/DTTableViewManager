//
//  StringCell.m
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 11.02.14.
//  Copyright (c) 2014 Denys Telezhkin. All rights reserved.
//

#import "StringCell.h"
@interface StringCell()
@property (nonatomic, retain) NSString * string;
@end

@implementation StringCell

-(void)updateWithModel:(id)model
{
    self.textLabel.text = model;
    self.string = model;
}

-(id)model
{
    return self.string;
}

@end
