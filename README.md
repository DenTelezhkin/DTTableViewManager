![Build Status](https://travis-ci.org/DenHeadless/DTTableViewManager.png?branch=master) &nbsp;
![CocoaPod platform](https://cocoapod-badges.herokuapp.com/p/DTTableViewManager/badge.png) &nbsp; 
![CocoaPod version](https://cocoapod-badges.herokuapp.com/v/DTTableViewManager/badge.png) &nbsp; 
![License MIT](https://go-shields.herokuapp.com/license-MIT-blue.png)

DTTableViewManager
================
> This is a sister-project for [DTCollectionViewManager](https://github.com/DenHeadless/DTCollectionViewManager) - great tool for UICollectionView management, built on the same principles.

The idea of this project is to move all datasource methods to separate class, and add many helper methods to manage presentation of your data models.

## 2.0

DTTableViewManager 2.0 is a major update to the framework, introducing big changes to the architecture and bringing several powerful features. 

### What's new

* Refactored and more modular architecture
* Support for CoreData/NSFetchedResultsController
* Support for custom data storage objects

## Features

* Powerful mapping system between data models and table view cells, headers and footers
* Automatic datasource and interface synchronization.
* Support for creating cells from code, XIBs or storyboards.
* Easy UITableView search 
* Core data / NSFetchedResultsController support

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

Okay, enough talking, let's dive into code. Simplest way for view controller is to subclass DTTableViewController, set it's tableView property, delegate, datasource and off you go!

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

If you use storyboards and prototype cells/headers/footers, you will need to set reuseIdentifier for corresponding cell in storyboard.

[Note](https://github.com/DenHeadless/DTTableViewManager/wiki/Foundation-classes-as-data-models-for-DTTableViewManager) on using Foundation classes as data models.

# Managing table items

Starting with 2.0, DTTableViewManager supports custom data storage objects to provide data models. It also provides two default data storage classes, that can be used. Let's start with DTTableViewMemoryStorage, that is used by default.

## DTTableViewMemoryStorage

DTTableViewMemoryStorage encapsulates storage of table view data models in memory. It's basically NSArray of DTTableViewSectionModel objects, which contain array of objects for current section, section header and footer model.

To work with memory storage, you will need to get it's instance from your DTTableViewController subclass.

```objective-c
DTTableViewMemoryStorage * storage = (DTTableViewMemoryStorage *)self.dataStorage;
```

##### Adding one item

```objective-c
[storage addTableItem:model];
[storage addTableItem:model toSection:0];
```

##### Adding array of items

```objective-c
[storage addTableItems:@[model1,model2]];
[storage addTableItems:@[model1,model2] toSection:0];
```

#### Removing data models

```objective-c
[storage removeTableItem:model];
[storage removeTableItems:@[model1,model2]];
```	

#### Replacing data models

```objective-c
[storage replaceTableItem:model1 withTableItem:model2];
```

#### Inserting data models

```objective-c
[storage insertTableItem:model toIndexPath:indexPath];
```	

### Search
	
Set UISearchBar's delegate property to your `DTTableViewManager` subclass. 	
Data models should conform to `DTTableViewModelSearching` protocol. You need to implement method shouldShowInSearchResultsForSearchString:inScopeIndex: on your data model, this way DTTableViewManager will know, when to show data models.

Searching data storage will be created automatically for current search, and it will be used as a datasource for UITableView.
	
## DTTableViewCoreDataStorage

This storage is meant to be used with NSFetchedResultsController. It automatically monitors all NSFetchedResultsControllerDelegate methods and updates UI accordingly to it's changes. All you need to do to display CoreData models in your UITableView, is create DTTableVIewCoreDataStorage object and set it on your DTTableViewController subclass.

```objective-c
self.dataStorage = [DTTableViewCoreDataStorage storageWithFetchResultsController:controller];
```	

### Search

Subclass DTTableViewCoreDataStorage and implement single method 
```objective-c
searchingStorageForSearchString:inSearchScope:
```	

You will need to provide a storage with NSFetchedResultsController and appropriate NSPredicate. Take a look at example application, that does just that.
	
## Notes on implementation

* This approach requires every table view cell to have it's data model object. 
* Every cell, header or footer view after creation gets called with method updateWithModel: and receives data model to represent. 
* Any datasource/delegate method can be overridden in your controller.  

## Requirements

* iOS 6.0
* XCode 5
        
## Installation

Simplest option is to use [CocoaPods](http://www.cocoapods.org):

	pod 'DTTableViewManager', '~> 1.3.1'

## Documentation

You can view documentation online or you can install it locally using [cocoadocs](http://cocoadocs.org/docsets/DTTableViewManager)!

## Example

Take a look at example application, it shows most common use cases for framework and how DTTableViewManager handles different situations. Don't miss CoreData examples, they are awesome =)

## Thanks

* [Alexey Belkevich](https://github.com/belkevich) for providing initial implementation of CellFactory.
* [Michael Fey](https://github.com/MrRooni) for providing insight into NSFetchedResultsController updates done right. 

[![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/DenHeadless/dttableviewmanager/trend.png)](https://bitdeli.com/free "Bitdeli Badge")

