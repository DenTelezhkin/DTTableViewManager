//
//  TextCell.m
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 23.10.13.
//  Copyright (c) 2013 Denys Telezhkin. All rights reserved.
//

#import "PrototypedCell.h"

@interface PrototypedCell()
@property (strong, nonatomic) IBOutlet UIImageView *cellImage;
@property (strong, nonatomic) IBOutlet UILabel *cellLabel;

@end

@implementation PrototypedCell

-(void)updateWithModel:(id)model
{
    self.cellImage.image = [UIImage imageNamed:@"mochaGrunge.png"];
    self.cellLabel.text = model;
}

@end
