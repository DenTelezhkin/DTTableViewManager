//
//  Example.h
//  TableViewFactory
//
//  Created by Denys Telezhkin on 10/1/12.
//  Copyright (c) 2012 Denys Telezhkin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Example : NSObject
@property (nonatomic,weak) Class controllerClass;
@property (nonatomic,strong) NSString * text;
@property (nonatomic,strong) NSString * details;

+(Example *)exampleWithText:(NSString *)someText andDetails:(NSString *)details;

+(Example *)exampleWithController:(Class)controllerClass andText:(NSString *)text;
@end
