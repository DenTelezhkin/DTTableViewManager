//
//  UITableView+ReloadIndexPath.h
//  ainifinity
//
//  Created by Alexey Belkevich on 7/7/12.
//  Copyright (c) 2012 MLSDev. All rights reserved.
//

@interface UITableView (ReloadIndexPath)

- (void)insertRowAtIndexPaths:(NSIndexPath *)indexPath 
             withRowAnimation:(UITableViewRowAnimation)animation;
- (void)reloadRowAtIndexPath:(NSIndexPath *)indexPath 
            withRowAnimation:(UITableViewRowAnimation)animation;

@end
