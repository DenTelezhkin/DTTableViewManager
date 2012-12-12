//
//  CustomModel.h
//  TableViewFactory
//
//  Created by Denys Telezhkin on 10/15/12.
//  Copyright (c) 2012 Denys Telezhkin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CustomModel : NSObject

@property (nonatomic,strong) NSString * text1;
@property (nonatomic,strong) NSString * text2;
@property (nonatomic,strong) NSString * text3;
@property (nonatomic,strong) NSString * text4;

+(CustomModel *)modelWithText1:(NSString *)text1
                         text2:(NSString *)text2
                         text3:(NSString *)text3
                         text4:(NSString *)text4;
@end
