TableViewFactory
================

Powerful architecture for table view controllers. Warning - setup will sound complex, but once you use it at least once, you will see the benefits.

### Setup

* CellFactory uses SingletonFactory, if you wish to use another approach to singletons, simply remove SingletonFactory and SingletonProtocol from the project. Otherwise use AppDataStore property on AppDelegate.

### Usage

* Your controller with table view needs to be a subclass of BaseTableViewController. It will have property table - put your table view there.
* You need to have a model for each type of table view cell
* Map every type of cell to type of model it will use. This is done in CellFactory init method.
* Implement -(void)updateWithModel:(id)model for each type of tableViewCell you are using. 
* Add some table items to the table!

### Example 

		ExampleModel * model = [[[ExampleModel alloc] initWith...] autorelease];
		[self addTableItem:model];

### Additional 

Please go to BaseTableViewController.h for all available API. Example project is included in Example folder.

### Example project installation

Project uses CocoaPods(Please visit www.cocoapods.org for install guide).

setup: in project directory
pod install

open TableViewFactory.xcworkspace.


### Discussion

This approach intends to clean your view controller from massive amounts of repeatable delegate and datasource code. It helps to think about table view models instead of table view cells. Table view cells should be responsive for displaying their content, and controller should only be responsive for displaying cells. 
		