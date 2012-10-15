//
//  CustomModel.h
//  TableViewFactory
//
//  Created by Denys Telezhkin on 10/15/12.
//  Copyright (c) 2012 Denys Telezhkin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CustomModel : NSObject

@property (nonatomic,retain) NSString * text1;
@property (nonatomic,retain) NSString * text2;
@property (nonatomic,retain) NSString * text3;
@property (nonatomic,retain) NSString * text4;

+(CustomModel *)modelWithText1:(NSString *)text1
                         text2:(NSString *)text2
                         text3:(NSString *)text3
                         text4:(NSString *)text4;
@end
