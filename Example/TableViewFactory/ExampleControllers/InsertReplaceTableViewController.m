//
//  InsertReplaceTableViewController.m
//  TableViewFactory
//
//  Created by Denys Telezhkin on 10/16/12.
//  Copyright (c) 2012 Denys Telezhkin. All rights reserved.
//

#import "InsertReplaceTableViewController.h"
#import "Example.h"

@interface InsertReplaceTableViewController ()
@property (nonatomic,strong) Example * wonderfulExample;
@end

@implementation InsertReplaceTableViewController

-(Example *)wonderfulExample
{
    if (!_wonderfulExample)
        _wonderfulExample = [Example exampleWithText:@"Wonderful" andDetails:@"cell"];
    return _wonderfulExample;
}

-(void)addInsertSection
{
    [[self memoryStorage] addItem:[Example exampleWithText:@"Tap me to insert wonderful cell" andDetails:nil]];
}

-(void)addReplaceSection
{
    DTTableViewMemoryStorage * storage = [self memoryStorage];
    [storage addItem:[Example exampleWithText:@"Tap me to replace with wonderful cell"
                                     andDetails:nil]
             toSection:1];
    [storage addItem:[Example exampleWithText:@"Or me" andDetails:nil] toSection:1];
    [storage addItem:[Example exampleWithText:@"Or me" andDetails:nil] toSection:1];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self addInsertSection];
    [self addReplaceSection];
    DTTableViewMemoryStorage * storage =[self memoryStorage];
    [storage setSectionHeaderModels:@[@"Insert rows", @"Replace rows"]];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DTTableViewMemoryStorage * storage = [self memoryStorage];
    if (indexPath.section)
    {
        //replace
        [storage replaceItem:[storage itemAtIndexPath:indexPath]
                 withItem:self.wonderfulExample];
    }
    else
    {
        //insert
        [storage insertItem:self.wonderfulExample
                  toIndexPath:indexPath];
    }
}

@end
