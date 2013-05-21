//
//  DTTableViewCell.m
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 21.05.13.
//  Copyright (c) 2013 Denys Telezhkin. All rights reserved.
//

#import "DTTableViewCell.h"

@implementation DTTableViewCell

-(void)updateWithModel:(id)model
{
    NSString * reason = [NSString stringWithFormat:@"cell %@ should implement updateWithModel: method\n",
                         NSStringFromClass([self class])];
    NSException * exc =
    [NSException exceptionWithName:@"DTTableViewManager API exception"
                            reason:reason
                          userInfo:nil];
    [exc raise];
}

-(id)model
{
    return nil;
}
@end
