//
//  BaseHeaderFooterView.m
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 25.05.13.
//  Copyright (c) 2013 Denys Telezhkin. All rights reserved.
//

#import "BaseHeaderFooterView.h"

@interface BaseHeaderFooterView()
@property (nonatomic, retain) id viewModel;
@end

@implementation BaseHeaderFooterView

-(void)updateWithModel:(id)model
{
    self.viewModel = model;
}

-(id)model
{
    return self.viewModel;
}

@end
