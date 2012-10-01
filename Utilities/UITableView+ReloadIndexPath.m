//
//  UITableView+ReloadIndexPath.m
//  ainifinity
//
//  Created by Alexey Belkevich on 7/7/12.
//  Copyright (c) 2012 MLSDev. All rights reserved.
//

#import "UITableView+ReloadIndexPath.h"

@implementation UITableView (ReloadIndexPath)

- (void)insertRowAtIndexPaths:(NSIndexPath *)indexPath 
             withRowAnimation:(UITableViewRowAnimation)animation
{
    NSArray *array = [NSArray arrayWithObject:indexPath];
    [self insertRowsAtIndexPaths:array withRowAnimation:animation];
}

- (void)reloadRowAtIndexPath:(NSIndexPath *)indexPath 
            withRowAnimation:(UITableViewRowAnimation)animation
{
    NSArray *array = [NSArray arrayWithObject:indexPath];
    [self reloadRowsAtIndexPaths:array withRowAnimation:animation];
}

@end
