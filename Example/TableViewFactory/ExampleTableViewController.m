//
//  ViewController.m
//  TableViewFactory
//
//  Created by Denys Telezhkin on 9/28/12.
//  Copyright (c) 2012 Denys Telezhkin. All rights reserved.
//

#import "ExampleTableViewController.h"
#import "Example.h"

@interface ExampleTableViewController ()

@end

@implementation ExampleTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self addTableItem:[Example exampleWithText:@"Hello" andDetails:@"World"]];
    [self setSectionHeaders:@[@"A", @"B", @"C", @"D", @"E"]];
    

    [self.table reloadData];
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
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Example * selectedExample = [self tableItemAtIndexPath:indexPath];
    
    [self removeTableItem:selectedExample withRowAnimation:UITableViewRowAnimationAutomatic];
}

@end
