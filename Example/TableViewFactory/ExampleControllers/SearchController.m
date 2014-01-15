//
//  SearchController.m
//  DTTableViewController
//
//  Created by Denys Telezhkin on 22.06.13.
//  Copyright (c) 2013 Denys Telezhkin. All rights reserved.
//

#import "SearchController.h"
#import "Example.h"
#import "DTDefaultCellModel.h"

@implementation SearchController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[self navigationController] navigationBar].translucent = NO;
    
    NSString * path = [[NSBundle mainBundle] pathForResource:@"Capitals" ofType:@"plist"];
    NSArray * continents = [NSArray arrayWithContentsOfFile:path];
    NSMutableArray * headerTitles = [NSMutableArray array];
    for (int section=0;section <[continents count]; section ++)
    {
        NSDictionary * continent = continents[section];
        NSDictionary * capitals = [[continents[section] allValues] lastObject];
        for (NSString * country in [capitals allKeys])
        {
            DTDefaultCellModel * model = [self cellModelForCapital:capitals[country]
                                                         inCountry:country];
            [[self memoryStorage] addItem:model
                                toSection:section];
        }
        
        [headerTitles addObject:[[continent allKeys] lastObject]];
    }
    [[self memoryStorage] setSectionHeaderModels:headerTitles];
}

-(DTDefaultCellModel *)cellModelForCapital:(NSString *)capital inCountry:(NSString *)country
{
    return [DTDefaultCellModel modelWithCellStyle:UITableViewCellStyleSubtitle
                                  reuseIdentifier:@"CountryCell"
                               configurationBlock:^(UITableViewCell *cell) {
                                                    cell.textLabel.text = capital;
                                                    cell.detailTextLabel.text = country;
                                                }
                                   searchingBlock:^BOOL(NSString *searchString, NSInteger searchScope) {
                                                       if ([capital rangeOfString:searchString].location == NSNotFound &&
                                                           [country rangeOfString:searchString].location == NSNotFound)
                                                       {
                                                           return NO;
                                                       }
                                                       return YES;
                                                   }];
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


@end
