//
//  ExampleCell.m
//  TableViewFactory
//
//  Created by Denys Telezhkin on 10/1/12.
//  Copyright (c) 2012 Denys Telezhkin. All rights reserved.
//

#import "ExampleCell.h"
#import "Example.h"

@interface ExampleCell()
@property (nonatomic,retain) Example * exampleModel;
@end

@implementation ExampleCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)updateWithModel:(id)model
{
    self.exampleModel = model;
    
    self.textLabel.text = self.exampleModel.someText;
    self.detailTextLabel.text = self.exampleModel.details;
}

-(void)dealloc
{
    self.exampleModel = nil;
    [super dealloc];
}

@end
