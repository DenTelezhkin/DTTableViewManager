//
//  CustomHeaderView.h
//  DTTableViewController
//
//  Created by Denys Telezhkin on 24.03.13.
//  Copyright (c) 2013 Denys Telezhkin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DTModelTransfer.h"

typedef enum {
    kHeaderKind = 1,
    kFooterKind = 2
} kHeaderFooterViewKind;

@interface CustomHeaderView : UIView <DTModelTransfer>

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;

@end
