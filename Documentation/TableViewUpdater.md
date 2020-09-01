# TableViewUpdater

`TableViewUpdater` is a class, responsible for animating datasource updates.

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

Please keep in mind, that those closures will not be called if you directly invoke `tableView.reloadData()`. If you need to call `reloadData` and trigger those closures, please call:

```swift
manager.tableViewUpdater?.storageNeedsReloading()
```

### Animations

You can customize section and row animations:

```swift
updater.insertSectionAnimation = .automatic
updater.deleteSectionAnimation = .fade
updater.reloadSectionAnimation = .none

updater.insertRowAnimation = .automatic
updater.deleteRowAnimation = .fade
updater.reloadRowAnimation = .none
```

### Customizing UITableView updates

`DTTableViewManager` uses `TableViewUpdater` class by default. While usually, you don't need to configure anything additional with `TableViewUpdater`, one exception to this rule is CoreData and `CoreDataStorage`.

When setting up CoreDataStorage with `DTTableViewManager` and `DTCollectionViewManager`, consider using special CoreData updater:

```swift
manager.collectionViewUpdater = manager.coreDataUpdater()

manager.tableViewUpdater = manager.coreDataUpdater()
```

This special version of updater has two important differences from default behavior:

1. Moving items is animated as insert and delete
2. When data model changes, `update(with:)` method and `handler` closure are called to update visible cells without explicitly reloading them.

Those are [recommended by Apple](https://developer.apple.com/documentation/coredata/nsfetchedresultscontrollerdelegate) approaches to handle `NSFetchedResultsControllerDelegate` updates with `UITableView` and `UICollectionView`.

If your `UITableView` is not on screen, it's updates are not required to be animated. For performance reasons you may want to disable offscreen animations:

```swift
manager.tableViewUpdater.animateChangesOffScreen = false
```
