//
//  DTDefaultCellModel.h
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 11.01.14.
//  Copyright (c) 2014 Denys Telezhkin. All rights reserved.
//

#import "DTViewConfiguration.h"

/**
 `DTDefaultCellModel` is a custom model class, that allows to use UITableViewCells without subclassing.
 */
@interface DTDefaultCellModel : NSObject

/**
 Reuse identifier for cell, that will be used for current cell model.
 */
@property (nonatomic, retain) NSString * reuseIdentifier;

/**
 Cell style for cell, that will be created for current cell model
 */
@property (nonatomic, assign) UITableViewCellStyle cellStyle;

/**
 Configuration block, that will be executed on UITableViewCell after it will be created/reused.
 */
@property (nonatomic, copy) DTCellConfigurationBlock cellConfigurationBlock;

/**
 Convenience method, allowing to create `DTDefaultCellModel` instance.
 
 @param style UITableViewCellStyle to use for cell
 
 @param reuseIdentifier reuse identifier to use for cell
 
 @param configurationBlock block to execute when cell is created
 
 @return `DTDefaultCellModel` instance.
 */
+(instancetype)modelWithCellStyle:(UITableViewCellStyle)style
                  reuseIdentifier:(NSString *)reuseIdentifier
               configurationBlock:(DTCellConfigurationBlock)configurationBlock;

@end
