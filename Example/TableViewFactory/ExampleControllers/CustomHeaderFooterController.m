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

@interface CustomHeaderFooterController ()

@end

@implementation CustomHeaderFooterController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Custom header/footer";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setHeaderMappingForNibName:NSStringFromClass([CustomHeaderFooterView class])
                         headerClass:[CustomHeaderFooterView class]
                          modelClass:[CustomHeaderFooterModel class]];
    [self setFooterMappingForNibName:NSStringFromClass([CustomHeaderFooterView class])
                         footerClass:[CustomHeaderFooterView class]
                          modelClass:[CustomHeaderFooterModel class]];
    
    [self addTableItem:[Example exampleWithText:@"Section 1" andDetails:nil]];
    [self addTableItem:[Example exampleWithText:@"Section 2" andDetails:nil]
             toSection:1];
    [self setSectionHeaderModels:@[[CustomHeaderFooterModel headerModel],
                                   [CustomHeaderFooterModel headerModel]]];
    [self setSectionFooterModels:@[[CustomHeaderFooterModel footerModel],
                                   [CustomHeaderFooterModel footerModel]]];
    
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
