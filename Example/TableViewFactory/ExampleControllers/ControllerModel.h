//
//  ControllerModel.h
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 23.06.13.
//  Copyright (c) 2013 Denys Telezhkin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ControllerModel : NSObject

@property (nonatomic, weak) Class controllerClass;
@property (nonatomic, retain) NSString * title;

+(instancetype)modelWithClass:(Class)controllerClass andTitle:(NSString *)title;

@end
