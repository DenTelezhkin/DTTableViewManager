# DTTableViewManager 5.0 Migration Guide

DTTableViewManager 5.0 is the latest major release of UITableView helper library for iOS and tvOS written in Swift 3. As a major release, following [Semantic Versioning conventions](https://semver.org), 5.0 introduces API-breaking changes.

This guide is provided in order to ease the transition of existing applications using DTTableViewManager 4.x to the latest APIs, as well as explain the design and structure of new and updated functionality.

- [Requirements](#requirements)
- [Benefits of Upgrading](#benefits-of-upgrading)
- [Breaking API Changes](#breaking-api-changes)
	- [Known migrator issues](#known-migrator-issues)
	- [Event system removals](#event-system-removals)
	- [Removed API](#removed-api)
- [New Features](#new-features)
	- [Events System](#events-system)
	- [Table View Updater](#table-view-updater)
  - [Unregister methods](#unregister-methods)
- [Updated Features](#updated-features)
  - [Supplementary Model Handling](#supplementary-model-handling)
  - [New Error Handling Model](#new-error-handling-model)
  - [Miscellaneous API additions](#miscellaneous-api-additions)

## Requirements

- iOS 8.0+ / tvOS 9.0+
- Xcode 8.0+
- Swift 3.0+

For those of you that would like to use DTTableViewManager with Swift 2.3 or Swift 2.2, please use the latest tagged 4.x release.

## Benefits of Upgrading

- **Complete Swift 3 Compatibility:** includes the full adoption of the new [API Design Guidelines](https://swift.org/documentation/api-design-guidelines/).
- **New Events System** introduces support for almost all `UITableViewDelegate` methods using closure-based API and generics.
- **New Table View Updater** opens up API to customize UITableView updates.
- **New unregister methods** allow unregistering classes from `DTTableViewManager` and `UITableView`.
- **Improvements to supplementary models** allow working with supplementary views whose position is defined by IndexPath in UICollectionView.
- **Improved Error System:** uses a new `MemoryStorageError` type to adhere to the new pattern proposed in [SE-0112](https://github.com/apple/swift-evolution/blob/master/proposals/0112-nserror-bridging.md).

---

## Breaking API Changes

DTTableViewManager 5 has fully adopted all the new Swift 3 changes and conventions, including the new [API Design Guidelines](https://swift.org/documentation/api-design-guidelines/). Because of this, almost every API in DTTableViewManager has been modified in some way. When migrating to new release, remember to run Xcode Swift migrator, as lot of API have been annotated to automatically migrate to new syntax. There are however some cases, that Swift migrator is missing.

### Known migrator issues

`ModelTransfer` protocol syntax was updated to new design guidelines, however due to present associatedtype Swift migrator is missing all implementations of this protocol. As a workaround, you will need to rename methods manually:

```swift
// DTTableViewManager 4.x
class FooCell : UITableViewCell, ModelTransfer {
  func updateWithModel(model: Foo) {

  }
}

// DTTableViewManager 5.x
class FooCell : UITableViewCell, ModelTransfer {
  func update(with model: Foo) {

  }
}
```

`DTViewModelMappingCustomizable` protocol has been renamed to `ViewModelMappingCustomizing` and it's signature was changed:

```swift
// DTTableViewManager 4.x
func viewModelMappingFromCandidates(_ candidates: [ViewModelMapping], forModel model: Any) -> ViewModelMapping? {
   return ...
}

// DTTableViewManager 5.0
func viewModelMapping(fromCandidates candidates: [ViewModelMapping], forModel model: Any) -> ViewModelMapping? {
  return ...
}
```

### Event system removals

DTTableViewManager 4.x had rudimentary support for event handling in two forms - closure-based and method-pointer based, both supporting only 5 events(cell selection, cell, header and footer configuration, willDisplay cell). Goal of DTTableViewManager 5 was to support much more events in much more robust way. Because of that implementation needed to be reworked, and only one system needed to be kept to avoid maintainance burden and confusion when using API.

Closure-based system turned out to clearly be more powerful and logical, therefore all method-pointer based events have been removed. To find out more about new events system, refer to [new events system](#events-system) section.

Old closure-based events work the same way as before. The only change that was made is renaming of `whenSelected` method to better clarify it's behavior:

```swift
// DTTableViewManager 4.x
manager.whenSelected(FooCell.self) { cell, model, indexPath in }

// DTTableViewManager 5.x
manager.didSelect(FooCell.self) { cell, model, indexPath in }
```

#### Removed API

* Generic methods like `itemForCellClass:atIndexPath:` - they did not provide enough value to be present in a framework.
* `viewBundle` property on `DTTableViewManager` - bundle is now determined automatically
* `dataBindingBehaviour` property. It's usage can be replaced by implementing of the new events.
* `DTTableViewContentUpdatable` protocol - use `TableViewUpdater` `willUpdateContent` and `didUpdateContent` properties.

---

## New Features

### Events system

Events system was completely rewritten from scratch, and has support for **37** `UITableViewDelegate` and `UITableViewDataSource` methods. The way you use any of the events is really straightforward, for example here's how you can react to cell deselection:

```swift
manager.didDeselect(FooCell.self) { cell, model, indexPath in
  print("did deselect FooCell at \(indexPath), model: \(model)")
}
```

There are two types of events:

1. Event where we have underlying view at runtime
1. Event where we have only data model, because view has not been created yet.

In the first case, we are able to check view and model types, and pass them into closure. In the second case, however, if there's no view, we can't make any guarantees of which type it will be, therefore it loses view generic type and is not passed to closure. These two types of events have different signature, for example:

```swift
// Signature for didSelect event
// We do have a cell, when UITableView calls `tableView(_:didSelectRowAt:)` method
open func didSelect<T:ModelTransfer>(_ cellClass:  T.Type, _ closure: @escaping (T,T.ModelType, IndexPath) -> Void) where T:UITableViewCell


// Signature for heightForCell event
// When UITableView calls `tableView(_:heightForRowAt:)` method, cell is not created yet, so closure contains two arguments instead of three, and there are no guarantees made about cell type, only model type
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

Here's full list of all delegate and datasource methods implemented:

**UITableViewDataSource**

| DataSource method | Event method | Comment |
| ----------------- | ------------ | ------- |
|  cellForRowAt: | configure(_:_:) | Called after `update(with:)` method was called |
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

### Table View Updater

`DTTableViewManager` makes sure, that UI is always updated to state, representing storage. In 4.x release however, there was no way to customize how UI was updated. For example, when reloading cell, you might want animation to occur, or you might want to silently update your cell. This is actually how [Apple's guide](https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/CoreData/nsfetchedresultscontroller.html) for `NSFetchedResultsController` suggests you should do. Another interesting thing it suggests that .Move event reported by NSFetchedResultsController should be animated not as a move, but as deletion of old index path and insertion of new one.

In 4.x release `DTTableViewManager` itself served as table view updater, implementing `StorageUpdating` protocol. 5.0 release introduces new property - `tableViewUpdater`, that holds table view updater object. All previous logic was extracted to separate `TableViewUpdater` class.

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

All animation options from `TableViewConfiguration` class along with `DTTableViewContentUpdatable` protocol methods have been moved to `TableViewUpdater`:

```swift
updater.insertRowAnimation = UITableViewRowAnimation.automatic

updater.willUpdateContent = { update in
  // prepare for updating
}
updater.didUpdateContent = { update in
  // update finished
}
```

These are all default options, however you might implement your own implementation of `TableViewUpdater`, the only requirement is that object needs to conform to `StorageUpdating` protocol. This gives you full control on how and when `DTTableViewManager` will update `UITableView`.

### Unregister methods

DTTableViewManager 5 introduces unregister methods, that allow unregistering from both `DTTableViewManager` and `UITableView`:

```swift
manager.unregister(FooCell.self)
manager.unregisterHeader(HeaderView.self)
manager.unregisterFooter(FooterView.self)
```

---

## Updated Features

DTTableViewManager 5 contains many enhancements on existing features. This section is designed to give a brief overview of the features and demonstrate their uses.

#### Supplementary model handling

In DTTableViewManager 4, supplementaries storage allowed only storing headers and footers, model that is sufficient for UITableView and UICollectionView with UICollectionViewFlowLayout, however insufficient, if you want to use UICollectionView with richer UICollectionViewLayout. Therefore underlying storage and methods for supplementary models has been changed to allow more supplementary view types in section.

```swift
// DTTableViewManager 4.x
let model = SectionModel()
model.setSupplementaryModel(1, forKind: "Kind")
model.supplementaryModelForKind("Kind") // 1

// DTTableViewManager 5.x
let model = SectionModel()
model.setSupplementaryModel(1, forKind: "Kind", atIndex: 0)
model.supplementaryModel(ofKind: "Kind", atIndex: 0) // 1
```

#### New Error handling model

DTTableViewManager 5 migrates to new error system, proposed in [SE-0112](https://github.com/apple/swift-evolution/blob/master/proposals/0112-nserror-bridging.md).

It makes much more easy to understand what error happened and how you should handle it.

For example:

```swift
do { try manager.memoryStorage.insertItem("Foo", at: NSIndexPath(item:0,section:0))}
catch let error as MemoryStorageError {
  print(error.localizedDescription)
}
```

#### Miscellaneous API Additions

* `DTTableViewOptionalManageable` now mirrors `DTTableViewManageable` functionality, but allows using optional `tableView` property.
* `SectionModel` and `RealmSection` objects now have `currentSectionIndex` property
* `DTTableViewManager` how has `isManagingTableView` Bool property
* `MemoryStorage` now has `removeItems(fromSection:)` method
* `DTTableViewManager` now has `updateCellClosure` that allows silently updating with model row at specific index path.
