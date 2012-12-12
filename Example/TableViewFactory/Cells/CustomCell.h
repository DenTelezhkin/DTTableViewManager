//
//  CustomCell.h
//  TableViewFactory
//
//  Created by Denys Telezhkin on 10/15/12.
//  Copyright (c) 2012 Denys Telezhkin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DTTableViewModelProtocol.h"

@interface CustomCell : UITableViewCell <DTTableViewModelProtocol>

@property (nonatomic,strong) IBOutlet UILabel * label1;
@property (nonatomic,strong) IBOutlet UILabel * label2;
@property (nonatomic,strong) IBOutlet UILabel * label3;
@property (nonatomic,strong) IBOutlet UILabel * label4;



@end
