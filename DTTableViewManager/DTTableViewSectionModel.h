//
//  DTTableViewSectionModel.h
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 23.11.13.
//  Copyright (c) 2013 Denys Telezhkin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DTTableViewSection.h"

@interface DTTableViewSectionModel : NSObject <DTTableViewSection>

@property (nonatomic, strong) NSMutableArray * objects;

@property (nonatomic, strong) NSString * headerTitle;
@property (nonatomic, strong) NSString * footerTitle;

@property (nonatomic, strong) NSString * indexTitle;

@property (nonatomic, strong) id headerModel;
@property (nonatomic, strong) id footerModel;

@end
