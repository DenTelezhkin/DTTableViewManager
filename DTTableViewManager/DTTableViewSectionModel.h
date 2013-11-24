//
//  DTTableViewSectionModel.h
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 23.11.13.
//  Copyright (c) 2013 Denys Telezhkin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DTTableViewSectionProtocol.h"

@interface DTTableViewSectionModel : NSObject <DTTableViewSectionProtocol>

@property (nonatomic, strong) NSMutableArray * objects;
@property (nonatomic, readonly) NSUInteger numberOfObjects;

@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSString * indexTitle;

@property (nonatomic, strong) id headerModel;
@property (nonatomic, strong) id footerModel;

@end
