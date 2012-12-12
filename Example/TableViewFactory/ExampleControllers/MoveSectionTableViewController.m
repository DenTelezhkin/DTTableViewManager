//
//  MoveSectionTableViewController.m
//  TableViewFactory
//
//  Created by Denys Telezhkin on 10/16/12.
//  Copyright (c) 2012 Denys Telezhkin. All rights reserved.
//

#import "MoveSectionTableViewController.h"

@interface MoveSectionTableViewController ()

@end

@implementation MoveSectionTableViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        self.title = @"Move section";
    }
    return self;
}

-(void)moveSection
{
    int numberofSections = [self numberOfSections];
    [self moveSection:0 toSection:numberofSections -1];
}

-(void)addExampleRows
{
    [self addTableItem:[Example exampleWithText:@"Section 1 cell"
                                     andDetails:@""]
             toSection:0];
    [self addTableItem:[Example exampleWithText:@"Section 1 cell"
                                     andDetails:@""]
             toSection:0];
    [self addTableItem:[Example exampleWithText:@"Section 2 cell"
                                     andDetails:@""]
             toSection:1];
    [self addTableItem:[Example exampleWithText:@"Section 3 cell"
                                     andDetails:@""]
             toSection:2];
    [self addTableItem:[Example exampleWithText:@"Section 3 cell"
                                     andDetails:@""]
             toSection:2];
    [self addTableItem:[Example exampleWithText:@"Section 3 cell"
                                     andDetails:@""]
             toSection:2];
    [self setSectionHeaders:@[@"Section 1", @"Section 2", @" Section 3"]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIBarButtonItem * moveButton = [[UIBarButtonItem alloc] initWithTitle:@"Move!"
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(moveSection)];
    self.navigationItem.rightBarButtonItem = moveButton;
    
    [self addExampleRows];
}

@end
