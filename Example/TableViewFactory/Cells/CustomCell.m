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
@property (nonatomic,strong) CustomModel * model;
@end

@implementation CustomCell


-(void)updateWithModel:(id)model
{
    self.model = model;
    self.label1.text = self.model.text1;
    self.label2.text = self.model.text2;
    self.label3.text = self.model.text3;
    self.label4.text = self.model.text4;
}



@end
