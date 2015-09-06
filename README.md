![CocoaPod platform](https://cocoapod-badges.herokuapp.com/p/DTTableViewManager/badge.png) &nbsp; 
![CocoaPod version](https://cocoapod-badges.herokuapp.com/v/DTTableViewManager/badge.png) &nbsp; 
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
![License MIT](https://go-shields.herokuapp.com/license-MIT-blue.png)

DTTableViewManager
================
> This is a sister-project for [DTCollectionViewManager](https://github.com/DenHeadless/DTCollectionViewManager) - great tool for UICollectionView management, built on the same principles.

Powerful protocol-oriented UITableView management framework, written in Swift. 

## Features

- [x] Safe, compile-time powered mapping system between data models and table view cells, headers and footers
- [x] Support for UITableViewController, UIViewController with UITableView, or any other object, that has a UITableView
- [x] Flexible datasource model with support for models in memory, CoreData, or even custom storages
- [x] Automatic datasource and interface synchronization.
- [x] Automatic XIB registration and dequeue
- [x] No type casts required
- [x] No need to subclass
- [x] Support for all Swift types - classes, structs, enums, tuples

## Requirements 

- iOS 8.0+
- XCode 7
- Swift 2

## Installation

[CocoaPods](http://www.cocoapods.org):

    pod 'DTTableViewManager', '~> 4.0.0'
	
[Carthage](https://github.com/Carthage/Carthage):

    github "DenHeadless/DTTableViewManager"

## Quick start

The core object of a framework is `DTTableViewManager`. Declare your class as 'DTTableViewManageable', and it will be automatically injected with `manager` property, that will hold an instance of `DTTableViewManager`.

First, call `startManagingWithDelegate:` to initiate UITableView management. Make sure your UITableView outlet is wired to your class.

```swift
	manager.startManagingWithDelegate(self)
```

Let's say you have an array of Posts you want to display in UITableView. To quickly show them using DTTableViewManager, here's what you need to do:

* Create UITableViewCell subclass, let's say PostCell. Adopt ModelTransfer protocol

```swift
class PostCell : UITableViewCell, ModelTransfer 
{
	func updateWithModel(model: Post)
	{
		// Fill your cell with actual data
	}
}
```

* Call registration methods on your DTTableViewManageable instance

```swift
	manager.registerCellClass(PostCell)
```

ModelType will be automatically gathered from your `PostCell`. If you have a PostCell.xib file, it will be automatically registered for PostCell.

* Add your posts!

```swift
	manager.memoryStorage.addItems(posts)
```

That's it! It's that easy!

## Mapping and registration

* `registerCellClass:`
* `registerNibNamed:forCellClass:`
* `registerHeaderClass:`
* `registerNibNamed:forHeaderClass:`
* `registerFooterClass:`
* `registerNibNamed:forFooterClass:`

By default, `DTTableViewManager` uses section titles and `tableView(_:titleForHeaderInSection:)` UITableViewDatasource methods. However, if you call any mapping methods for headers or footers, it will automatically switch to using 'tableView(_:viewForHeaderInSection:)' methods and dequeue UITableViewHeaderFooterView instances. Make your `UITableViewHeaderFooterView` subclasses conform to `ModelTransfer` protocol to allow them to participate in mapping.

You can also use UIView subclasses for headers and footers.

For more detailed look at mapping in DTTableViewManager, check out dedicated *[Mapping wiki page](https://github.com/DenHeadless/DTTableViewManager/wiki/Mapping)*.

### DTModelStorage

[DTModelStorage](https://github.com/DenHeadless/DTModelStorage/) is a framework, that provides storage classes for `DTTableViewManager`. By default, storage class is a `MemoryStorage` instance.

`MemoryStorage` is a class, that manages UITableView models in memory. It has methods for adding, removing, replacing, reordering table view models etc. You can read all about them in [DTModelStorage repo](https://github.com/DenHeadless/DTModelStorage). Basically, every section in `MemoryStorage` is an array of `SectionModel` objects, which itself is an object, that contains optional header and footer models, and array of table items.


**You can take a look at all provided methods for manipulating items here: [DTMemoryStorage methods](https://github.com/DenHeadless/DTModelStorage/blob/master/README.md#adding-items)**

DTTableViewManager adds several methods to `DTMemoryStorage`, that are specific to UITableView. Take a look at them here: **[DTMemoryStorage additions](https://github.com/DenHeadless/DTTableViewManager/wiki/DTMemoryStorage-additions)**

### NSFetchedResultsController and DTCoreDataStorage

`DTCoreDataStorage` is meant to be used with NSFetchedResultsController. It automatically monitors all NSFetchedResultsControllerDelegate methods and updates UI accordingly to it's changes. All you need to do to display CoreData models in your UITableView, is create DTCoreDataStorage object and set it on your DTTableViewController subclass.

```objective-c
self.dataStorage = [DTCoreDataStorage storageWithFetchResultsController:controller];
```

**Important** Keep in mind, that DTMemoryStorage is not limited to objects in memory. For example, if you have CoreData database, and you now for sure, that number of items is not big, you can choose not to use DTCoreDataStorage and NSFetchedResultsController. You can fetch all required models, and store them in DTMemoryStorage, just like you would do with NSObject subclasses.

##### Search

DTTableViewManager has a built-in search system, that is easy to use and flexible. Read all about it in a dedicated **[Implementing search](https://github.com/DenHeadless/DTTableViewManager/wiki/Implementing-search)** wiki page.	


## Requirements

* XCode 6.3 and higher
* iOS 7.x, 8.x
* ARC
        
## Installation

[CocoaPods](http://www.cocoapods.org):

    pod 'DTTableViewManager', '~> 3.1.0'
	
[Carthage](https://github.com/Carthage/Carthage):

    github "DenHeadless/DTTableViewManager"
    
Carthage uses dynamic frameworks, which require iOS 8 and higher. After running `carthage update` drop DTTableViewManager.framework and DTModelStorage.framework to XCode project embedded binaries.

## Documentation

You can view documentation online or you can install it locally using [cocoadocs](http://cocoadocs.org/docsets/DTTableViewManager)!

Also check out [wiki page](https://github.com/DenHeadless/DTTableViewManager/wiki) for lot's of information on DTTableViewManager internals and best practices.

## Thanks

* [Alexey Belkevich](https://github.com/belkevich) for providing initial implementation of CellFactory.
* [Michael Fey](https://github.com/MrRooni) for providing insight into NSFetchedResultsController updates done right. 
* [Nickolay Sheika](https://github.com/hawk-ukr) for great feedback, that helped shaping 3.0 release.
