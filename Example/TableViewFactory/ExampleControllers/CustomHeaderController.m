//
//  CustomHeaderController.m
//  DTTableViewController
//
//  Created by Denys Telezhkin on 24.03.13.
//  Copyright (c) 2013 Denys Telezhkin. All rights reserved.
//

#import "CustomHeaderController.h"
#import "CustomHeaderView.h"

@implementation CustomHeaderController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Custom header/footer";
    
    [self registerHeaderClass:[CustomHeaderView class]
                forModelClass:[NSNumber class]];
    [self registerFooterClass:[CustomHeaderView class]
                forModelClass:[NSNumber class]];
    
    [self addTableItem:[Example exampleWithText:@"Section 1" andDetails:nil]];
    [self addTableItem:[Example exampleWithText:@"Section 2" andDetails:nil]
             toSection:1];
    
    [self.sectionHeaderModels addObjectsFromArray:@[@(kHeaderKind),@(kHeaderKind)]];
    [self.sectionFooterModels addObjectsFromArray:@[@(kFooterKind),@(kFooterKind)]];
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
