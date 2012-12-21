//
//  DTTableViewManagerCellProtocol.h
//  TableViewFactory
//
//  Created by Denys Telezhkin on 12/18/12.
//  Copyright (c) 2012 Denys Telezhkin. All rights reserved.
//

/**
 `DTTableViewCellCreation` protocol is used to pass created cell to your controller, so it can apply with additional customization, that cannot be specified in your `UITableViewCell` subclass. When you are using `DTTableViewManager` as a separate object, and your controller is a delegate, then method `tableView:cellForRowAtIndexPath:` won't be called on your controller, and you will need to use this protocol instead.
 
    @warning If controller is a subclass of DTTableViewManager, this protocol is not needed. You can receive cell by calling `DTTableViewManager` `tableView:cellForRowAtIndexPath:` method in your `tableView:cellForRowAtIndexPath:` method.
 */

@protocol DTTableViewCellCreation
@optional

/**
 Use this method, if you need to update cell from your controller. This method is equal to `tableView:cellForRowAtIndexPath:`, except that cell is already created and `updateWithModel:` method is already called on it.
 
 @param cell Custom cell object that was created to display your model.
 
 @param tableView TableView for which this cell is created.
 
 @param indexPath indexPath of the created cell.
 */
-(void)createdCell:(UITableViewCell *)cell
      forTableView:(UITableView *)tableView
 forRowAtIndexPath:(NSIndexPath *)indexPath;
@end