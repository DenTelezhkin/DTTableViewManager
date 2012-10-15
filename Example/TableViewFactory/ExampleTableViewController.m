//
//  ViewController.m
//  TableViewFactory
//
//  Created by Denys Telezhkin on 9/28/12.
//  Copyright (c) 2012 Denys Telezhkin. All rights reserved.
//

#import "ExampleTableViewController.h"
#import "Example.h"
#import "ExampleCell.h"
#import "CustomCell.h"
#import "CustomModel.h"

@interface ExampleTableViewController ()

@end

@implementation ExampleTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment this line if you want to NOT reuse cells.
    // self.doNotReuseCells = YES;
    
    // CustomCell is created from NIB
    // IMPORTANT to register cell nib for reuse identifier IDENTICAL to your model class name
    [self.tableView registerNib:[UINib nibWithNibName:@"CustomCell" bundle:nil]
         forCellReuseIdentifier:@"CustomModel"];
    
    [self addCellClassMapping:[ExampleCell class] forModelClass:[Example class]];
    [self addCellClassMapping:[CustomCell class] forModelClass:[CustomModel class]];
    
    [self insertTableItem:[Example exampleWithText:@"Hello" andDetails:@"World"]
              toIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    [self setSectionHeaders:@[@"A", @"B", @"C", @"D", @"E"]];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self addTableItem:[Example exampleWithText:@"Hello section 1!" andDetails:@"Woohoo!"]
                 toSection:1
          withRowAnimation:UITableViewRowAnimationAutomatic];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self insertTableItem:[Example exampleWithText:@"Hello section 3!" andDetails:@"Woohoo!"]
                  toIndexPath:[NSIndexPath indexPathForRow:0 inSection:4]
             withRowAnimation:UITableViewRowAnimationAutomatic];
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self deleteSections:[NSIndexSet indexSetWithIndex:3]
            withRowAnimation:UITableViewRowAnimationAutomatic];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self addTableItem:[Example exampleWithText:@"Reloaded row from section 2" andDetails:@""]
                 toSection:2];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self reloadSections:[NSIndexSet indexSetWithIndex:2]
            withRowAnimation:UITableViewRowAnimationAutomatic];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self moveSection:1 toSection:3];
    });
 
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self addTableItem:[Example exampleWithText:@"Add item and reload section" andDetails:@""]
                 toSection:4];
        [self reloadSections:[NSIndexSet indexSetWithIndex:4]
            withRowAnimation:UITableViewRowAnimationAutomatic];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 4 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self addTableItem:[CustomModel modelWithText1:@"Very"
                                                 text2:@"Customized"
                                                 text3:@"Table"
                                                 text4:@"Cell"]
                 toSection:4];
    });
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id model = [self tableItemAtIndexPath:indexPath];
    if ([model isKindOfClass:[Example class]])
    {
        Example * selectedExample = model;
        
        [self removeTableItem:selectedExample withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

@end
