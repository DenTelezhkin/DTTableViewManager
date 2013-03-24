//
//  CustomHeaderFooterView.m
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 24.03.13.
//  Copyright (c) 2013 Denys Telezhkin. All rights reserved.
//

#import "CustomHeaderFooterView.h"
#import "CustomHeaderFooterModel.h"

@implementation CustomHeaderFooterView

-(void)updateWithModel:(id)model
{
    CustomHeaderFooterModel * customModel = model;
    
    if (customModel.viewKind == kHeaderKind)
    {
        self.backgroundPatternView.backgroundColor = [UIColor colorWithPatternImage:
                                            [UIImage imageNamed:@"textured_paper.png"]];
        self.headerTitleLabel.text = @"Awesome custom header";
    }
    if (customModel.viewKind == kFooterKind)
    {
        self.backgroundPatternView.backgroundColor = [UIColor colorWithPatternImage:
                                            [UIImage imageNamed:@"mochaGrunge.png"]];
        self.headerTitleLabel.text = @"Not so awesome custom footer";
    }
}

@end
