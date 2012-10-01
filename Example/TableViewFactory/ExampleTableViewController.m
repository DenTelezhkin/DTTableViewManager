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
  
    [self.table reloadData];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self addTableItem:[Example exampleWithText:@"Hello section 2!" andDetails:@"Woohoo!"]
             toSection:1
         withAnimation:UITableViewRowAnimationAutomatic];
    
    [self setSectionHeaders:@[@"A", @"B",@"C",@"D",@"E"]];
    [self.table reloadData];
    
    [self insertTableItem:[Example exampleWithText:@"Hello section 4!" andDetails:@"Woohoo!"]
              toIndexPath:[NSIndexPath indexPathForRow:0 inSection:4]
     withAnimation:UITableViewRowAnimationAutomatic];
    
}

@end
