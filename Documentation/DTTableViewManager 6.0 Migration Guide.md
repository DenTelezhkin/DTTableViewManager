# DTTableViewManager/DTCollectionViewManager 6.0 Migration Guide

DTTableViewManager and DTCollectionViewManager 6.0 are the latest major releases of UITableView/UICollectionView helper libraries for iOS and tvOS written in Swift. Following [Semantic Versioning conventions](https://semver.org), 6.0 introduces API-breaking changes.

This guide is provided in order to ease the transition of existing applications using 5.x versions to the latest APIs, as well as explain the design and structure of new and updated functionality.

- [Requirements](#requirements)
- [Benefits of Upgrading](#benefits-of-upgrading)
- [Breaking API Changes](#breaking-api-changes)
	- [Delegate implementations](#delegate-implementations)
	- [Realm storage](#realm-storage)
	- [Other breaking changes](#other-breaking-changes)
- [New Features](#new-features)
	- [Backwards compatibility](#backwards-compatibility)
	- [Drag and Drop](#drag-and-drop)
  - [Improvements to events system](#improvements-to-events-system)
  - [Conditional mappings](#conditional-mappings)
	- [Improved Carthage support](#improved-carthage-support)
  - [Miscellaneous stuff](#miscellaneous-stuff)

## Requirements

- iOS 8.0+ / tvOS 9.0+
- Xcode 8.3+/ Xcode 9.x
- Swift 3.1/3.2/4.0

## Benefits of Upgrading

- **Compatibility with Xcode 8 / Xcode 9, as well as Swift 3.x/4.x**.
- **Support for Drag&Drop in iOS 11**, including convenience handling for `MemoryStorage`.
- **Improvements to events system** provide compile-time safety for events registration and lots of new events.
- **Conditional mappings** provide a powerful way of customizing your view mappings.
- **Improved Carthage support** will now include prebuilt binaries, attached via GitHub releases.

## Breaking API Changes

Compared to last year's massive Swift 3 changes, this year breaking API changes are relatively small, and in most cases should not affect a lot of users, and should not require a lot of time to migrate to.

### Delegate implementations

In all previous releases, `DTTableViewManager` and `DTCollectionViewManager` were objects, that implemented datasource and delegate methods. In 6.x, number of protocols implemented doubled due to Drag&Drop, which is why implementations of those protocols has been moved to those classes:

- `UITableViewDataSource` -> `DTTableViewDataSource`
- `UITableViewDelegate` -> `DTTableViewDelegate`
- `UITableViewDragDelegate` -> `DTTableViewDragDelegate`
- `UITableViewDropDelegate` -> `DTTableViewDropDelegate`
- `UICollectionViewDataSource` -> `DTCollectionViewDataSource`
- `UICollectionViewDelegate` -> `DTCollectionViewDelegate`
- `UICollectionViewDropDelegate` -> `DTCollectionViewDropDelegate`
- `UICollectionViewDragDelegate` -> `DTCollectionViewDragDelegate`

As a consequence, `DTTableViewManager` and `DTCollectionViewManager` no longer implement any of those datasource and delegate methods. If you relied on this fact, or have subclasses or extensions of `DTTableViewManager` or `DTCollectionViewManager`, you should subclass or extend new classes instead.

### Realm Storage

`RealmStorage` class is a `Storage` implementation for [Realm database](https://realm.io). It is great to have the ability to work independently with in-memory datasources, CoreData datasources, or Realm datasources. What's not great, is wait times if you use Carthage. `RealmSwift` framework, even in zipped prebuilt binary form, is 250 Mb in size. That's a lot even if you use some form of Carthage cache. And this penalty is applied to all `DTTableViewManager` Carthage users, even if they don't use Realm at all.

So, starting with 6.0, `RealmStorage` extension will not be made available through Carthage. If you use `CocoaPods`, `RealmStorage` is still available via a subspec, and as for Carthage users - for now I can recommend only copy pasting Realm classes into your projects, and depending on Realm-Cocoa directly. If Carthage developers ever decide to implement subspec-like functionality, I'll be happy to bring those classes back. Another hope is Carthage `Ignorefile`, that is currently in development - https://github.com/Carthage/Carthage/pull/1990, if this will be implemented, `RealmStorage` will be once again made available through Carthage.

### Other breaking changes

* `MemoryStorage` method `setItems(_:)`, that accepted array of arrays of items, was renamed to `setItemsForAllSections` to provide more clarity and eliminate possibility of calling `setItems(_:forSection:)` that has identical signature.
* Signature of `move(_:_:)` method has been changed to make it consistent with other events. Arguments received in closure are now: `(destinationIndexPath: IndexPath, cell: T, model: T.ModelType, sourceIndexPath: IndexPath)`
* `tableView(UITableView, moveRowAt: IndexPath, to: IndexPath)` no longer automatically moves items, if current storage is `MemoryStorage`. Please use `MemoryStorage` convenience method `moveItemWithoutAnimation(from:to:)` to move items manually.

## New Features

### Backwards compatibility

Usually backwards compatibility is not considered a "feature", but since last year Swift 3 migration was huge and painful, maintaining backwards compatibility is actually pretty important. 6.x release contains several CI jobs setup to ensure compatibility with operating systems, Xcode releases and Swift compilers. Supported releases include:

* **iOS 8.x - iOS 11.x, tvOS 9.0 - tvOS 11.x**
* **Xcode 8.3, Xcode 9.0**
* **Swift 3.1, 3.2, 4.0**

### Drag and Drop

[Drag&Drop in iOS 11](https://developer.apple.com/ios/drag-and-drop) is a huge topic, that has 4 WWDC sessions, dedicated to it. I highly recommend checking all 4 of those sessions out before implementing support for Drag&Drop in your app. `DTTableViewManager` and `DTCollectionViewManager` gained **28** new events for Drag&Drop delegate methods. Those methods, as usual, are named almost identical to original delegate methods. There is also special support for `UITableView` and `UICollectionView` placeholders.

New convenience classes `DTTableViewDropPlaceholderContext` and `DTCollectionViewDropPlaceholderContext` serve as thin wrappers around `UITableViewDropPlaceholderContext` and `UICollectionViewDropPlaceholderContext`, automatically dispatching placeholder updates to `DispatchQueue.main`, and providing automatic datasource updates if you are using `MemoryStorage` class.

To demonstrate `Drag&Drop` usage with `DTTableViewManager` and `DTCollectionViewManager` there's a new example repo - [https://github.com/DenHeadless/DTDragAndDropExample](https://github.com/DenHeadless/DTDragAndDropExample), containing [Apple's sample on Drag&Drop](https://developer.apple.com/sample-code/wwdc/2017/Drag-and-Drop-in-UICollectionView-and-UITableView.zip), rewritten using `DTTableViewManager` and `DTCollectionViewManager`.

### Improvements to events system

Back in 4.x release, there were only 6 events implemented. 5.x release introduced support for 37 `UITableView` events, and 27 `UICollectionView` events. 6.x release boosts this system to whole new level.

`DTTableViewManager` now has **61** event, that cover all delegate and datasource protocols `UITableView` has. `DTCollectionViewManager` now has **54** events, which brings total number of events to crazy **115**, if you count events for entire system :tada:.

New events include iOS 11 API, as well as some iOS 9 and iOS 10 API, that was missed or was not implemented previously. If you are afraid of perfomance hit this may imply on your app - don't worry. Both `DTTableViewManager` and `DTCollectionViewManager` intelligently tell `UITableView` and `UICollectionView` only about events and methods, that are being actually used, which means that there's no perfomance cost needed to be paid for additional events.

Events system also got one really small improvement, that is partially experimental, however it may have huge impact on how events are registered. For example, if you wanted to register a cell, that uses Int as a data model, and then event that calculates estimated height for this cell, it would look similar to this:

```swift
  manager.register(IntCell.self)
  manager.estimatedHeight(for: Int.self) { _,_ in
    return 44
  }
```

Notice that for registration we pass Cell type, and for estimated height event we are actually passing Model type instead of cell. Why is that? Well, this is actually because for estimated height calculation cell is not yet created, and we can't possibly know it's type. There's about 1/3 of events, that use the same pattern - cell is not created, therefore let's use data model. This approach, however, has a big logic problem. What happens if `IntCell` changes it's model to be `NSNumber` for example? The code will compile without issues, however event will not get triggered, because there's no event registered for NSNumber. `DTTableViewManager` and `DTCollectionViewManager` 6.x introduce a new way of registering events, that works like so:

```swift
  manager.configureEvents(for: IntCell.self) { cellType, modelType in
    manager.register(cellType)
    manager.estimatedHeight(for: modelType) { _,_ in
      return 44
    }
  }
```

`configureEvents` is a simple method, that immediately calls closure of `(T.Type, T.ModelType.Type) -> Void`, and you can use both cellType and modelType inside this closure to register events. This way, when `IntCell` changes it's model to `NSNumber`, you don't need to change anything in event registration code, it will just work. And more importantly - this provides compile-time safety for all cell and model types, that are participating in events system.

### Conditional mappings

Previously, if you needed to customize mappings based on some condition, you would use `ViewModelMappingCustomizing` protocol. For example, if you wanted to have different cell mappings for two different sections, you may have done something like this:

```swift
extension MyViewController: ViewModelMappingCustomizing {
  func viewModelMapping(fromCandidates candidates: [ViewModelMapping], forModel model: Any) -> ViewModelMapping? {
    if let indexPathInSection = manager.memoryStorage.indexPath(forItem: model) {
      switch indexPathInSection.section {
        case 0: return candidates.first
        case 1: return candidates[1]
        default: return nil
      }
      return nil
    }
  }
}
```

This has a lot of buggy and crashy potential. First of all, there's no indication that this model should resolve to cell - this may be a model for header or footer. Second - there's no indexPath, we have to guess from where this model is coming from. And this approach also relies on implicit order of mapping candidates, which is very unstable.

Starting with 6.x, this functionality is soft-deprecated, and replaced with new, much more powerful conditional mappings. Here's how you would implement the same thing with new API:

```swift
  manager.register(FirstSectionCell.self) { mapping in mapping.condition = .section(0) }
  manager.register(SectionSectionCell.self) { mapping in mapping.condition = .section(1) }
```

Is is much simpler, and much more readable. Conditional mappings have three possible behaviors - `.none` allows mappings everywhere, `.section` allows mapping to be tied to specific section, and also there is `.custom` for everything else.

For example, if want your mapping to work only for Int models, that are larger than 2, here's how you would implement it:

```swift
  manager.register(ComplexConditionCell.self) { mapping in
      mapping.condition = .custom({ indexPath, model in
          guard let model = model as? Int else { return false }
          return model > 2
      })
  }
```

`.custom` case has a closure of type `(IndexPath,Any) -> Bool` which allows you to customize mapping as you want. Apart from condition, you can also change `reuseIdentifier` to be used for mappings. This is rare case, however if you want for example to use different XIBs for the same cell class in different sections, you would need to do this:

```swift
manager.register(NibCell.self) { mapping in
    mapping.condition = .section(0)
    mapping.reuseIdentifier = "NibCell One"
}
controller.manager.registerNibNamed("CustomNibCell", for: NibCell.self) { mapping in
    mapping.condition = .section(1)
    mapping.reuseIdentifier = "NibCell Two"
}
```

This is needed because even though mappings are stored on `DTTableViewManager` instance, `UITableView` actually has no idea we are pulling such tricks, and when we'll try to dequeue cell based on reuseIdentifier, if we use the same reuseIdentifier, second mapping will simply be erased from `UITableView` memory. But since we are able to use two different reuseIdentifiers, we are golden :100:.

### Improved Carthage support

Thanks to dropping `Realm` dependency from `DTModelStorage`, build times should be significantly faster for Carthage users. To improve this even more, starting with 6.x release, prebuilt binaries will be now made available as a part of GitHub release for `DTModelStorage`, `DTTableViewManager` and `DTCollectionViewManager`.

Prebuilt binaries will only be compiled using latest version of compiler, so for example for Xcode 9.0 it will be Swift 4.0 compiler.

### Miscellaneous stuff

There's quite a few of small improvements in 6.x releases, that can be useful.

For example, there's a new `updateVisibleCells(_:)` method on `DTTableViewManager` and `DTCollectionViewManager`, that allows you to update only visible on screen cells, which can be a big improvement over calling `reloadData`, if your models change, but their quantity does not change.

`MemoryStorage` now has `moveItemWithoutAnimation(from:to:)` method, that can be used when reordering items.

There is now `DTTableViewOptionalManageable` protocol, that allows you to have outlet of `UITableView` declared as optional `UITableView?`. There's also `DTCollectionViewNonOptionalManageable` protocol for `UICollectionView!`.
