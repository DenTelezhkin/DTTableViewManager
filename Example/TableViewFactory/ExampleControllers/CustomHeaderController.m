//
//  CustomHeaderController.m
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 24.03.13.
//  Copyright (c) 2013 Denys Telezhkin. All rights reserved.
//

#import "CustomHeaderController.h"
#import "CustomHeaderFooterModel.h"
#import "CustomHeaderView.h"

@implementation CustomHeaderController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Custom header/footer";
    
    [self registerHeaderClass:[CustomHeaderView class]
                forModelClass:[CustomHeaderFooterModel class]];
    [self registerFooterClass:[CustomHeaderView class]
                forModelClass:[CustomHeaderFooterModel class]];
    
    [self addTableItem:[Example exampleWithText:@"Section 1" andDetails:nil]];
    [self addTableItem:[Example exampleWithText:@"Section 2" andDetails:nil]
             toSection:1];
    
    [self.sectionHeaderModels addObjectsFromArray:
        @[
            [CustomHeaderFooterModel headerModel],
            [CustomHeaderFooterModel headerModel]
        ]
     ];
    [self.sectionFooterModels addObjectsFromArray:
        @[
            [CustomHeaderFooterModel footerModel],
            [CustomHeaderFooterModel footerModel]
        ]
     ];
    
    [self.tableView reloadData];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 50;
}

@end
