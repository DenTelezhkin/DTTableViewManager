# Change Log

All notable changes to this project will be documented in this file.

# Next

## [10.0.0](https://github.com/DenTelezhkin/DTTableViewManager/releases/tag/10.0.0)

### Added

* Closure wrappers for iOS 15 `tableView:selectionFollowsFocusForRowAt` method.

### Changed

* To align version numbers between `DTModelStorage`, `DTTableViewManager` and `DTCollectionViewManager`, `DTTableViewManager` will not have 9.x release, instead it's being released as 10.x.

### Removed

* Wrappers for `tableView:willCommitMenuWithAnimator` delegate method, that was only briefly available in Xcode 12, and was removed by Apple in one of Xcode 12 releases.

## [9.0.0-beta.1](https://github.com/DenTelezhkin/DTTableViewManager/releases/tag/9.0.0-beta.1)

### Removed

* `usesLegacyTableViewUpdateMethod` on `TableViewUpdater`
* `configureDiffableDatasource` deprecated method that returned `UITableViewDiffableDataSourceReference`.

### Fixed

* Diffable datasources exceptions in Xcode 13 / iOS 15 with some internal restructuring.
* Swift 5.4 / Xcode 12.5 warnings.

## [8.0.1](https://github.com/DenTelezhkin/DTTableViewManager/releases/tag/8.0.1)

### Added

* Support for DTModelStorage 9.1

## [8.0.0](https://github.com/DenTelezhkin/DTTableViewManager/releases/tag/8.0.0)

## [8.0.0-beta.1](https://github.com/DenTelezhkin/DTTableViewManager/releases/tag/8.0.0-beta.1)

### Added

* Cell and supplementary view events are now available inside mapping closure directly, for example:

```swift
// Previous releases
manager.register(PostCell.self)
manager.didSelect(PostCell.self) { cell, model, indexPath in
    // React to selection
}

// New
manager.register(PostCell.self) { mapping in
    mapping.didSelect { cell, model, indexPath in

    }
}
```
Those events are now tied to `ViewModelMapping` instance, which means, that events, registered this way, will only trigger, if mapping condition of current mapping applies. For example:

```swift
manager.register(PostCell.self) { mapping in
    mapping.condition = .section(0)
    mapping.didSelect { cell, model, indexPath in  
        // This closure will only get called, when user selects cell in the first section
    }
}
manager.register(PostCell.self) { mapping in
    mapping.condition = .section(1)
    mapping.didSelect { cell, model, indexPath in  
        // This closure will only get called, when user selects cell in the second section
    }
}
```

Please note, that headers and footers only support mapping-style event registration, if they inherit from `UITableViewHeaderFooterView`.

* `TableViewConfiguration` `semanticHeaderHeight` and `semanticFooterHeight`, that specify whether `DTTableViewManager` should deploy custom logic in `tableView(_ tableView: UITableView, heightForHeaderInSection section: Int)` and `tableView(_ tableView: UITableView, heightForFooterInSection section: Int)`. This logic includes checking whether header and footer models exist in storage, returning `UITableView.automaticDimension` for sections, whose header and footer models are Strings (for table section titles), as well as returning minimal height for cases where data model is not there(which happens to be different for `UITableView.Style.plain` and `UITableView.Style.grouped`). Those properties default to true, but if you want to use self-sizing table view sections headers or footers, which may improve perfomance, consider turning those off:

```swift
manager.configuration.semanticHeaderHeight = false
manager.configuration.semanticFooterHeight = false
```

Please note, that even when those properties are set to false, corresponding `UITableViewDelegate` methods will still be called in two cases:

1. Your `DTTableViewManageable` instance implements them
2. You register a `heightForHeader(withItem:_:)` or `heightForFooter(withItem:_:)` closures on `DTTableViewManager` instance.

### Breaking

This release requires Swift 5.3. Minimum iOS / tvOS deployment targets are unchanged (iOS 11, tvOS 11).

Some context: this release heavily relies on where clauses on contextually generic declarations, that are only available in Swift 5.3 - [SE-0267](https://github.com/apple/swift-evolution/blob/master/proposals/0267-where-on-contextually-generic.md).

* `ViewModelMapping` is now a generic class, that captures view and model information(ViewModelMapping<T,U>).

### Fixed

* `indentationLevelForCell` closure now correctly returns `Int` instead of `CGFloat`.
* Several event API's have been improved to allow returning nil for methods, that accept nil as a valid value:
`contextMenuConfiguration`, `previewForHighlightingContextMenu`, `previewForDismissingContextMenu`.

### Changed

* Generic placeholders for cell/model/view methods have been improved for better readability.

### Deprecated

* Several cell/header/footer/supplementary view registration methods have been deprecated to unify registration logic. Please use `register(_:mapping:handler:)`, `registerHeader(_:mapping:handler:)`, `registerFooter(_:mapping:handler:)` as a replacements for all of those methods. For more information on those changes, please read [migration guide](Documentation/Migration%20guides/8.0%20Migration%20Guide.md).
* All non-deprecated registration methods now have an additional `handler` closure, that allows to configure cells/headers/footers that are dequeued from UITableView. This is a direct replacement for `configure(_:_:`, `configureHeader(_:_:)`, `configureFooter(_:_:)` , that are all now deprecated. Please note, that handler closure is called before `DTModelTransfer.update(with:)` method.
* `DTTableViewManager.configureEvents(for:_:)`, it's functionality has become unnecessary since mapping closure of cell/header/footer registration now captures both cell and model type information for such events.
* `DTTableViewManager.configureDiffableDataSource(modelProvider:)` for non-hashable data models. Please use configureDiffableDataSource method for models, that are Hashable. From Apple's documentation: `If you’re working in a Swift codebase, always use UITableViewDiffableDataSource instead`.
* `TableViewUpdater.usesLegacyTableViewUpdateMethods` property.

## [7.2.0](https://github.com/DenTelezhkin/DTTableViewManager/releases/tag/7.2.0)

### Changed

* Deployment targets - iOS 11 / tvOS 11.
* Minimum Swift version required: 5.0
* Added support for DTModelStorage/Realm with Realm 5

Please note, that this framework version source is identical to previous version, which supports iOS 8 / tvOS 9 / Swift 4.0 and higher.

## [7.1.0](https://github.com/DenTelezhkin/DTTableViewManager/releases/tag/7.1.0)

### Changed

* It's not longer necessary to import DTModelStorage framework to use it's API's. `import DTTableViewManager` now implicitly exports `DTModelStorage`.

## [7.0.0](https://github.com/DenTelezhkin/DTTableViewManager/releases/tag/7.0.0)

* `willCommitMenuWithAnimator` method has been made unavailable for Xcode 11.2, because `UITableViewDelegate` method it used has been removed from UIKit on Xcode 11.2.

## [7.0.0-beta.2](https://github.com/DenTelezhkin/DTTableViewManager/releases/tag/7.0.0-beta.2)

* Added support for Xcode versions, that are older than Xcode 11.

## [7.0.0-beta.1](https://github.com/DenTelezhkin/DTTableViewManager/releases/tag/7.0.0-beta.1)

**This is a major release with some breaking changes, please read [DTTableViewManager 7.0 Migration Guide](Documentation/Migration%20guides/7.0%20Migration%20Guide.md)**

### Added

* `configureDiffableDataSource(modelProvider:)` method to enable `UITableViewDiffableDataSource` with `DTTableViewManager`.
* Ability for `DTTableViewManageable` to implement `tableView(_:viewForHeaderInSection:)` and `tableView(_:viewForFooterInSection:)` to return view directly without going through storages.
* `minimalHeaderHeightForTableView` and `minimalFooterHeightForTableView` properties for `TableViewConfiguration`, that allows configuring height for section headers and footers that need to be hidden.
* Ability to customize bundle, from which xib files are loaded from by setting `bundle` property on `ViewModelMapping` in `mappingBlock`. As before, `bundle` defaults to `Bundle(for: ViewClass.self)`.
* `DTTableViewManager.supplementaryStorage` getter, that conditionally casts current storage to `SupplementaryStorage` protocol.

New method wrappers for iOS 13 API

* `shouldBeginMultipleSelectionInteraction`
* `didBeginMultipleSelectionInteraction`
* `didEndMultipleSelectionInteraction`
* `contextMenuConfiguration(for:)`
* `previewForHighlightingContextMenu`
* `previewForDismissingContextMenu`
* `willCommitMenuWithAnimator`

### Changed

* If tableView section does not contain any items, and `TableViewConfiguration.display<Header/Footer>OnEmptySection` property is set to false, `DTTableViewManager` no longer asks for header footer height explicitly and returns `TableViewConfiguration.minimal<Header/Footer>HeightForTableView`.
* Anomaly event verification now allows subclasses to prevent false-positives.
* `animateChangesOffScreen` property on `TableViewUpdater` that allows to turn off animated updates for `UITableView` when it is not on screen.

### Removed

* Usage of previously deprecated and now removed from `DTModelStorage` `ViewModelMappingCustomizing` protocol.

### Breaking

DTModelStorage header, footer and supplementary model handling has been largely restructured to be a single closure-based API. Read more about changes in [DTModelStorage changelog](https://github.com/DenTelezhkin/DTModelStorage/blob/master/CHANGELOG.md). As a result of those changes, several breaking changes in DTTableViewManager include:

* `SupplementaryAccessible` extension with `tableHeaderModel` and `tableFooterModel` properties has been removed.
* Because headers/footers are now a closure based API, `setSectionHeaderModels` and `setSectionFooterModels` do not create sections by default, and do not call tableView.reloadData.
* If a storage does not contain any sections, even if `configuration.displayHeaderOnEmptySections` or `configuration.displayFooterOnEmptySections` is set, headers and footers will not be displayed, since there are no sections, which is different from present sections, that contain 0 items. For example, If you need to show a header or footer in empty section using MemoryStorage, you can call `memoryStorage.setItems([Int](), forSectionAt: emptySectionIndex)`, and now with empty section header and footer can be displayed.

Other breaking changes:

* `tableViewUpdater` will contain nil if `DTTableViewManager` is configured to work with `UITableViewDiffableDataSource`.
* `DTTableViewOptionalManageable` protocol was removed and replaced by `optionalTableView` property on `DTTableViewManageable` protocol. One of `tableView`/`optionalTableView` properties must be implemented by `DTTableViewManageable` instance to work with `DTTableViewManager`.

### Deprecated

Following methods have been deprecated due to their delegate methods being deprecated in iOS 13:

* `editActions(for:)`
* `shouldShowMenuForItemAt`
* `canPerformAction`
* `performAction`

## [6.6.0](https://github.com/DenTelezhkin/DTTableViewManager/releases/tag/6.6.0)

* Added support for Swift Package Manager in Xcode 11

## [6.5.0](https://github.com/DenTelezhkin/DTTableViewManager/releases/tag/6.5.0)

### Added

* Convenience constructor for `DTTableViewManager` object: `init(storage:)` that allows to create it's instance without initializing `MemoryStorage`.
* Static variable `defaultStorage` on `DTTableViewManager` that allows to configure which `Storage` class is used by default.
* [Documentation](https://dentelezhkin.github.io/DTTableViewManager)
* Support for Xcode 10.2 and Swift 5

### Removed

* Support for Xcode 9 and Swift 3

## [6.4.0](https://github.com/DenTelezhkin/DTTableViewManager/releases/tag/6.4.0)

Dependency changelog -> [DTModelStorage 7.2.0 and higher](https://github.com/DenTelezhkin/DTModelStorage/releases)

### Added

* Example of auto-diffing capability and animations when using `SingleSectionStorage`.
* Support for Swift 4.2 and Xcode 10.

### Changed

* Reduced severity comment for `nilHeaderModel` and `nilFooterModel` anomalies, since in some cases it's actually a desired behavior.

## [6.3.0](https://github.com/DenTelezhkin/DTTableViewManager/releases/tag/6.3.0)

### Added

* Anomaly detecting system for various errors in `DTTableViewManager`. Read more about it in [Anomaly Handler Readme section](https://github.com/DenTelezhkin/DTTableViewManager#anomaly-handler). Anomaly handler system **requires Swift 4.1 and higher**.
* Support for Swift 4.2 in Xcode 10 beta 1.

### Changed

* Calling `startManaging(withDelegate:_)` method is no longer required.

### Breaking

* `viewFactoryErrorHandler` deprecated property on `DTTableViewManager` was removed. All previously reported errors and warnings are now a part of anomaly detecting system.

## [6.2.0](https://github.com/DenTelezhkin/DTTableViewManager/releases/tag/6.2.0)

* `editingStyle(for:_,_:)` method was replaced with `editingStyle(forItem:_,:_)` method, that accepts model and indexPath closure, without cell. Reason for that is that `UITableView` may call this method when cell is not actually on screen, in which case this event would not fire, and current editingStyle of the cell would be lost.

## [6.1.1](https://github.com/DenTelezhkin/DTTableViewManager/releases/tag/6.1.1)

* Updates for Xcode 9.3 and Swift 4.1

## [6.1.0](https://github.com/DenTelezhkin/DTTableViewManager/releases/tag/6.1.0)

## [6.1.0-beta.1](https://github.com/DenTelezhkin/DTTableViewManager/releases/tag/6.1.0-beta.1)

* Implemented new system for deferring datasource updates until `performBatchUpdates` block. This system is intended to fight crash, that might happen when `performBatchUpdates` method is called after `UITableView.reloadData` method(for example after calling `memoryStorage.setItems`, and then immediately `memoryStorage.addItems`). This issue is detailed in https://github.com/DenTelezhkin/DTCollectionViewManager/issues/27 and https://github.com/DenTelezhkin/DTCollectionViewManager/issues/23. This crash can also happen, if iOS 11 API `UITableView.performBatchUpdates` is used. This system is turned on by default. If, for some reason, you want to disable it and have old behavior, call:

```swift
manager.memoryStorage.defersDatasourceUpdates = false
```

* `TableViewUpdater` now uses iOS 11 `performBatchUpdates` API, if this API is available. This API will work properly on `MemoryStorage` only if `defersDatasourceUpdates` is set to `true` - which is default. However, if for some reason you need to use legacy methods `beginUpdates`, `endUpdates`, you can enable them like so:

```swift
manager.tableViewUpdater?.usesLegacyTableViewUpdateMethods = true
```

Please note, though, that new default behavior is recommended, because it is more stable and works the same on both UITableView and UICollectionView.

* `tableViewUpdater` property on `DTTableViewManager` is now of `TableViewUpdater` type instead of opaque `StorageUpdating` type. This should ease use of this object and prevent type unneccessary type casts.

## [6.0.0](https://github.com/DenTelezhkin/DTTableViewManager/releases/tag/6.0.0)

* Updated to Xcode 9.1 / Swift 4.0.2

## [6.0.0-beta.3](https://github.com/DenTelezhkin/DTTableViewManager/releases/tag/6.0.0-beta.3)

* Makes `DTTableViewManager` property weak instead of unowned to prevent iOS 10-specific memory issues/crashes.

## [6.0.0-beta.2](https://github.com/DenTelezhkin/DTTableViewManager/releases/tag/6.0.0-beta.2)

* Build with Xcode 9.0 final release.
* Fixed partial-availability warnings.

## [6.0.0-beta.1](https://github.com/DenTelezhkin/DTTableViewManager/releases/tag/6.0.0-beta.1)

**This is a major release with some breaking changes, please read [DTTableViewManager 6.0 Migration Guide](Documentation/Migration%20guides/6.0%20Migration%20Guide.md)**

* Added `updateVisibleCells(_:) method`, that allows updating cell data for visible cells with callback on each cell. This is more efficient than calling `reloadData` when number of elements in `UITableView` does not change, and only contents of items change.
* Implement `configureEvents(for:_:)` method, that allows batching in several cell events to avoid using T.ModelType for events, that do not have cell created.
* Added event for `UITableViewDelegate` `tableView(_:targetIndexPathForMoveFromRowAt:toProposedIndexPath:`
* Added events for focus engine on iOS 9
* Added events for iOS 11 `UITableViewDelegate` methods: `tableView(_:leadingSwipeActionsConfigurationForRowAt:`, `tableView(_:trailingSwipeActionsConfigurationForRowAt:`, `tableView(_:shouldSpringLoadRowAt:withContext:`
* `UITableViewDelegate` and `UITableViewDatasource` implementations have been refactored from `DTTableViewManager` to `DTTableViewDelegate` and `DTTableViewDataSource` classes.
* `DTTableViewManager` now allows registering mappings for specific sections, or mappings with any custom condition.
* Added `move(_:_:)` method to allow setting up events, reacting to `tableView:moveRowAt:to:` method.

# Breaking

* Signature of `move(_:_:)` method has been changed to make it consistent with other events. Arguments received in closure are now: `(destinationIndexPath: IndexPath, cell: T, model: T.ModelType, sourceIndexPath: IndexPath)`
* `tableView(UITableView, moveRowAt: IndexPath, to: IndexPath)` no longer automatically moves items, if current storage is `MemoryStorage`. Please use `MemoryStorage` convenience method `moveItemWithoutAnimation(from:to:)` to move items manually.

# Deprecated

* Error handling system of `DTTableViewManager` is deprecated and can be removed or replaced in future versions of the framework.

## [5.3.0](https://github.com/DenTelezhkin/DTTableViewManager/releases/tag/5.3.0)

Dependency changelog -> [DTModelStorage 5.0.0 and higher](https://github.com/DenTelezhkin/DTModelStorage/releases)

* Use new events system from DTModelStorage, that allows events to be properly called for cells, that are created using `ViewModelMappingCustomizing` protocol.

## [5.2.0](https://github.com/DenTelezhkin/DTTableViewManager/releases/tag/5.2.0)

### New

* Setting `TableViewUpdater` instance to `tableViewUpdater` property on `DTTableViewManager` now triggers `didUpdateContent` closure on `TableViewUpdater`.
* Added `sectionIndexTitles` event to replace `UITableViewDataSource.sectionIndexTitles(for:)` method.
* Added `sectionForSectionIndexTitle` event to replace `UITableViewDataSource.tableView(_:sectionForSectionIndexTitle:at)` method.

### Bugfixes

* All events that return Optional value now accept nil as a valid event result.
* `didDeselect(_:,_:)` method now accepts closure without return type - since `UITableViewDelegate` does not have return type in that method.

## [5.1.0](https://github.com/DenTelezhkin/DTTableViewManager/releases/tag/5.1.0)

Dependency changelog -> [DTModelStorage 4.0.0 and higher](https://github.com/DenTelezhkin/DTModelStorage/releases)

* `TableViewUpdater` has been rewritten to use new `StorageUpdate` properties that track changes in order of their occurence.
* `TableViewUpdater` `reloadRowClosure` and `DTTableViewManager` `updateCellClosure` now accept indexPath and model instead of just indexPath. This is done because update may happen after insertions and deletions and object that needs to be updated may exist on different indexPath.

## [5.0.0](https://github.com/DenTelezhkin/DTTableViewManager/releases/tag/5.0.0)

No changes

## [5.0.0-beta.3](https://github.com/DenTelezhkin/DTTableViewManager/releases/tag/5.0.0-beta.3)

* `DTModelStorage` dependency now requires `Realm 2.0`
* `UITableViewDelegate` `heightForHeaderInSection` and `heightForFooterInSection` are now properly called on the delegate, if it implements it(thanks, @augmentedworks!).

## [5.0.0-beta.2](https://github.com/DenTelezhkin/DTTableViewManager/releases/tag/5.0.0-beta.2)

### Added

* `DTTableViewOptionalManageable` protocol, that is identical to `DTTableViewManageable`, but allows optional `tableView` property instead of implicitly unwrapped one.
* Enabled `RealmStorage` from `DTModelStorage` dependency

## [5.0.0-beta.1](https://github.com/DenTelezhkin/DTTableViewManager/releases/tag/5.0.0-beta.1)

This is a major release, written in Swift 3. Read [Migration guide](Documentation/Migration%20guides/5.0%20Migration%20Guide.md) with descriptions of all features and changes.

Dependency changelog -> [DTModelStorage 3.0.0 and higher](https://github.com/DenTelezhkin/DTModelStorage/releases)

### Added

* New events system that covers almost all available `UITableViewDelegate` and `UITableViewDataSource` delegate methods.
* New class - `TableViewUpdater`, that is calling all animation methods for `UITableView` when required by underlying storage.
* `updateCellClosure` method on `DTTableViewManager`, that manually updates visible cell instead of calling `tableView.reloadRowsAt(_:)` method.
* `coreDataUpdater` property on `DTTableViewManager`, that creates `TableViewUpdater` object, that follows Apple's guide for updating `UITableView` from `NSFetchedResultsControllerDelegate` events.
* `isManagingTableView` property on `DTTableViewManager`
* `unregisterCellClass(_:)`, `unregisterHeaderClass(_:)`, `unregisterFooterClass(_:)` methods to unregister mappings from `DTTableViewManager` and `UITableView`

### Changed

* Event system is migrated to new `EventReaction` class from `DTModelStorage`
* Swift 3 API Design guidelines have been applied to all public API.
* Section and row animations are now set on `TableViewUpdater` class instead of `TableViewConfiguration`

### Removals

* `itemForVisibleCell`, `itemForCellClass:atIndexPath:`, `itemForHeaderClass:atSectionIndex:`, `itemForFooterClass:atSectionIndex:` were removed - they were not particularly useful and can be replaced with much shorter Swift conditional typecasts.
* `registerCellClass:whenSelected` method
* All events methods with method pointer semantics. Please use block based methods instead.
* `dataBindingBehaviour` property.
* `viewBundle` property on `DTTableViewManager`. Bundle is not determined automatically based on view class.
* `DTTableViewContentUpdatable` protocol. Use `TableViewUpdater` properties instead.

## [4.8.0](https://github.com/DenTelezhkin/DTTableViewManager/releases/tag/4.8.0)

### Changed

* Support for building in both Swift 2.2 and Swift 2.3
* Now all view registration methods use `NSBundle(forClass:)` constructor, instead of falling back on `DTTableViewManager` `viewBundle` property. This allows having cells from separate bundles or frameworks to be used with single `DTTableViewManager` instance.

## [4.7.0](https://github.com/DenTelezhkin/DTTableViewManager/releases/tag/4.7.0)

Dependency changelog -> [DTModelStorage 2.6.0 and higher](https://github.com/DenTelezhkin/DTModelStorage/releases)

## [4.6.0](https://github.com/DenTelezhkin/DTTableViewManager/releases/tag/4.6.0)

Dependency changelog -> [DTModelStorage 2.5 and higher](https://github.com/DenTelezhkin/DTModelStorage/releases)

### Breaking

* Update to Swift 2.2. This release is not backwards compatible with Swift 2.1.

### Changed

* Require Only-App-Extension-Safe API is set to YES in framework targets.

## [4.5.3](https://github.com/DenTelezhkin/DTTableViewManager/releases/tag/4.5.0)

## Fixed

* Fixed a bug, where prototype cell from storyboard could not be created after calling `registerCellClass(_:)` method.

## [4.5.0](https://github.com/DenTelezhkin/DTTableViewManager/releases/tag/4.5.0)

## Added

* Support for Realm database storage - using `RealmStorage` class.
* Ability to defer data binding until `tableView(_:willDisplayCell:forRowAtIndexPath:)` method is called. This can improve  scrolling perfomance for table view cells.
```swift
    manager.dataBindingBehaviour = .BeforeCellIsDisplayed
```

## Changed

* UIReactions now properly unwrap data models, even for cases when model contains double optional value.

## [4.4.1](https://github.com/DenTelezhkin/DTTableViewManager/releases/tag/4.4.1)

## Fixed

* Issue with Swift 2.1.1 (XCode 7.2) where storage.delegate was not set during initialization

## [4.4.0](https://github.com/DenTelezhkin/DTTableViewManager/releases/tag/4.4.0)

Dependency changelog -> [DTModelStorage 2.3 and higher](https://github.com/DenTelezhkin/DTModelStorage/releases)

This release aims to improve mapping system and error reporting.

## Added

* [New mapping system](https://github.com/DenTelezhkin/DTTableViewManager#data-models) with support for protocols and subclasses
* Mappings can now be [customized](https://github.com/DenTelezhkin/DTTableViewManager#customizing-mapping-resolution) using `DTViewModelMappingCustomizable` protocol.
* [Custom error handler](https://github.com/DenTelezhkin/DTTableViewManager#error-reporting) for `DTTableViewFactoryError` errors.

## Changed

* preconditionFailures have been replaced with `DTTableViewFactoryError` ErrorType
* Internal `TableViewReaction` class have been replaced by `UIReaction` class from DTModelStorage.

## [4.3.0](https://github.com/DenTelezhkin/DTTableViewManager/releases/tag/4.3.0)

Dependency changelog -> [DTModelStorage 2.2 and higher](https://github.com/DenTelezhkin/DTModelStorage/releases)

## Changed

* Added support for Apple TV platform (tvOS).

## Fixed

* `registerNiblessFooterClass` method now works correctly.

## Renamed

* `objectForCellClass` category of methods have been removed to read item in their title instead of object.

## Removed

* `TableViewStorageUpdating` protocol and conformance has been removed as unnecessary.

## [4.2.1](https://github.com/DenTelezhkin/DTTableViewManager/releases/tag/4.2.1)

## Updated

* Improved stability by treating UITableView as optional

## [4.2.0](https://github.com/DenTelezhkin/DTTableViewManager/releases/tag/4.2.0)

Dependency changelog -> [DTModelStorage 2.1 and higher](https://github.com/DenTelezhkin/DTModelStorage/releases)

This release aims to improve storage updates and UI animation with UITableView. To make this happen, `DTModelStorage` classes were rewritten and rearchitectured, using Swift `Set`.

There are some backwards-incompatible changes in this release, however Xcode quick-fix tips should guide you through what needs to be changed.

## Added

 * `registerNiblessHeaderClass` and `registerNiblessFooterClass` methods to  support creating `UITableViewHeaderFooterView`s from code

## Fixed

* Fixed retain cycles in event blocks

## [4.1.0](https://github.com/DenTelezhkin/DTTableViewManager/releases/tag/4.1.0)

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

## [4.0.0](https://github.com/DenTelezhkin/DTTableViewManager/releases/tag/4.0.0)

4.0 is a next major release of `DTTableViewManager`. It was rewritten from scratch in Swift 2 and is not backwards-compatible with previous releases.

Read  [4.0 Migration guide](Documentation/Migration%20guides/4.0%20Migration%20Guide.md).

### Features

* Improved `ModelTransfer` protocol with associated `ModelType`
* `DTTableViewManager` is now a separate object
* New events system, that allows reacting to cell selection, cell/header/footer configuration and content updates
* Added support for `UITableViewController`, and any other object, that has `UITableView`
* New storage object generic-type getters
* Support for Swift types - classes, structs, enums, tuples.

## [3.2.0](https://github.com/DenTelezhkin/DTTableViewManager/releases/tag/3.2.0)

### Bugfixes

* Fixed an issue, where storageDidPerformUpdate method could be called without any updates.

## [3.1.1](https://github.com/DenTelezhkin/DTTableViewManager/releases/tag/3.1.1)

* Added support for installation using [Carthage](https://github.com/Carthage/Carthage) :beers:

## [3.1.0](https://github.com/DenTelezhkin/DTTableViewManager/releases/tag/3.1.0)

### Changes

* Added nullability annotations for XCode 6.3 and Swift 1.2


## [3.0.5](https://github.com/DenTelezhkin/DTTableViewManager/releases/tag/3.0.5)

## Features

Added removeAllTableItemsAnimated method.

## Bugfixes

Fixed issue, that could lead to wrong table items being removed, when using memory storage  removeItemsAtIndexPaths: method.

## [3.0.2](https://github.com/DenTelezhkin/DTTableViewManager/releases/tag/3.0.2)

### Changes

* Supported frameworks installation from CocoaPods - requires iOS 8.

## [3.0.0](https://github.com/DenTelezhkin/DTTableViewManager/releases/tag/3.0.0)

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

## [2.7.0](https://github.com/DenTelezhkin/DTTableViewManager/releases/tag/2.7.0)

This is a release, that is targeted at improving code readability, and reducing number of classes and protocols inside DTTableViewManager architecture.

### Breaking changes

* `DTTableViewMemoryStorage` class was removed. It's methods were transferred to `DTMemoryStorage+DTTableViewManagerAdditions` category.
* `DTTableViewStorageUpdating` protocol was removed. It's methods were moved to `DTTableViewController`.

### Features

* When using `DTCoreDataStorage`, section titles are displayed by default, if NSFetchedController was created with sectionNameKeyPath property.

## [2.5.0](https://github.com/DenTelezhkin/DTTableViewManager/releases/tag/2.5.0)

### Changes

Preliminary support for Swift.

If you use cells, headers or footers inside storyboards from Swift, implement optional reuseIdentifier method to return real Swift class name instead of the mangled one. This name should also be set as reuseIdentifier in storyboard.

## [2.4.0](https://github.com/DenTelezhkin/DTTableViewManager/releases/tag/2.4.0)

### Breaking changes

Reuse identifier now needs to be identical to cell, header or footer class names. For example, UserTableCell should now have "UserTableCell" reuse identifier.

## [2.3.0](https://github.com/DenTelezhkin/DTTableViewManager/releases/tag/2.3.0)

#### Features

Added properties of `DTTableViewController` to control, whether section headers and footers should be shown for sections, that don't contain any items.

#### Deprecations

Removed `DTModelSearching` protocol, please use `DTMemoryStorage` `setSearchingBlock:forModelClass:` method instead.

## [2.2.0](https://github.com/DenTelezhkin/DTTableViewManager/releases/tag/2.2.0)

* `DTModelSearching` protocol is deprecated and is replaced by memoryStorage method setSearchingBlock:forModelClass:
* UITableViewDelegate and UITableViewDatasource properties for UITableView are now filled automatically.
* Added more assertions, programmer errors should be easily captured.

## [2.1.0](https://github.com/DenTelezhkin/DTTableViewManager/releases/tag/2.1.0)

#### Breaking changes

Storage classes now use external dependency from [DTModelStorage repo](https://github.com/DenTelezhkin/DTModelStorage).

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

## [2.0.0](https://github.com/DenTelezhkin/DTTableViewManager/releases/tag/2.0.0)

DTTableViewManager 2.0 is a major update to the framework with several API - breaking changes. Please read [DTTableViewManager 2.0 transition guide for an overview](https://github.com/DenTelezhkin/DTTableViewManager/wiki/DTTableViewManager-2.0-Transition-Guide).

## [1.3.0](https://github.com/DenTelezhkin/DTTableViewManager/releases/tag/1.3.0)

#### Features

Added support for storyboard prototype cells.

##### Enhancements

DTTableViewManager renamed to DTTableViewController.

#### Bugfixes

Fixed bug, which prevented using correct height values on custom headers and footers.

## [1.2.1](https://github.com/DenTelezhkin/DTTableViewManager/releases/tag/1.2.1)

#### Features
Added ability to disable logging

##### Enhancements

Improved structure of mapping code, now mapping and cell creation happens completely in DTCellFactory class.

## [1.2.0](https://github.com/DenTelezhkin/DTTableViewManager/releases/tag/1.2.0)

#### Features

Introducing support for Foundation data models. Cell, header and footer mapping now supports following classes:
* NSString / NSMutableString
* NSNumber
* NSDictionary / NSMutableDictionary
* NSArray / NSMutableArray

#### Deprecations

* option to not reuse cells is removed. Currently there's no obvious reason to not have cell reuse.

## [1.1.0](https://github.com/DenTelezhkin/DTTableViewManager/releases/tag/1.1.0)

#### Features
Powerful and easy search within UITableView.

#### General changes
Tests are now running on [Travis-CI](https://travis-ci.org/DenTelezhkin/DTTableViewManager)

#### Deprecations

Ability to create DTTableViewManager as a separate object was removed. If you need to subclass from different UIViewController, consider using iOS Containment API.
