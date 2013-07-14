//
//  CustomHeaderFooterView.m
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 24.03.13.
//  Copyright (c) 2013 Denys Telezhkin. All rights reserved.
//

#import "CustomHeaderFooterView.h"

@implementation CustomHeaderFooterView

-(void)updateWithModel:(id)model
{
    NSNumber * headerNumber = model;
    
    switch ([headerNumber intValue]) {
        case kHeaderKind:
            self.backgroundPatternView.backgroundColor = [UIColor colorWithPatternImage:
                                                          [UIImage imageNamed:@"textured_paper.png"]];
            self.headerTitleLabel.text = @"Awesome custom header";
            break;
        case kFooterKind:
            self.backgroundPatternView.backgroundColor = [UIColor colorWithPatternImage:
                                                          [UIImage imageNamed:@"mochaGrunge.png"]];
            self.headerTitleLabel.text = @"Not so awesome custom footer";
            break;
        default:
            break;
    }
}

@end
