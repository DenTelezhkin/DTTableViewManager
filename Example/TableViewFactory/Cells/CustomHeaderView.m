//
//  CustomHeaderView.m
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 24.03.13.
//  Copyright (c) 2013 Denys Telezhkin. All rights reserved.
//

#import "CustomHeaderView.h"
@implementation CustomHeaderView

-(void)updateWithModel:(id)model
{
    NSNumber * headerKindNumber = model;
    
    switch ([headerKindNumber intValue]) {
        case kHeaderKind:
            self.backgroundColor = [UIColor colorWithPatternImage:
                                    [UIImage imageNamed:@"textured_paper.png"]];
            self.titleLabel.text = @"Awesome custom header";
            break;
        case  kFooterKind:
            self.backgroundColor = [UIColor colorWithPatternImage:
                                    [UIImage imageNamed:@"mochaGrunge.png"]];
            self.titleLabel.text = @"Not so awesome custom footer";
            break;
        default:
            break;
    }
}

@end
