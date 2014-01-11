//
//  DTDefaultCellModel.h
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 11.01.14.
//  Copyright (c) 2014 Denys Telezhkin. All rights reserved.
//
#import "DTViewConfiguration.h"

@interface DTDefaultCellModel : NSObject

@property (nonatomic, retain) NSString * reuseIdentifier;

@property (nonatomic, assign) UITableViewCellStyle cellStyle;

@property (nonatomic, copy) DTCellConfigurationBlock cellConfigurationBlock;

+(instancetype)modelWithCellStyle:(UITableViewCellStyle)style
                  reuseIdentifier:(NSString *)reuseIdentifier
               configurationBlock:(DTCellConfigurationBlock)configurationBlock;

@end
