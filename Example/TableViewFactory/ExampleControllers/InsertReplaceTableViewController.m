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
    [self addTableItem:[Example exampleWithText:@"Tap me to insert wonderful cell" andDetails:nil]];
}

-(void)addReplaceSection
{
    [self addTableItem:[Example exampleWithText:@"Tap me to replace with wonderful cell"
                                     andDetails:nil]
             toSection:1];
    [self addTableItem:[Example exampleWithText:@"Or me" andDetails:nil] toSection:1];
    [self addTableItem:[Example exampleWithText:@"Or me" andDetails:nil] toSection:1];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addInsertSection];
    [self addReplaceSection];
    [self.sectionHeaderTitles addObjectsFromArray:@[@"Insert rows", @"Replace rows"]];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section)
    {
        //replace
        [self replaceTableItem:[self tableItemAtIndexPath:indexPath]
                 withTableItem:self.wonderfulExample
               andRowAnimation:UITableViewRowAnimationRight];
    }
    else
    {
        //insert
        [self insertTableItem:self.wonderfulExample
                  toIndexPath:indexPath
             withRowAnimation:UITableViewRowAnimationLeft];
    }
}

@end
