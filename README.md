![Build Status](https://travis-ci.org/DenHeadless/DTTableViewManager.svg?branch=master) &nbsp;
[![codecov.io](http://codecov.io/github/DenHeadless/DTTableViewManager/coverage.svg?branch=master)](http://codecov.io/github/DenHeadless/DTTableViewManager?branch=master)
![CocoaPod platform](https://cocoapod-badges.herokuapp.com/p/DTTableViewManager/badge.png) &nbsp;
![CocoaPod version](https://cocoapod-badges.herokuapp.com/v/DTTableViewManager/badge.png) &nbsp;
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Packagist](https://img.shields.io/packagist/l/doctrine/orm.svg)]()

DTTableViewManager 5
================
> This is a sister-project for [DTCollectionViewManager](https://github.com/DenHeadless/DTCollectionViewManager) - great tool for UICollectionView management, built on the same principles.

Powerful generic-based UITableView management framework, written in Swift 3.

- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Quick start](#quick-start)
- [Usage](#usage)
    - **Intro -** [Mapping and Registration](#mapping-and-registration), [Data Models](#data-models)
    - **Storage classes -** [Memory Storage](#memorystorage), [CoreDataStorage](#coredatastorage), [RealmStorage](#realmstorage)
    - **Reacting to events -** [Event types](#event-types), [Events list](#events-list)
- [Advanced Usage](#advanced-usage)
	- [Reacting to content updates](#reacting-to-content-updates)
	- [Customizing UITableView updates](#customizing-uitableview-updates)
	- [Display header on empty section](#display-header-on-empty-section)
  - [Customizing mapping resolution](#customizing-mapping-resolution)
  - [Unregistering mappings](#unregistering-mappings)
  - [Error reporting](#error-reporting)
- [ObjectiveC support](#objectivec-support)
- [Documentation](#documentation)
- [Running example project](#running-example-project)
- [Thanks](#thanks)

## Features

- [x] Powerful mapping system between data models and cells, headers and footers
- [x] Support for all Swift types - classes, structs, enums, tuples
- [x] Support for protocols and subclasses as data models
- [x] Powerful events system, that covers most of UITableView delegate methods
- [x] Views created from code, XIB, or storyboard
- [x] Flexible Memory/CoreData/Realm.io storage options
- [x] Automatic datasource and interface synchronization.
- [x] Automatic XIB registration and dequeue
- [x] No type casts required
- [x] No need to subclass
- [x] Can be used with UITableViewController, or UIViewController with UITableView, or any other class, that contains UITableView

## Requirements

* Xcode 8 and higher
* iOS 8.0 and higher / tvOS 9.0 and higher
* Swift 3

## Installation

[CocoaPods](http://www.cocoapods.org):

    pod 'DTTableViewManager', '~> 5.1'

[Carthage](https://github.com/Carthage/Carthage):

    github "DenHeadless/DTTableViewManager" ~> 5.1.0

After running `carthage update` drop DTTableViewManager.framework and DTModelStorage.framework to Xcode project embedded binaries.

## Quick start

`DTTableViewManager` framework has two parts - core framework, and storage classes. Import them both to your view controller class to start:

```swift
import DTTableViewManager
import DTModelStorage
```

The core object of a framework is `DTTableViewManager`. Declare your class as `DTTableViewManageable`, and it will be automatically injected with `manager` property, that will hold an instance of `DTTableViewManager`.

Make sure your UITableView outlet is wired to your class and call in viewDidLoad:

```swift
	manager.startManaging(withDelegate:self)
```

Let's say you have an array of Posts you want to display in UITableView. To quickly show them using DTTableViewManager, here's what you need to do:

* Create UITableViewCell subclass, let's say PostCell. Adopt ModelTransfer protocol

```swift
class PostCell : UITableViewCell, ModelTransfer {
	func update(with model: Post) {
		// Fill your cell with actual data
	}
}
```

* Call registration methods on your `DTTableViewManageable` instance

```swift
	manager.register(PostCell.self)
```

ModelType will be automatically gathered from your `PostCell`. If you have a PostCell.xib file, it will be automatically registered for PostCell. If you have a storyboard with PostCell, set it's reuseIdentifier to be identical to class - "PostCell".

* Add your posts!

```swift
	manager.memoryStorage.addItems(posts)
```

That's it! It's that easy!

## Usage

### Mapping and registration

* `register(_:)`
* `registerNibNamed(_:for:)`
* `registerHeader(_:)`
* `registerNibNamed(_:forHeader:)`
* `registerFooter(_:)`
* `registerNibNamed(_:forFooter:)`
* `registerNiblessHeader(_:)`
* `registerNiblessFooter(_:)`

By default, `DTTableViewManager` uses section titles and `tableView(_:titleForHeaderInSection:)` UITableViewDatasource methods. However, if you call any mapping methods for headers or footers, it will automatically switch to using `tableView(_:viewForHeaderInSection:)` methods and dequeue `UITableViewHeaderFooterView` instances. Make your `UITableViewHeaderFooterView` subclasses conform to `ModelTransfer` protocol to allow them participate in mapping.

You can also use UIView subclasses for headers and footers.

### Data models

`DTTableViewManager` supports all Swift and Objective-C types as data models. This also includes protocols and subclasses.

```swift
protocol Food {}
class Apple : Food {}
class Carrot: Food {}

class FoodTableViewCell : UITableViewCell, ModelTransfer {
    func update(with model: Food) {
        // Display food in a cell
    }
}
manager.register(FoodTableViewCell.self)
manager.memoryStorage.addItems([Apple(),Carrot()])
```

Mappings are resolved simply by calling `is` type-check. In our example Apple is Food and Carrot is Food, so mapping will work.

## Storage classes

[DTModelStorage](https://github.com/DenHeadless/DTModelStorage/) is a framework, that provides storage classes for `DTTableViewManager`. By default, storage property on `DTTableViewManager` holds a `MemoryStorage` instance.

### MemoryStorage

`MemoryStorage` is a class, that manages UITableView models in memory. It has methods for adding, removing, replacing, reordering table view models etc. You can read all about them in [DTModelStorage repo](https://github.com/DenHeadless/DTModelStorage#memorystorage). Basically, every section in `MemoryStorage` is an array of `SectionModel` objects, which itself is an object, that contains optional header and footer models, and array of table items.

### CoreDataStorage

`CoreDataStorage` is meant to be used with `NSFetchedResultsController`. It automatically monitors all NSFetchedResultsControllerDelegate methods and updates UI accordingly to it's changes. All you need to do to display CoreData models in your UITableView, is create CoreDataStorage object and set it on your `storage` property of `DTTableViewManager`.

It also recommended to use built-in CoreData updater to properly update UITableView:

```swift
manager.tableViewUpdater = manager.coreDataUpdater()
```

Standard flow for creating `CoreDataStorage` can be something like this:

```swift
let request = NSFetchRequest<Post>()
request.entity = NSEntityDescription.entity(forEntityName: String(Post.self), in: context)
request.fetchBatchSize = 20
request.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
let fetchResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
_ = try? fetchResultsController.performFetch()

manager.storage = CoreDataStorage(fetchedResultsController: fetchResultsController)
```

Keep in mind, that MemoryStorage is not limited to objects in memory. For example, if you have CoreData database, and you now for sure, that number of items is not big, you can choose not to use CoreDataStorage and NSFetchedResultsController. You can fetch all required models, and store them in MemoryStorage.

### RealmStorage

`RealmStorage` is a class, that is meant to be used with [realm.io](https://realm.io) databases. To use `RealmStorage` with `DTTableViewManager`, add following line to your Podfile:

```ruby
    pod 'DTModelStorage/Realm'
```

If you are using Carthage, `RealmStorage` will be automatically built along with `DTModelStorage`.


## Reacting to events

Event system in DTTableViewManager 5 allows you to react to `UITableViewDelegate` and `UITableViewDataSource` events based on view and model types, completely bypassing any switches or ifs when working with UITableView API. For example:

```swift
manager.didSelect(PostCell.self) { cell,model,indexPath in
  print("Selected PostCell with \(model) at \(indexPath)")
}
```

**Important**

All events with closures are stored on `DTTableViewManager` instance, so be sure to declare [weak self] in capture lists to prevent retain cycles.

### Event types

There are two types of events:

1. Event where we have underlying view at runtime
1. Event where we have only data model, because view has not been created yet.

In the first case, we are able to check view and model types, and pass them into closure. In the second case, however, if there's no view, we can't make any guarantees of which type it will be, therefore it loses view generic type and is not passed to closure. These two types of events have different signature, for example:

```swift
// Signature for didSelect event
// We do have a cell, when UITableView calls "tableView(_:didSelectRowAt:)" method
open func didSelect<T:ModelTransfer>(_ cellClass:  T.Type, _ closure: @escaping (T,T.ModelType, IndexPath) -> Void) where T:UITableViewCell


// Signature for heightForCell event
// When UITableView calls "tableView(_:heightForRowAt:)" method, cell is not created yet, so closure contains two arguments instead of three, and there are no guarantees made about cell type, only model type
open func heightForCell<T>(withItem itemType: T.Type, _ closure: @escaping (T, IndexPath) -> CGFloat)
```

It's also important to understand, that event system is implemented using `responds(to:)` method override and is working on the following rules:

* If `DTTableViewManageable` is implementing delegate method, `responds(to:)` returns true
* If `DTTableViewManager` has events tied to selector being called, `responds(to:)` also returns true

What this approach allows us to do, is configuring UITableView knowledge about what delegate method is implemented and what is not. For example, `DTTableViewManager` is implementing `tableView(_:heightForRowAt:)` method, however if you don't call `heightForCell(withItem:_:)` method, you are safe to use self-sizing cells in UITableView. While **37** delegate methods are implemented, only those that have events or are implemented by delegate will be called by `UITableView`.

`DTTableViewManager` has the same approach for handling each delegate and datasource method:

* Try to execute event, if cell and model type satisfy requirements
* Try to call delegate or datasource method on `DTTableViewManageable` instance
* If two previous scenarios fail, fallback to whatever default `UITableView` has for this delegate or datasource method

### Events list

Here's full list of all delegate and datasource methods implemented:

**UITableViewDataSource**

| DataSource method | Event method | Comment |
| ----------------- | ------------ | ------- |
|  cellForItemAt: | configure(_:_:) | Called after `update(with:)` method was called |
|  viewForHeaderInSection: | configureHeader(_:_:) | Called after `update(with:)` method was called |
|  viewForFooterInSection: | configureFooter(_:_:) | Called after `update(with:)` method was called |
|  commit:forRowAt: | commitEditingStyle(for:_:) | - |
|  canEditRowAt: | canEditCell(withItem:_:) | - |
|  canMoveRowAt: | canMove(_:_:) | - |

**UITableViewDelegate**

| Delegate method | Event method | Comment |
| ----------------- | ------------ | ------ |
|  heightForRowAt: | heightForCell(withItem:_:) | - |
|  estimatedHeightForRowAt: | estimatedHeightForCell(withItem:_:) | - |
|  indentationLevelForRowAt: | indentationLevelForCell(withItem:_:) | - |
|  willDisplay:forRowAt: | willDisplay(_:_:) | - |
|  editActionsForRowAt: | editActions(for:_:) | iOS only |
|  accessoryButtonTappedForRowAt: | accessoryButtonTapped(in:_:) | - |
|  willSelectRowAt: | willSelect(_:_:) | - |
|  didSelectRowAt: | didSelect(_:_:) | - |
|  willDeselectRowAt: | willDeselect(_:_:) | - |
|  didDeselectRowAt: | didDeselect(_:_:) | - |
|  willSelectRowAt: | willSelect(_:_:) | - |
|  heightForHeaderInSection: | heightForHeader(withItem:_:) | - |
|  heightForFooterInSection: | heightForFooter(withItem:_:) | - |
|  estimatedHeightForHeaderInSection: | estimatedHeightForHeader(withItem:_:) | - |
|  estimatedHeightForFooterInSection: | estimatedHeightForFooter(withItem:_:) | - |
|  heightForHeaderInSection: | heightForHeader(withItem:_:) | - |
|  willDisplayHeaderView:forSection: | willDisplayHeaderView(_:_:) | - |
|  willDisplayFooterView:forSection: | willDisplayFooterView(_:_:) | - |
|  willBeginEditingRowAt: | willBeginEditing(_:_:) | iOS only |
|  didEndEditingRowAt: | didEndEditing(_:_:) | iOS only |
|  editingStyleForRowAt: | editingStyle(for:_:) | - |
|  titleForDeleteConfirmationButtonForRowAt: | titleForDeleteConfirmationButton(in:_:) | iOS only |
|  shouldIndentWhileEditingRowAt: | shouldIndentWhileEditing(_:_:) | - |
|  didEndDisplaying:forRowAt: | didEndDisplaying(_:_:) | - |
|  didEndDisplayingHeaderView:forSection: | didEndDisplayingHeaderView(_:_:) | - |
|  didEndDisplayingFooterView:forSection: | didEndDisplayingFooterView(_:_:) | - |
|  shouldShowMenuForRowAt: | shouldShowMenu(for:_:) | - |
|  canPerformAction:forRowAt:withSender: | canPerformAction(for:_:) | - |
|  performAction:forRowAt:withSender: | performAction(for:_:) | - |
|  shouldHighlightRowAt: | shouldHighlight(_:_:) | - |
|  didHighlightRowAt: | didHighlight(_:_:) | - |
|  didUnhighlightRowAt: | didUnhighlight(_:_:) | - |
|  canFocusRowAt: | canFocus(_:_:) | iOS/tvOS 9.0+ |

## Advanced usage

### Reacting to content updates

Sometimes it's convenient to know, when data is updated, for example to hide UITableView, if there's no data. `TableViewUpdater` has `willUpdateContent` and `didUpdateContent` properties, that can help:

```swift
updater.willUpdateContent = { update in
  print("UI update is about to begin")
}

updater.didUpdateContent = { update in
  print("UI update finished")
}
```

### Customizing UITableView updates

`DTTableViewManager` uses `TableViewUpdater` class by default. However for `CoreData` you might want to tweak UI updating code. For example, when reloading cell, you might want animation to occur, or you might want to silently update your cell. This is actually how [Apple's guide](https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/CoreData/nsfetchedresultscontroller.html) for `NSFetchedResultsController` suggests you should do. Another interesting thing it suggests that .Move event reported by NSFetchedResultsController should be animated not as a move, but as deletion of old index path and insertion of new one.

If you want to work with CoreData and NSFetchedResultsController, just call:

```swift
manager.tableViewUpdater = manager.coreDataUpdater()
```

`TableViewUpdater` constructor allows customizing it's basic behaviour:

```swift
let updater = TableViewUpdater(tableView: tableView, reloadRow: { indexPath in
  // Reload row
}, animateMoveAsDeleteAndInsert: false)
```

These are all default options, however you might implement your own implementation of `TableViewUpdater`, the only requirement is that object needs to conform to `StorageUpdating` protocol. This gives you full control on how and when `DTTableViewManager` will update `UITableView`.

`TableViewUpdater` also contains all animation options, that can be changed, for example:

```swift
updater.deleteSectionAnimation = UITableViewRowAnimation.fade
updater.insertRowAnimation = UITableViewRowAnimation.automatic
```

### Display header on empty section

By default, headers are displayed if there's header model for them in section, even if there are no items in section. This behaviour can be changed:

```swift
manager.configuration.displayHeaderOnEmptySection = false
// or
manager.configuration.displayFooterOnEmptySection = false
```

Also you can use simple String models for header and footer models, without any registration, and they will be used in `tableView(_:titleForHeaderInSection:)` method automatically.

### Customizing mapping resolution

There can be cases, where you might want to customize mappings based on some criteria. For example, you might want to display model in several kinds of cells:

```swift
class FoodTextCell: UITableViewCell, ModelTransfer {
    func update(with model: Food) {
        // Text representation
    }
}

class FoodImageCell: UITableViewCell, ModelTransfer {
    func update(with model: Food) {
        // Photo representation
    }
}

manager.register(FoodTextCell.self)
manager.register(FoodImageCell.self)
```

If you don't do anything, FoodTextCell mapping will be selected as first mapping, however you can adopt `ViewModelMappingCustomizing` protocol to adjust your mappings:

```swift
extension PostViewController : ViewModelMappingCustomizing {
    func viewModelMapping(fromCandidates candidates: [ViewModelMapping], forModel model: Any) -> ViewModelMapping? {
        if let foodModel = model as? Food where foodModel.hasPhoto {
            return candidates.last
        }
        return candidates.first
    }
}
```

### Unregistering mappings

You can unregister cells, headers and footers from `DTTableViewManager` and `UITableView` by calling:

```swift
manager.unregister(FooCell.self)
manager.unregisterHeader(HeaderView.self)
manager.unregisterFooter(FooterView.self)
```

This is equivalent to calling `tableView(register:nil,forCellWithReuseIdenfier: "FooCell")`

### Error reporting

In some cases `DTTableViewManager` will not be able to create cell, header or footer view. This can happen when passed model is nil, or mapping is not set. By default, 'fatalError' method will be called and application will crash. You can improve crash logs by setting your own error handler via closure:

```swift
manager.viewFactoryErrorHandler = { error in
    // DTTableViewFactoryError type
    print(error.description)
}
```

## ObjectiveC support

`DTTableViewManager` is heavily relying on Swift protocol extensions, generics and associated types. Enabling this stuff to work on Objective-c right now is not possible. Because of this DTTableViewManager 4 and greater only supports building from Swift. If you need to use Objective-C, you can use [latest Objective-C compatible version of `DTTableViewManager`](https://github.com/DenHeadless/DTTableViewManager/releases/tag/3.3.0).

## Documentation

You can view documentation online or you can install it locally using [cocoadocs](http://cocoadocs.org/docsets/DTTableViewManager)!

## Running example project

```bash
pod try DTTableViewManager
```

## Thanks

* [Alexey Belkevich](https://github.com/belkevich) for providing initial implementation of CellFactory.
* [Michael Fey](https://github.com/MrRooni) for providing insight into NSFetchedResultsController updates done right.
* [Nickolay Sheika](https://github.com/hawk-ukr) for great feedback, that helped shaping 3.0 release.
* [Artem Antihevich](https://github.com/sinarionn) for great discussions about Swift generics and type capturing.
