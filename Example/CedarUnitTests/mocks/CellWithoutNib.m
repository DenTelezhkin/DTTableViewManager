//
//  CellWithoutNib.m
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 21.05.13.
//  Copyright (c) 2013 Denys Telezhkin. All rights reserved.
//

#import "CellWithoutNib.h"

@implementation CellWithoutNib

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
