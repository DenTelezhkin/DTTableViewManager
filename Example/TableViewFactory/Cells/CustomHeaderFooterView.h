//
//  CustomHeaderFooterView.h
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


@interface CustomHeaderFooterView : UITableViewHeaderFooterView
                                    <DTModelTransfer>

@property (strong, nonatomic) IBOutlet UILabel *headerTitleLabel;
@property (strong, nonatomic) IBOutlet UIView *backgroundPatternView;
@end
