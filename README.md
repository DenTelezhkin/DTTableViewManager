![CocoaPod platform](https://cocoapod-badges.herokuapp.com/p/DTTableViewManager/badge.png) &nbsp;
![CocoaPod version](https://cocoapod-badges.herokuapp.com/v/DTTableViewManager/badge.png) &nbsp;
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
![License MIT](https://go-shields.herokuapp.com/license-MIT-blue.png)

DTTableViewManager 4
================
> This is a sister-project for [DTCollectionViewManager](https://github.com/DenHeadless/DTCollectionViewManager) - great tool for UICollectionView management, built on the same principles.

Powerful protocol-oriented UITableView management framework, written in Swift 2.

## Features

- [x] Powerful mapping system between data models and cells, headers and footers
- [x] Flexible Memory/CoreData/Custom storage options
- [x] Automatic datasource and interface synchronization.
- [x] Automatic XIB registration and dequeue
- [x] No type casts required
- [x] No need to subclass
- [x] Support for all Swift types - classes, structs, enums, tuples
- [x] Can be used with UITableViewController, or UIViewController with UITableView, or any other class, that contains UITableView

## Requirements

* XCode 7 and higher
* iOS 8,9
* Swift 2

## Installation

[CocoaPods](http://www.cocoapods.org):

    pod 'DTTableViewManager', '~> 4.0.0'

[Carthage](https://github.com/Carthage/Carthage):

    github "DenHeadless/DTTableViewManager"

After running `carthage update` drop DTTableViewManager.framework and DTModelStorage.framework to XCode project embedded binaries.

## Quick start

`DTTableViewManager` framework has two parts - core framework, and storage classes. Import them both to your view controller class to start:

```swift
import DTTableViewManager
import DTModelStorage
```

The core object of a framework is `DTTableViewManager`. Declare your class as `DTTableViewManageable`, and it will be automatically injected with `manager` property, that will hold an instance of `DTTableViewManager`.

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

* Call registration methods on your `DTTableViewManageable` instance

```swift
	manager.registerCellClass(PostCell)
```

ModelType will be automatically gathered from your `PostCell`. If you have a PostCell.xib file, it will be automatically registered for PostCell. If you have a storyboard with PostCell, set it's reuseIdentifier to be identical to class - "PostCell".

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

By default, `DTTableViewManager` uses section titles and `tableView(_:titleForHeaderInSection:)` UITableViewDatasource methods. However, if you call any mapping methods for headers or footers, it will automatically switch to using `tableView(_:viewForHeaderInSection:)` methods and dequeue `UITableViewHeaderFooterView` instances. Make your `UITableViewHeaderFooterView` subclasses conform to `ModelTransfer` protocol to allow them participate in mapping.

You can also use UIView subclasses for headers and footers.

For more detailed look at mapping in DTTableViewManager, check out dedicated *[Mapping wiki page](https://github.com/DenHeadless/DTTableViewManager/wiki/Mapping-and-registration)*.

## DTModelStorage

[DTModelStorage](https://github.com/DenHeadless/DTModelStorage/) is a framework, that provides storage classes for `DTTableViewManager`. By default, storage property on `DTTableViewManager` holds a `MemoryStorage` instance.

### MemoryStorage

`MemoryStorage` is a class, that manages UITableView models in memory. It has methods for adding, removing, replacing, reordering table view models etc. You can read all about them in [DTModelStorage repo](https://github.com/DenHeadless/DTModelStorage#memorystorage). Basically, every section in `MemoryStorage` is an array of `SectionModel` objects, which itself is an object, that contains optional header and footer models, and array of table items.

### NSFetchedResultsController and CoreDataStorage

`CoreDataStorage` is meant to be used with NSFetchedResultsController. It automatically monitors all NSFetchedResultsControllerDelegate methods and updates UI accordingly to it's changes. All you need to do to display CoreData models in your UITableView, is create CoreDataStorage object and set it on your `storage` property of `DTTableViewManager`.

Keep in mind, that MemoryStorage is not limited to objects in memory. For example, if you have CoreData database, and you now for sure, that number of items is not big, you can choose not to use CoreDataStorage and NSFetchedResultsController. You can fetch all required models, and store them in MemoryStorage.

## Subclassing storage classes

For in-depth look at how subclassing storage classes can improve your code base, read [this article](https://github.com/DenHeadless/DTTableViewManager/wiki/Extracting-logic-into-storage-subclasses) on wiki.

## Reacting to events

You can register closures, that will be executed on various events. First and most important is cell selection event.

**Important**

All events are stored on `DTTableViewManager` instance, so be sure to declare self weak in capture lists to prevent retain cycles.

### Selection

 Instead of reacting to cell selection at UITableView NSIndexPath, `DTTableViewManager` allows you to react when user selects concrete model:

```swift
  manager.whenSelected(PostCell.self) { postCell, post, indexPath in
      print("Selected \(post) in \(postCell) at \(indexPath)")
  }
```

Thanks to generics, `postCell` and `post` are already a concrete type, there's no need to check types and cast. There' also a shortcut to registration and selection method:

```swift
  manager.registerCellClass(PostCell.self, whenSelected: { postCell, post, indexPath in })
```

### Configuration

Although in most cases your cell can update it's UI with model inside `updateWithModel:` method, sometimes you may need to additionally configure it from controller. There are three events you can react to:

```swift
  manager.configureCell(PostCell.self) { postCell, post, indexPath in }
  manager.configureHeader(PostHeader.self) { postHeader, postHeaderModel, sectionIndex in }
  manager.configureFooter(PostFooter.self) { postFooter, postFooterModel, sectionIndex in }
```

### Content updates

Sometimes it's convenient to know, when data is updated, for example to hide UITableView, if there's no data.

```swift
  manager.beforeContentUpdate {}
  manager.afterContentUpdate {}
```

## UITableViewDelegate and UITableViewDatasource

`DTTableViewManager` serves as a datasource and the delegate to `UITableView`. However, it implements only some of UITableViewDelegate and UITableViewDatasource methods, other methods will be redirected to your controller, if it implements it.

## Convenience model getters

There are several convenience model getters, that will allow you to get data model from storage classes. Those include cell, header or footer class types to gather type information and being able to return model of correct type. Again, no need for type casts.

```swift
  let post = manager.objectForCellClass(PostCell.self, atIndexPath: indexPath)
  let postHeaderModel = manager.objectForHeaderClass(PostHeaderClass.self, atSectionIndex: sectionIndex)
  let postFooterModel = manager.objectForFooterClass(PostFooterClass.self, atSectionIndex: sectionIndex)
```

There's also convenience getter, that will allow you to get model from visible `UITableViewCell`.

```swift
  let post = manager.objectForVisibleCell(postCell)
```

## Configuration

There are various customization options available with `DTTableViewManager`. Those are all concentrated in `TableViewConfiguration` class. They allow to customize:

* Row insert, update, and delete animation
* Section insert, update and delete animation
* Section header and footer styles - title or view
* Should section header and footer be displayed on empty section

## ObjectiveC

`DTTableViewManager` is heavily relying on Swift 2 protocol extensions, generics and associated types. Enabling this stuff to work on objective-c right now is not possible. Because of this DTTableViewManager 4 does not support usage in objective-c. If you need to use objective-c, you can use [latest compatible version of `DTTableViewManager`](https://github.com/DenHeadless/DTTableViewManager/releases/tag/3.2.0).

## Documentation

You can view documentation online or you can install it locally using [cocoadocs](http://cocoadocs.org/docsets/DTTableViewManager)!

Also check out [wiki page](https://github.com/DenHeadless/DTTableViewManager/wiki) for some information on DTTableViewManager internals.

## Examples

There is an example project, that shows some usage examples of `DTTableViewManager`.

## Thanks

* [Alexey Belkevich](https://github.com/belkevich) for providing initial implementation of CellFactory.
* [Michael Fey](https://github.com/MrRooni) for providing insight into NSFetchedResultsController updates done right.
* [Nickolay Sheika](https://github.com/hawk-ukr) for great feedback, that helped shaping 3.0 release.
* [Artem Antihevich](https://github.com/sinarionn) for great discussions about Swift generics and type capturing.
