//
//  DTHeaderFooterModel.h
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 12.01.14.
//  Copyright (c) 2014 Denys Telezhkin. All rights reserved.
//

#import "DTViewConfiguration.h"

/**
 `DTDefaultHeaderFooterModel` is a custom model class, that allows to use UITableViewHeaderFooterView without subclassing.
 */
@interface DTDefaultHeaderFooterModel : NSObject

/**
 Reuse identifier for header footer view, that will be used for current model.
 */
@property (nonatomic, retain) NSString * reuseIdentifier;

/**
 Configuration block, that will be executed on UITableViewHeaderFooterView after it will be created/reused.
 */
@property (nonatomic, copy) DTViewConfigurationBlock viewConfigurationBlock;

/**
 Convenience method, allowing to create `DTDefaultHeaderFooterModel` instance.
 
 @param reuseIdentifier reuse identifier to use for header footer view
 
 @param configurationBlock block to execute when header footer view is created
 
 @return `DTDefaultHeaderFooterModel` instance.
 */
+(instancetype)modelWithReuseIdentifier:(NSString *)reuseIdentifier
                     configurationBlock:(DTViewConfigurationBlock)configurationBlock;

@end
