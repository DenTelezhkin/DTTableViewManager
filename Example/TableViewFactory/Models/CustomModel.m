//
//  CustomModel.m
//  TableViewFactory
//
//  Created by Denys Telezhkin on 10/15/12.
//  Copyright (c) 2012 Denys Telezhkin. All rights reserved.
//

#import "CustomModel.h"

@implementation CustomModel

+(CustomModel *)modelWithText1:(NSString *)text1
                         text2:(NSString *)text2
                         text3:(NSString *)text3
                         text4:(NSString *)text4
{
    CustomModel * model = [[CustomModel alloc] init];
    model.text1 = text1;
    model.text2 = text2;
    model.text3 = text3;
    model.text4 = text4;
    return model;
}


@end
