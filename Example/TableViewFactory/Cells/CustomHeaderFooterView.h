//
//  CustomHeaderFooterView.h
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 24.03.13.
//  Copyright (c) 2013 Denys Telezhkin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DTTableViewModelTransfer.h"

@interface CustomHeaderFooterView : UITableViewHeaderFooterView
                                    <DTTableViewModelTransfer>

@property (strong, nonatomic) IBOutlet UILabel *headerTitleLabel;
@property (strong, nonatomic) IBOutlet UIView *backgroundPatternView;
@end
