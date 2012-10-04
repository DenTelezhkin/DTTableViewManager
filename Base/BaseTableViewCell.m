//
//  BaseTableViewCell.m
//  Messenger
//
//  Created by Denys Telezhkin on 9/11/12.
//  Copyright (c) 2012 Denys Telezhkin. All rights reserved.
//

#import "BaseTableViewCell.h"

@implementation BaseTableViewCell

-(id)initWithStyle:(UITableViewCellStyle)style
   reuseIdentifier:(NSString *)reuseIdentifier
          andModel:(id)model
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        [self updateWithModel:model];
    }
    return self;
}

-(void)updateWithModel:(id)model;
{
    NSString *reason = [NSString stringWithFormat:@"updateWithModel is not overridden by %@ class",
                                                                NSStringFromClass([self class])];
    @throw [NSException exceptionWithName:@"API misuse" reason:reason userInfo:nil];
}

-(id)model
{
    NSString *reason = [NSString stringWithFormat:@"model getter is not overridden by %@ class",
                        NSStringFromClass([self class])];
    @throw [NSException exceptionWithName:@"API misuse" reason:reason userInfo:nil];
}

@end
