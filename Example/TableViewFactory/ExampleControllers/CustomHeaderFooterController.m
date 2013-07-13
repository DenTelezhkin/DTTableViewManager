//
//  CustomHeaderFooterController.m
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 24.03.13.
//  Copyright (c) 2013 Denys Telezhkin. All rights reserved.
//

#import "CustomHeaderFooterController.h"
#import "CustomHeaderFooterView.h"
#import "CustomHeaderFooterModel.h"

@implementation CustomHeaderFooterController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Custom header/footer";
    
    [self registerHeaderClass:[CustomHeaderFooterView class]
                forModelClass:[CustomHeaderFooterModel class]];
    
    [self registerFooterClass:[CustomHeaderFooterView class]
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
