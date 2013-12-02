![Build Status](https://travis-ci.org/DenHeadless/DTTableViewManager.png?branch=master,develop) &nbsp;
![CocoaPod platform](https://cocoapod-badges.herokuapp.com/p/DTTableViewManager/badge.png) &nbsp; 
![CocoaPod version](https://cocoapod-badges.herokuapp.com/v/DTTableViewManager/badge.png) &nbsp; 
![License MIT](https://go-shields.herokuapp.com/license-MIT-blue.png)

DTTableViewManager
================
> This is a sister-project for [DTCollectionViewManager](https://github.com/DenHeadless/DTCollectionViewManager) - great tool for UICollectionView management, built on the same principles.

The idea of this project is to move all datasource methods to separate class, and add many helper methods to manage presentation of your data models.

## Features

* Simple handling of custom table view cells, headers and footers
* Support for creating cells from code, XIBs or storyboards!
* Super easy search 
* Automatic datasource and interface synchronization
* Dramatic decrease of code amount needed for any UITableView implementation.
* Good unit test coverage

The best way to understand, what we are trying to achieve here, is to take a look at example, provided in Example folder.

## How?

Lets imagine view controller, that manages table view presentation on itself. 

<p align="center" >
  <img src="without.png" alt="without" title="without.png">
</p>

Clearly, there are way to many connections, that your view controller needs to handle. And we only show table view stuff, however most likely your view controller is also doing other things, which will make this graph even more complicated. 

Solution for this - separate datasource from view controller. DTTableViewManager does just that. Here's how picture looks, when we use it:

<p align="center" >
  <img src="with.png" alt="with" title="with.png">
</p>

In the end, view controller is left with following stuff:

* Register mapping between data model class and cell class.
* Populate table view with data models

Okay, enough talking, let's dive into code. Simplest way for view controller is to subclass DTTableViewManager, set it's tableView property, delegate, datasource and off you go!

## Mapping

* Cells

```objective-c
[self registerCellClass:[Cell class] forModelClass:[Model class]];
```

* Headers/Footers

```objective-c
[self registerHeaderClass:[HeaderView class] forModelClass:[Model class]];
[self registerFooterClass:[FooterView class] forModelClass:[Model class]];
```

This will also register nibs with "Cell", "HeaderView" and "FooterView" name, if any of them exist. 

[Note](https://github.com/DenHeadless/DTTableViewManager/wiki/Foundation-classes-as-data-models-for-DTTableViewManager) on using Foundation classes as data models.

## Managing table items

##### Adding one item

```objective-c
[self addTableItem:model];
[self addTableItem:model withRowAnimation:UITableViewRowAnimationAutomatic;
[self addTableItem:model toSection:0];
[self addTableItem:model toSection:0 withRowAnimation:UITableViewRowAnimationFade];
```

##### Adding array of items

```objective-c
[self addTableItems:@[model1,model2]];
[self addTableItems:@[model1,model2] toSection:0];
[self addTableItems:@[model1,model2] withRowAnimation:UITableViewRowAnimationFade];
[self addTableItems:@[model1,model2] toSection:0 withRowAnimation:UITableViewRowAnimationAutomatic];
```

#### Removing data models

```objective-c
[self removeTableItem:model];
[self removeTableItem:model withRowAnimation:UITableViewRowAnimationAutomatic];
[self removeTableItems:@[model1,model2]];
[self removeTableItems:@[model1,model2] withRowAnimation:UITableViewRowAnimationAutomatic];
```	

#### Replacing data models

```objective-c
[self replaceTableItem:model1 withTableItem:model2];
[self replaceTableItem:model1 withTableItem:model2 andRowAnimation:UITableViewRowAnimationAutomatic];
```

#### Inserting data models

```objective-c
[self insertTableItem:model toIndexPath:indexPath];
[self insertTableItem:model toIndexPath:indexPath withRowAnimation:UITableViewRowAnimationAutomatic];
```	

## Awesome search!
	
There are two ways of using search. In both cases your data models should conform to `DTTableViewModelSearching` protocol. You need to implement method shouldShowInSearchResultsForSearchString:inScopeIndex: on your data model, this way DTTableViewManager will know, when to show data models.

#### Automatic

Set UISearchBar's delegate property to your `DTTableViewManager` subclass. That's it, you've got search implemented!

#### Manual

Any time you need your models sorted, call method 

```objective-c
filterTableItemsForSearchString:
```

Every data model in the table will be called with method 

```objective-c
shouldShowInSearchResultsForSearchString:inScopeIndex:
```

and tableView will be automatically updated with results.

## Storyboard prototype cells

To use storyboard prototype cells, set reuseIdentifier for table cell with the name of your model class. Call registerCellClass:forModelClass: just as for xib registration. 

You can also take a look at example, which contains storyboard table view with prototyped cell.

## What else do you have?

List is not full, for additional features like:

* Section headers/footers titles and custom views
* Section manipulations (delete, reload, move)
* Search for tableItem / tableItems, getting all items from one section etc.

head on to documentation.
	
## Notes on implementation

* This approach requires every table view cell to have it's data model object. 
* Every cell, header or footer view after creation gets called with method updateWithModel: and receives data model to represent. 
* Any datasource/delegate method can be overridden in your controller.  

## Requirements

* iOS 6.0
* ARC
        
## Installation

Simplest option is to use [CocoaPods](http://www.cocoapods.org):

	pod 'DTTableViewManager', '~> 1.3.0'

## Documentation

You can view documentation online or you can install it locally using [cocoadocs](http://cocoadocs.org/docsets/DTTableViewManager)!

## Thanks

Special thanks to [Alexey Belkevich](https://github.com/belkevich) for providing initial implementation of CellFactory.


[![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/DenHeadless/dttableviewmanager/trend.png)](https://bitdeli.com/free "Bitdeli Badge")

