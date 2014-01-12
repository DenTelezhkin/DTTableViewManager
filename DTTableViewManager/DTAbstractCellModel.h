//
//  DTAbstractCellModel.h
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 11.01.14.
//  Copyright (c) 2014 Denys Telezhkin. All rights reserved.
//

#import "DTViewConfiguration.h"

@interface DTAbstractCellModel : NSObject

@property (nonatomic, retain) Class cellClass;
@property (nonatomic, retain) NSString * reuseIdentifier;
@property (nonatomic, copy) DTCellConfigurationBlock cellConfigurationBlock;

+(instancetype)modelWithCellClass:(Class)cellClass
                  reuseIdentifier:(NSString *)reuseIdentifier
               configurationBlock:(DTCellConfigurationBlock)configurationBlock;

@end
