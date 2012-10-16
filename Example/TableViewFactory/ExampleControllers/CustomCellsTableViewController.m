//
//  CustomCellsTableViewController.m
//  TableViewFactory
//
//  Created by Denys Telezhkin on 10/16/12.
//  Copyright (c) 2012 Denys Telezhkin. All rights reserved.
//

#import "CustomCellsTableViewController.h"
#import "CustomCell.h"
#import "CustomModel.h"

@implementation CustomCellsTableViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        [self addCellClassMapping:[CustomCell class] forModelClass:[CustomModel class]];
        
        self.title = @"Custom NIB";
               
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // CustomCell is created from NIB
    // IMPORTANT to register cell nib for reuse identifier IDENTICAL to your model class name
    [self.tableView registerNib:[UINib nibWithNibName:@"CustomCell" bundle:nil]
         forCellReuseIdentifier:@"CustomModel"];
    
    
    [self addTableItem:[CustomModel modelWithText1:@"Very"
                                             text2:@"Customized"
                                             text3:@"Table"
                                             text4:@"Cell"]];
}

@end
