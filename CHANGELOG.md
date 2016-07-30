# Change Log

All notable changes to this project will be documented in this file.

## Master

### Added

* `isManagingTableView` property on `DTTableViewManager`

### Changed

* Event system is migrated to new `EventReaction` class from `DTModelStorage`
* Now all view registration methods use `NSBundle(forClass:)` constructor, instead of falling back on `DTTableViewManager` `viewBundle` property. This allows having cells from separate bundles or frameworks to be used with single `DTTableViewManager` instance.

### Removals

* `registerCellClass:whenSelected` method 
* All events methods with method pointer semantics. Please use block based methods instead.
* `dataBindingBehaviour` property. 
* `viewBundle` property on `DTTableViewManager`. Bundle is not determined automatically based on view class.

## [4.7.0](https://github.com/DenHeadless/DTTableViewManager/releases/tag/4.7.0)

Dependency changelog -> [DTModelStorage 2.6.0 and higher](https://github.com/DenHeadless/DTModelStorage/releases)

## [4.6.0](https://github.com/DenHeadless/DTTableViewManager/releases/tag/4.6.0)

Dependency changelog -> [DTModelStorage 2.5 and higher](https://github.com/DenHeadless/DTModelStorage/releases)

### Breaking

* Update to Swift 2.2. This release is not backwards compatible with Swift 2.1.

### Changed

* Require Only-App-Extension-Safe API is set to YES in framework targets.

## [4.5.3](https://github.com/DenHeadless/DTTableViewManager/releases/tag/4.5.0)

## Fixed

* Fixed a bug, where prototype cell from storyboard could not be created after calling `registerCellClass(_:)` method.

## [4.5.0](https://github.com/DenHeadless/DTTableViewManager/releases/tag/4.5.0)

## Added

* Support for Realm database storage - using `RealmStorage` class.
* Ability to defer data binding until `tableView(_:willDisplayCell:forRowAtIndexPath:)` method is called. This can improve  scrolling perfomance for table view cells.
```swift
    manager.dataBindingBehaviour = .BeforeCellIsDisplayed
```

## Changed

* UIReactions now properly unwrap data models, even for cases when model contains double optional value.

## [4.4.1](https://github.com/DenHeadless/DTTableViewManager/releases/tag/4.4.1)

## Fixed

* Issue with Swift 2.1.1 (XCode 7.2) where storage.delegate was not set during initialization

## [4.4.0](https://github.com/DenHeadless/DTTableViewManager/releases/tag/4.4.0)

Dependency changelog -> [DTModelStorage 2.3 and higher](https://github.com/DenHeadless/DTModelStorage/releases)

This release aims to improve mapping system and error reporting.

## Added

* [New mapping system](https://github.com/DenHeadless/DTTableViewManager#data-models) with support for protocols and subclasses
* Mappings can now be [customized](https://github.com/DenHeadless/DTTableViewManager#customizing-mapping-resolution) using `DTViewModelMappingCustomizable` protocol.
* [Custom error handler](https://github.com/DenHeadless/DTTableViewManager#error-reporting) for `DTTableViewFactoryError` errors.

## Changed

* preconditionFailures have been replaced with `DTTableViewFactoryError` ErrorType
* Internal `TableViewReaction` class have been replaced by `UIReaction` class from DTModelStorage.

## [4.3.0](https://github.com/DenHeadless/DTTableViewManager/releases/tag/4.3.0)

Dependency changelog -> [DTModelStorage 2.2 and higher](https://github.com/DenHeadless/DTModelStorage/releases)

## Changed

* Added support for Apple TV platform (tvOS).

## Fixed

* `registerNiblessFooterClass` method now works correctly.

## Renamed

* `objectForCellClass` category of methods have been removed to read item in their title instead of object.

## Removed

* `TableViewStorageUpdating` protocol and conformance has been removed as unnecessary.

## [4.2.1](https://github.com/DenHeadless/DTTableViewManager/releases/tag/4.2.1)

## Updated

* Improved stability by treating UITableView as optional

## [4.2.0](https://github.com/DenHeadless/DTTableViewManager/releases/tag/4.2.0)

Dependency changelog -> [DTModelStorage 2.1 and higher](https://github.com/DenHeadless/DTModelStorage/releases)

This release aims to improve storage updates and UI animation with UITableView. To make this happen, `DTModelStorage` classes were rewritten and rearchitectured, using Swift `Set`.

There are some backwards-incompatible changes in this release, however Xcode quick-fix tips should guide you through what needs to be changed.

## Added

 * `registerNiblessHeaderClass` and `registerNiblessFooterClass` methods to  support creating `UITableViewHeaderFooterView`s from code

## Fixed

* Fixed retain cycles in event blocks

## [4.1.0](https://github.com/DenHeadless/DTTableViewManager/releases/tag/4.1.0)

## Features

New events registration system with method pointers, that automatically breaks retain cycles.

For example, cell selection:

```swift
manager.cellSelection(PostsViewController.selectedCell)

func selectedCell(cell: PostCell, post: Post, indexPath: NSIndexPath) {
    // Do something, push controller probably?
}
```

Alternatively, you can use dynamicType to register method pointer:

```swift
manager.cellSelection(self.dynamicType.selectedCell)
```

Other available events:
* cellConfiguration
* headerConfiguration
* footerConfiguration

## Breaking changes

`beforeContentUpdate` and `afterContentUpdate` closures were replaced with `DTTableViewContentUpdatable` protocol, that can be adopted by your `DTTableViewManageable` class, for example:

```swift
extension PostsViewController: DTTableViewContentUpdatable {
    func afterContentUpdate() {
        // Do something
    }
}
```

## [4.0.0](https://github.com/DenHeadless/DTTableViewManager/releases/tag/4.0.0)

4.0 is a next major release of `DTTableViewManager`. It was rewritten from scratch in Swift 2 and is not backwards-compatible with previous releases.

Read  [4.0 Migration guide](https://github.com/DenHeadless/DTTableViewManager/wiki/4.0-Migration-guide).

[Blog post](http://digginginswift.com/2015/09/13/dttableviewmanager-4-protocol-oriented-uitableview-management-in-swift/)

### Features

* Improved `ModelTransfer` protocol with associated `ModelType`
* `DTTableViewManager` is now a separate object
* New events system, that allows reacting to cell selection, cell/header/footer configuration and content updates
* Added support for `UITableViewController`, and any other object, that has `UITableView`
* New storage object generic-type getters
* Support for Swift types - classes, structs, enums, tuples.

## [3.2.0](https://github.com/DenHeadless/DTTableViewManager/releases/tag/3.2.0)

### Bugfixes

* Fixed an issue, where storageDidPerformUpdate method could be called without any updates.

## [3.1.1](https://github.com/DenHeadless/DTTableViewManager/releases/tag/3.1.1)

* Added support for installation using [Carthage](https://github.com/Carthage/Carthage) :beers:

## [3.1.0](https://github.com/DenHeadless/DTTableViewManager/releases/tag/3.1.0)

### Changes

* Added nullability annotations for XCode 6.3 and Swift 1.2


## [3.0.5](https://github.com/DenHeadless/DTTableViewManager/releases/tag/3.0.5)

## Features

Added removeAllTableItemsAnimated method.

## Bugfixes

Fixed issue, that could lead to wrong table items being removed, when using memory storage  removeItemsAtIndexPaths: method.

## [3.0.2](https://github.com/DenHeadless/DTTableViewManager/releases/tag/3.0.2)

### Changes

* Supported frameworks installation from CocoaPods - requires iOS 8.

## [3.0.0](https://github.com/DenHeadless/DTTableViewManager/releases/tag/3.0.0)

### Features
* Full Swift support, including swift model classes
* Added convenience method to update section items
* Added `DTTableViewControllerEvents` protocol, that allows developer to react to changes in datasource
* Registering header or footer view now automatically changes default header/footer style to DTTableViewSectionStyleView.

### Breaking changes

* `DTSectionModel` methods `headerModel` and `footerModel` were renamed. Use `tableHeaderModel` and `tableFooterModel` instead.
* `DTStorage` protocol was renamed to `DTStorageProtocol`.
* `DTTableViewDataStorage` class was removed, it's methods were merged in `DTMemoryStorage`
* `DTDefaultCellModel` and `DTDefaultHeaderFooterModel` were removed.

## [2.7.0](https://github.com/DenHeadless/DTTableViewManager/releases/tag/2.7.0)

This is a release, that is targeted at improving code readability, and reducing number of classes and protocols inside DTTableViewManager architecture.

### Breaking changes

* `DTTableViewMemoryStorage` class was removed. It's methods were transferred to `DTMemoryStorage+DTTableViewManagerAdditions` category.
* `DTTableViewStorageUpdating` protocol was removed. It's methods were moved to `DTTableViewController`.

### Features

* When using `DTCoreDataStorage`, section titles are displayed by default, if NSFetchedController was created with sectionNameKeyPath property.

## [2.5.0](https://github.com/DenHeadless/DTTableViewManager/releases/tag/2.5.0)

### Changes

Preliminary support for Swift.

If you use cells, headers or footers inside storyboards from Swift, implement optional reuseIdentifier method to return real Swift class name instead of the mangled one. This name should also be set as reuseIdentifier in storyboard.

## [2.4.0](https://github.com/DenHeadless/DTTableViewManager/releases/tag/2.4.0)

### Breaking changes

Reuse identifier now needs to be identical to cell, header or footer class names. For example, UserTableCell should now have "UserTableCell" reuse identifier.

## [2.3.0](https://github.com/DenHeadless/DTTableViewManager/releases/tag/2.3.0)

#### Features

Added properties of `DTTableViewController` to control, whether section headers and footers should be shown for sections, that don't contain any items.

#### Deprecations

Removed `DTModelSearching` protocol, please use `DTMemoryStorage` `setSearchingBlock:forModelClass:` method instead.

## [2.2.0](https://github.com/DenHeadless/DTTableViewManager/releases/tag/2.2.0)

* `DTModelSearching` protocol is deprecated and is replaced by memoryStorage method setSearchingBlock:forModelClass:
* UITableViewDelegate and UITableViewDatasource properties for UITableView are now filled automatically.
* Added more assertions, programmer errors should be easily captured.

## [2.1.0](https://github.com/DenHeadless/DTTableViewManager/releases/tag/2.1.0)

#### Breaking changes

Storage classes now use external dependency from [DTModelStorage repo](https://github.com/DenHeadless/DTModelStorage).

Some method calls on memory storage have been renamed, dropping 'table' part from the name, for example
```objective-c
-(void)addTableItems:(NSArray *)items
```
now becomes

```objective-c
-(void)addItems:(NSArray *)items
```

Several protocols and classes have been also renamed:

`DTTableViewModelTransfer` - `DTModelTransfer`
`DTTableViewModelSearching` - `DTModelSearching`
`DTTableViewCoreDataStorage` - `DTCoreDataStorage`

#### Features

Added support for default UITableViewCellStyles and default UITableViewHeaderFooterViews without subclassing.

## [2.0.0](https://github.com/DenHeadless/DTTableViewManager/releases/tag/2.0.0)

DTTableViewManager 2.0 is a major update to the framework with several API - breaking changes. Please read [DTTableViewManager 2.0 transition guide for an overview](https://github.com/DenHeadless/DTTableViewManager/wiki/DTTableViewManager-2.0-Transition-Guide).

## [1.3.0](https://github.com/DenHeadless/DTTableViewManager/releases/tag/1.3.0)

#### Features

Added support for storyboard prototype cells.

##### Enhancements

DTTableViewManager renamed to DTTableViewController.

#### Bugfixes

Fixed bug, which prevented using correct height values on custom headers and footers.

## [1.2.1](https://github.com/DenHeadless/DTTableViewManager/releases/tag/1.2.1)

#### Features
Added ability to disable logging

##### Enhancements

Improved structure of mapping code, now mapping and cell creation happens completely in DTCellFactory class.

## [1.2.0](https://github.com/DenHeadless/DTTableViewManager/releases/tag/1.2.0)

#### Features

Introducing support for Foundation data models. Cell, header and footer mapping now supports following classes:
* NSString / NSMutableString
* NSNumber
* NSDictionary / NSMutableDictionary
* NSArray / NSMutableArray

#### Deprecations

* option to not reuse cells is removed. Currently there's no obvious reason to not have cell reuse.

## [1.1.0](https://github.com/DenHeadless/DTTableViewManager/releases/tag/1.1.0)

#### Features
Powerful and easy search within UITableView.

#### General changes
Tests are now running on [Travis-CI](https://travis-ci.org/DenHeadless/DTTableViewManager)

#### Deprecations

Ability to create DTTableViewManager as a separate object was removed. If you need to subclass from different UIViewController, consider using iOS Containment API.
