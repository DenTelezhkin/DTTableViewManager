//
//  DTHeaderFooterModel.h
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 12.01.14.
//  Copyright (c) 2014 Denys Telezhkin. All rights reserved.
//

#import "DTViewConfiguration.h"

@interface DTDefaultHeaderFooterModel : NSObject

@property (nonatomic, retain) NSString * reuseIdentifier;

@property (nonatomic, copy) DTViewConfigurationBlock viewConfigurationBlock;

+(instancetype)modelWithReuseIdentifier:(NSString *)reuseIdentifier
                     configurationBlock:(DTViewConfigurationBlock)configurationBlock;

@end
