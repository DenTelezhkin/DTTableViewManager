//
//  BaseMockCell.h
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 21.05.13.
//  Copyright (c) 2013 Denys Telezhkin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DTTableViewCell.h"

@interface BaseMockCell : DTTableViewCell

@property (nonatomic, assign) BOOL awakedFromNib;

@property (nonatomic, assign) BOOL inittedWithStyle;

@end
