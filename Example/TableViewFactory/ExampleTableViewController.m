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


@end
