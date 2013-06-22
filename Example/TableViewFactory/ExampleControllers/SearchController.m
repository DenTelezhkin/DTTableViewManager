//
//  SearchController.m
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 22.06.13.
//  Copyright (c) 2013 Denys Telezhkin. All rights reserved.
//

#import "SearchController.h"

@implementation SearchController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self addTableItems:@[
            [Example exampleWithText:@"Kyiv" andDetails:@"Ukraine"],
            [Example exampleWithText:@"London" andDetails:@"England"],
            [Example exampleWithText:@"Lissabon" andDetails:@"Portugal"]
     ]
              toSection:0];
    
    [self addTableItems:@[
            [Example exampleWithText:@"Bangkok" andDetails:@"Thailand"],
            [Example exampleWithText:@"Oman" andDetails:@"Maskat"],
            [Example exampleWithText:@"Beihrut" andDetails:@"Lebanon"]
     ] toSection:1];
    
    [self addTableItems:@[
            [Example exampleWithText:@"Suva" andDetails:@"Fiji"],
            [Example exampleWithText:@"Kanberra" andDetails:@"Australia"]
     ] toSection:2];
    
    [self addTableItems:@[
            [Example exampleWithText:@"Washington D.C." andDetails:@"USA"],
            [Example exampleWithText:@"Mexico city" andDetails:@"Mexico"]
    ] toSection:3];
    
    [self addTableItems:@[
            [Example exampleWithText:@"Santiago" andDetails:@"Chile"],
            [Example exampleWithText:@"Lima" andDetails:@"Peru"],
            [Example exampleWithText:@"Bogota" andDetails:@"Columbia"]
     ] toSection:4];
    
    [self addTableItems:@[
            [Example exampleWithText:@"Bamako" andDetails:@"Mali"],
            [Example exampleWithText:@"Akkra" andDetails:@"Gana"],
            [Example exampleWithText:@"Lome" andDetails:@"Togo"]
     ] toSection:5];
    
    [self.sectionHeaderTitles addObjectsFromArray:@[
        @"Europe",
        @"Asia",
        @"Australia",
        @"Northern America",
        @"Southern America",
        @"Africa"
     ]];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.searchBar resignFirstResponder];
}


@end
