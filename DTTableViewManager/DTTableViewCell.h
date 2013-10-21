//
//  DTTableViewCell.h
//  DTTableViewController
//
//  Created by Denys Telezhkin on 21.05.13.
//  Copyright (c) 2013 Denys Telezhkin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DTTableViewModelTransfer.h"

/**
 `DTTableViewCell` is a convinience UITableViewCell subclass, conforming to `DTTableViewModelTransfer` protocol.
 */


@interface DTTableViewCell : UITableViewCell <DTTableViewModelTransfer>

@end
