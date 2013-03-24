//
//  CustomHeaderView.m
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 24.03.13.
//  Copyright (c) 2013 Denys Telezhkin. All rights reserved.
//

#import "CustomHeaderView.h"
#import "CustomHeaderFooterModel.h"
@implementation CustomHeaderView

-(void)updateWithModel:(id)model
{
    CustomHeaderFooterModel * customModel = model;
    
    if (customModel.viewKind == kHeaderKind)
    {
        self.backgroundColor = [UIColor colorWithPatternImage:
                                                      [UIImage imageNamed:@"textured_paper.png"]];
        self.titleLabel.text = @"Awesome custom header";
    }
    if (customModel.viewKind == kFooterKind)
    {
        self.backgroundColor = [UIColor colorWithPatternImage:
                                                      [UIImage imageNamed:@"mochaGrunge.png"]];
        self.titleLabel.text = @"Not so awesome custom footer";
    }
}

@end
