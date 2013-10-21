//
//  BaseMockCell.m
//  DTTableViewController
//
//  Created by Denys Telezhkin on 21.05.13.
//  Copyright (c) 2013 Denys Telezhkin. All rights reserved.
//

#import "BaseMockCell.h"

@implementation BaseMockCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.inittedWithStyle = YES;
    }
    return self;
}

-(void)awakeFromNib
{
    [super awakeFromNib];
    
    self.awakedFromNib = YES;
}

-(void)updateWithModel:(id)model
{
    
}

@end
