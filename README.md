DTTableViewController
================

Powerful architecture for UITableView. The idea is to move all datasource methods to separate class, and add many helper methods to manage presentation of your data models.

Warning - setup will sound complex, but once you use it at least once, you will see the benefits.

## Core features

* Ability to manipulate models in the table view on the fly. No need to worry about datasource methods.
* Clean controller code
* Table view cells can be created from code, or from IB.
* You can make your controller a subclass of DTTableViewManager, or you can make it a property on your controller and subclass from whatever you need
* Any datasource/delegate method can be overridden in your controller

## Usage

### Subclassing

* You will have a property tableView - put your tableView there
* You need to have a model for each type of table view cell. Every cell needs to conform to DTTableViewModelProtocol(method updateWithModel: is required)
* Map every cell class to model class
* Add some table items to the table!

    	[self addTableItem:<modelObject>];
        
### Property on your controller

* Create DTTableViewManager object instance on your controler 

   		self.tableManager = [DTTableViewManager managerWithDelegate:self andTableView:self.tableView];    
* You need to have a model for each type of table view cell. Every cell needs to conform to DTTableViewModelProtocol(method updateWithModel: is required)
* Map every cell class to model class 
* Add some table items to the table!

		[self.tableManager addTableItem:<modelObject>];
        
## Changelog

[Changelog](https://github.com/DenHeadless/DTTableViewController/wiki/Changelog)

## Example 

Example is available in Example folder. 

## Additional 

Added support for ARC, DTCellFactory now uses [GCDSingleton macro](https://gist.github.com/1057420). If you need non-ARC version, please refer to [0.0.5 version](https://github.com/DenHeadless/DTTableViewController/tree/0.0.5).

## Discussion

This approach intends to clean your view controller from massive amounts of repeatable datasource code. It helps to think about table view models instead of table view cells. Table view cells should be responsive for displaying their content, and controller should only be responsive for displaying models, not cells. 
		
## Thanks

Special thanks to Alexey Belkevich (https://github.com/belkevich) for providing initial implementation of CellFactory.