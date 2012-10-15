//
//  CustomCell.m
//  TableViewFactory
//
//  Created by Denys Telezhkin on 10/15/12.
//  Copyright (c) 2012 Denys Telezhkin. All rights reserved.
//

#import "CustomCell.h"
#import "CustomModel.h"

@interface CustomCell()
@property (nonatomic,retain) CustomModel * model;
@end

@implementation CustomCell

-(void)dealloc
{
    self.model = nil;
    self.label1 = nil;
    self.label2 = nil;
    self.label3 = nil;
    self.label4 = nil;
    [super dealloc];
}

-(void)updateWithModel:(id)model
{
    self.model = model;
    self.label1.text = self.model.text1;
    self.label2.text = self.model.text2;
    self.label3.text = self.model.text3;
    self.label4.text = self.model.text4;
}



@end
