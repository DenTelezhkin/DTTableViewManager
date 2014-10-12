//
//  SearchController.m
//  DTTableViewController
//
//  Created by Denys Telezhkin on 22.06.13.
//  Copyright (c) 2013 Denys Telezhkin. All rights reserved.
//

#import "SearchController.h"
#import "Example.h"
#import "ExampleCell.h"

@implementation SearchController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[self navigationController] navigationBar].translucent = NO;
    
    [self registerCellClass:[ExampleCell class] forModelClass:[Example class]];
    
    NSString * path = [[NSBundle mainBundle] pathForResource:@"Capitals" ofType:@"plist"];
    NSArray * continents = [NSArray arrayWithContentsOfFile:path];
    NSMutableArray * headerTitles = [NSMutableArray array];
    for (NSUInteger section=0;section <[continents count]; section ++)
    {
        NSDictionary * continent = continents[section];
        NSDictionary * capitals = [[continents[section] allValues] lastObject];
        for (NSString * country in [capitals allKeys])
        {
            Example * example = [Example exampleWithText:capitals[country]
                                              andDetails:country];
            [[self memoryStorage] addItem:example
                                toSection:section];
        }
        
        [headerTitles addObject:[[continent allKeys] lastObject]];
    }
    [[self memoryStorage] setSectionHeaderModels:headerTitles];
    
    /*
     We use country, capital and the continent name as the search criteria here.
     */
    [self.memoryStorage setSearchingBlock:^BOOL(id model, NSString *searchString, NSInteger searchScope, DTSectionModel *section) {
        Example * example  = model;
        if ([example.text rangeOfString:searchString].location == NSNotFound &&
            [example.details rangeOfString:searchString].location == NSNotFound &&
            [(NSString *)section.tableHeaderModel rangeOfString:searchString].location == NSNotFound)
        {
            return NO;
        }
        return YES;
    } forModelClass:[Example class]];
}

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [self.searchBar setShowsCancelButton:YES animated:YES];
}

-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    [self.searchBar setShowsCancelButton:NO animated:YES];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self.searchBar resignFirstResponder];
}

-(void)tableControllerDidEndSearch
{
    if ([self.tableView numberOfSections] == 0)
    {
        self.tableView.hidden = YES;
    }
    else {
        self.tableView.hidden = NO;
    }
}

-(void)tableControllerDidCancelSearch
{
    self.tableView.hidden = NO;
}


@end
