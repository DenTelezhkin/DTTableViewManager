## Datasources

### MemoryStorage

By default, `DTTableViewManager` uses `MemoryStorage` - a storage wrapper, representing storage of data models in memory.

```swift
manager.memoryStorage.setItems([1,2,3])
```

`MemoryStorage` has a lot of methods, allowing you to modify storage contents - adding, inserting, removing, replacing, moving, searching items in storage. For a complete list, head on to [MemoryStorage documentation](https://github.com/DenTelezhkin/DTModelStorage/blob/master/Documentation/Memory%20storage.md).

### Diffable datasources (iOS/tvOS 13+)

Setting up diffable datasources is similar to how you would setup them without `DTTableViewManager`. The only difference is that instead of creating diffable datasource object using it's initializer, you instead use method provided by `DTTableViewManager`:

```swift
dataSource = manager.configureDiffableDataSource { indexPath, model in
   model
}
```

You can find working example of multi-section diffable datasources integration [here](https://github.com/DenTelezhkin/DTTableViewManager/blob/master/Example/Controllers/MultiSectionDiffingTableViewController.swift).

More documentation on diffable datasources integration can be found [here](https://github.com/DenTelezhkin/DTModelStorage/blob/master/Documentation/Diffable%20datasource%20storage.md).

### SingleSectionEquatableStorage

`SingleSectionEquatableStorage` is a storage for a single section, that calculates UI updates using provided differ.

No differ is provided by `DTModelStorage`, but you really need to build a thin adapter(5-6 lines of code) between your differ of choice and `DTModelStorage` for update calculation. `DTModelStorage` provides example of already built adapters for [Dwifft](https://github.com/jflinter/Dwifft), [HeckelDiff](https://github.com/mcudich/HeckelDiff) and [Changeset](https://github.com/osteslag/Changeset) differs.

Setting up this kind of storage is simple:

```swift
let storage = SingleSectionEquatableStorage(items: arrayOfPosts, differ: ChangesetDiffer())
storage.setItems(startingItems)
manager.storage = storage

storage.addItems(newItems)
```

For more specific documentation on this storage, head on to [this document](https://github.com/DenTelezhkin/DTModelStorage/blob/master/Documentation/Single%20section%20diffable%20storage.md).

### CoreDataStorage

`CoreDataStorage` is designed to work with `NSFetchedResultsController`, and automatically animate all changes happening in the database.

```swift
manager.storage = CoreDataStorage(fetchedResultsController: controller)
```

For more information, read documentation on [CoreDataStorage](https://github.com/DenTelezhkin/DTModelStorage/blob/master/Documentation/CoreData%20storage.md).

### RealmStorage

`RealmStorage` is a single-section storage for data models from [Realm](https://realm.io)


```
let results = try! Realm().objects(Dog)

let storage = RealmStorage()
storage.addSection(with:results)
```

For more details, please read [documentation on RealmStorage](https://github.com/DenTelezhkin/DTModelStorage/blob/master/Documentation/Realm%20storage.md).

### Custom storage

If you are not happy with provided options, you can build custom storage, that fits your needs. You can either subclass any of 5 storages described above, or implement your own. The only requirement is [Storage protocol](https://github.com/DenTelezhkin/DTModelStorage/blob/master/Sources/DTModelStorage/StorageProtocols.swift#L30-L40). Additionally, you may implement [SupplementaryStorage protocol](https://github.com/DenTelezhkin/DTModelStorage/blob/master/Sources/DTModelStorage/StorageProtocols.swift#L43-L59), that allows storage to implement supplementary models / header-footer models.

For convenience, `DTTableViewManager` provides optional access to supplementaryStorage:

```swift
manager.supplementaryStorage?.setSectionHeaderModels([1])
```

Please note, that this accessor works also for any of the 5 storages described above, as well as for any storage, that implements `SupplementaryStorage` protocol.
