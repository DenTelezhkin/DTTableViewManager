DTTableViewManager
================

Powerful architecture for UITableView. The idea is to move all datasource methods to separate class, and add many helper methods to manage presentation of your data models.


## Why?

But first off, why do we need this? 

Lets imagine view controller, that manages table view presentation on itself. 

![https://github.com/DenHeadless/DTTableViewManager/blob/gh-pages/without.png](without.png)

Clearly, there are way to many connections, that your view controller needs to handle. And we only show table view stuff, however most likely your view controller is also doing other things, which will make this graph even more complicated. 

Solution for this - separate datasource from view controller. DTTableViewManager does just that. Here's how picture looks, when we use it:

![https://github.com/DenHeadless/DTTableViewManager/blob/gh-pages/with.png](with.png)

In the end, view controller is left with following stuff:

* Set mapping between data model class and cell class.
* Populate table view with data models

When view controller manages insertion, deletion, or moves items, it always struggles to keep datasource and table view in sync. DTTableViewManager does this automatically. View controller handles data models - table view is automatically updated.

Okay, enough talking, let's dive into code!  

## How?

Simplest way for view controller is to subclass DTTableViewManager (it's not required, you can make it a separate object).

#### Adding data models to the table view

##### One item
	
	[self addTableItem:model];
	
	[self addTableItem:model withRowAnimation:UITableViewRowAnimationAutomatic;
	
	[self addTableItem:model toSection:0];
	
All methods above are just shortcuts to method:

	[self addTableItem:model toSection:0 withRowAnimation:UITableViewRowAnimationAutomatic];

##### Array of items

	[self addTableItems:@[model1,model2]];
	[self addTableItems:@[model1,model2] toSection:0];
	[self addTableItems:@[model1,model2] withRowAnimation:UITableViewRowAnimationAutomatic];
	
These methods are shortcuts to method:
	
	[self addTableItems:@[model1,model2] toSection:0 withRowAnimation:UITableViewRowAnimationAutomatic];
	
#### Mapping data models to cells
	
Creating cell in code:

	[self setCellMapping:[Cell class] modelClass:[Model class]];
	
Custom XIB for cell:	
	
	[self setCellMappingForNib:@"nib" cellClass:[Cell class] modelCLass:[Model class]];
	
#### Removing data models

	[self removeTableItem:model];
	[self removeTableItem:model withRowAnimation:UITableViewRowAnimationAutomatic];
	[self removeTableItems:@[model1,model2]];
	[self removeTableItems:@[model1,model2] withRowAnimation:UITableViewRowAnimationAutomatic];
	
#### Replacing data models

	[self replaceTableItem:model1 withTableItem:model2];
	[self replaceTableItem:model1 withTableItem:model2 andRowAnimation:UITableViewRowAnimationAutomatic];
	
#### Inserting data models

	[self insertTableItem:model toIndexPath:indexPath];
	[self insertTableItem:model toIndexPath:indexPath withRowAnimation:UITableViewRowAnimationAutomatic];
	
	
## What else do you have?

List is not full, for additional features like:

* Search for tableItem / tableItems, getting all items from one section etc.
* Section headers/footers titles and custom views
* Section manipulations (delete, reload, move)

head on to documentation.
	
## Notes on implementation

* This approach requires every table view cell to have it's data model object. 
* Every cell after creation gets called with method updateWithModel: and receives data model to represent. Every cell needs to conform to DTTableViewModelTransfer protocol.
* You can make your controller a subclass of DTTableViewManager, or you can make it a property on your controller and subclass from whatever you need. 
* Any datasource/delegate method can be overridden in your controller. In case you are making DTTableViewManager a property on your UIViewController, datasource methods will be trampolined to your controller. 

## Requirements

* iOS 5.0
* ARC
        
## Installation

Simplest option is to use [CocoaPods](http://www.cocoapods.org):

	pod 'DTTableViewManager'
	
## Example 

Example project is available in Example folder. 

## Documentation

You can view documentation [online](http://denheadless.github.com/DTTableViewManager/) or you can install it locally using following atom link: [http://denheadless.github.com/DTTableViewManager/DTTableViewManager.atom](http://denheadless.github.com/DTTableViewManager/DTTableViewManager.atom).

[Changelog](https://github.com/DenHeadless/DTTableViewManager/wiki/Changelog)
		
## Thanks

Special thanks to Alexey Belkevich (https://github.com/belkevich) for providing initial implementation of CellFactory.