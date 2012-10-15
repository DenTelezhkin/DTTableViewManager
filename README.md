TableViewFactory
================

Powerful architecture for table view controllers. Warning - setup will sound complex, but once you use it at least once, you will see the benefits.

### Usage

* Your controller with table view needs to be a subclass of DTBaseTableViewController. It will have property tableView - put your table view there.
* You need to have a model for each type of table view cell. Every cell needs to conform to TableViewModelProtocol(method updateWithModel: is required).
* Map every cell class to model class. 
* Add some table items to the table!

### 0.0.2 changes

* Added option to disable reusing table view cells
* Added support for creating cells from custom NIB. I use registerNib method to do that. 

Example project updated with these changes.

### Example 

Example is available in Example folder. 

### Additional 

Please go to DTBaseTableViewController.h for all available API. Example project is included in Example folder.
CellFactory uses SynthethizeSingleton macros (...), but you can use any singleton approach you like.

### Discussion

This approach intends to clean your view controller from massive amounts of repeatable datasource code. It helps to think about table view models instead of table view cells. Table view cells should be responsive for displaying their content, and controller should only be responsive for displaying cells. 
		
### Thanks

Special thanks to Alexey Belkevich (https://github.com/belkevich) for providing initial implementation of CellFactory and SingletonFactory, they are really the core of this approach.