//
//  CustomHeaderFooterController.m
//  DTTableViewController
//
//  Created by Denys Telezhkin on 24.03.13.
//  Copyright (c) 2013 Denys Telezhkin. All rights reserved.
//

#import "CustomHeaderFooterController.h"
#import "CustomHeaderFooterView.h"
#import "Example.h"

@implementation CustomHeaderFooterController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Custom header/footer";
    
    [self registerHeaderClass:[CustomHeaderFooterView class]
                forModelClass:[NSNumber class]];
    
    [self registerFooterClass:[CustomHeaderFooterView class]
                forModelClass:[NSNumber class]];
    
    DTTableViewMemoryStorage * storage = [self memoryStorage];
    
    [storage setSectionHeaderModels:@[@(kHeaderKind),@(kHeaderKind)]];
    [storage setSectionFooterModels:@[@(kFooterKind),@(kFooterKind)]];
    self.sectionHeaderStyle = DTTableViewSectionStyleView;
    self.sectionFooterStyle = DTTableViewSectionStyleView;
    
    [storage addItem:[Example exampleWithText:@"Section 1 cell" andDetails:nil]];
    [storage addItem:[Example exampleWithText:@"Section 2 cell" andDetails:nil]
             toSection:1];
}

@end
