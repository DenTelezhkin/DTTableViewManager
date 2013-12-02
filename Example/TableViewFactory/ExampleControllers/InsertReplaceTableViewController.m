//
//  InsertReplaceTableViewController.m
//  TableViewFactory
//
//  Created by Denys Telezhkin on 10/16/12.
//  Copyright (c) 2012 Denys Telezhkin. All rights reserved.
//

#import "InsertReplaceTableViewController.h"

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
    DTTableViewMemoryStorage * storage = self.dataStorage;
    [storage addTableItem:[Example exampleWithText:@"Tap me to insert wonderful cell" andDetails:nil]];
}

-(void)addReplaceSection
{
    DTTableViewMemoryStorage * storage = self.dataStorage;
    [storage addTableItem:[Example exampleWithText:@"Tap me to replace with wonderful cell"
                                     andDetails:nil]
             toSection:1];
    [storage addTableItem:[Example exampleWithText:@"Or me" andDetails:nil] toSection:1];
    [storage addTableItem:[Example exampleWithText:@"Or me" andDetails:nil] toSection:1];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.dataStorage = [DTTableViewMemoryStorage storageWithDelegate:self];
    [self addInsertSection];
    [self addReplaceSection];
    DTTableViewMemoryStorage * storage = self.dataStorage;
    [storage setSectionHeaderModels:@[@"Insert rows", @"Replace rows"]];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DTTableViewMemoryStorage * storage = self.dataStorage;
    if (indexPath.section)
    {
        //replace
        [storage replaceTableItem:[storage tableItemAtIndexPath:indexPath]
                 withTableItem:self.wonderfulExample];
    }
    else
    {
        //insert
        [storage insertTableItem:self.wonderfulExample
                  toIndexPath:indexPath];
    }
}

@end
