# Why

UITableView has great API. It provides access to amazing things like compositional layouts, list layout, effective cell reuse, self-sizing and others. However, in some places using UITableView becomes boilerplatey and error-prone.

DTTableViewManager framework aims to close those gaps by focusing on compile-time safety, elimination of String-based API's, replacing delegate syntax with concrete-type closures, and much more. To find out more, read along!

## Cell registration

Two most popular ways of creating UITableViewCell's are creating cells from code or from xib file. Both of those API's use String API's in some form:

```swift
tableView.register(PostCell.self, forCellWithReuseIdentifier: "PostCell")

let nib = UINib(nibName: "PostCell", bundle: nil)
tableView.register(nib, forCellWithReuseIdentifier: "PostCell")
```

It's a common sense to use the same name for xib with cell design and reuseIdentifier, so why not use this as default? Registering cells to be dequeued from code, xib, or storyboard are exactly the same with DTTableViewManager:

```swift
manager.register(PostCell.self)
```

Registration methods are also much more expanded, and allow powerful customizations:

```swift
manager.register(PostCell.self) { mapping in
    // Different reuse identifier
    mapping.reuseIdentifier = "FooBar"

    // Different xib name
    mapping.xibName = "MyPostCell"

    // Only use this mapping for Posts in second section
    mapping.condition = .section(1)
}
```

Registration API's work similarly for header/footer views, allow a configuration handler to be passed, and also serve as a base for delegate event handling.

You can read more about view registration [here](Registration.md).

## Delegate API's

There are a lot of delegate methods on UITableView. A lot of them are related to UITableViewCell, which is usually provided by delegate method using indexPath. Most of the time you need actual data model from you datasource, not the indexPath provided by tableView.

```swift
func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let post = posts[indexPath.item]
    // Push PostDetailController?
}
```
If you have an array of models of a single type, it looks fine, but especially with introduction of compositional layouts, and also when your app becomes more complex, chances are you will have much more types of data models, and some type-casting will be required:

```swift
func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let post = posts[indexPath.item]
    switch post {
    case let photoPost as PhotoPost:
      // Show photo gallery
    case let videoPost as VideoPost:
      // Play video full screen
    case let textPost as TextPost:
      // Push PostDetailController
    default: ()
    }
}
```

This is just one delegate method, imagine you have several of those - cells might have different sizes, or can support drag&drop, or other things. Your code quickly becomes filled with switches and if statements, unnecessarily multiplying complexity.

DTTableViewManager solves this problem by implementing delegate methods as type-safe closures, and providing access to them directly where you register your cell:

```swift
manager.register(VideoPostCell.self) { mapping in
  mapping.didSelect { cell, model, indexPath in
      // cell is of type VideoPostCell, model is VideoPost
  }
  mapping.willDisplay { cell, model, indexPath in
      // cell is of type VideoPostCell, model is VideoPost
  }
  // etc..
}
```

All delegate methods are supported, including `UITableViewDelegate`, `UITableViewDragDelegate` and `UITableViewDropDelegate` . Delegate methods, that are not related to cells or header/footer views, are available as closures on `DTTableViewManager` instance directly:

```swift
manager.didEndMultipleSelectionInteraction {
  // is equivalent to func tableViewDidEndMultipleSelectionInteraction(_ tableView: UITableView) delegate method
}
```

You can read more about [events and how they are implemented here](Events.md)

## Model transfer

If you read previous section, and thought to yourself: "Wait, how does the framework know, that VideoPostCell needs VideoPost, and not other type of model?", let's dive in!

Usually with UITableView, you have some models, that you need to display. So, in datasource method `tableVoew(_:cellForRowAt:)` you would typically update all UITableViewCell subviews, or just transfer model to cell, so that cell would do it itself.

DTTableViewManager standardizes this by introducing `ModelTransfer` protocol:

```swift
class VideoPostCell: UITableViewCell, ModelTransfer {
  func update(with model: VideoPost) {
    // update cell
  }
}
```

This protocol is used when you register cell with `DTTableViewManager` instance, inferring mapping between `VideoPost` and `VideoPostCell`. This is also how delegate closure events have understanding about which cell and model types they execute on.

Although usage of `ModelTransfer` protocol is recommended, it's not required. You can register cells without explicitly transferring it's model, which is useful for simple cells:

```swift
manager.register(UITableViewCell.self, for: MenuItem.self) { mapping in
  mapping.didSelect { cell, model, indexPath in
    // did select menu item \(model) at \(indexPath)
  }
} handler: { cell, model, indexPath in
  cell.textLabel.text = model
}
```

To find out more about model transfer and model mapping, head on to [Mapping.md](Mapping.md).

## Datasource abstractions

Datasource abstractions for `DTTableViewManager` are extracted into separate framework `DTModelStorage`.It abstracts datasources as `Storage` protocol, and provides several implementations:

* `MemoryStorage` for storing array of arrays of data models in memory
* `CoreDataStorage` for displaying data models from CoreData, fetched by NSFetchedResultsController
* `RealmStorage` for displaying data models from Realm
* `SingleSectionEquatableStorage` for single section diffable datasources, can be used with frameworks like [Changeset](https://github.com/osteslag/Changeset), [Dwifft](https://github.com/jflinter/Dwifft) or another diffing framework of your choice
* `ProxyDiffableDataSourceStorage` for diffable datasources in iOS / tvOS 13

DTTableViewManager defaults to using `MemoryStorage`, in which case showing array of data models is as simple as:

```swift
  manager.memoryStorage.setItems(posts)
```

Configuring diffable datasources for iOS 13 and higher also simplifies following code:

```swift
dataSource = UITableViewDiffableDataSource
    <Section, MountainsController.Mountain>(tableView: mountainsTableView) {
        (tableView: UITableView, indexPath: IndexPath,
        mountain: MountainsController.Mountain) -> UITableViewCell? in
    guard let mountainCell = tableView.dequeueReusableCell(
        withReuseIdentifier: LabelCell.reuseIdentifier, for: indexPath) as? LabelCell else {
            fatalError("Cannot create new cell") }
    mountainCell.label.text = mountain.name
    return mountainCell
}
```

into:

```swift
dataSource = manager.configureDiffableDataSource { indexPath, model in
   model
}
```

[Read more](Datasources.md) about all datasource abstractions in more detail.

## Anomalies

We are all human. We make mistakes. `DTTableViewManager` attempts to analyze usage of it's API's, and if something is off, it emits anomaly.

By default, anomalies are non-fatal errors, and they are simply logged into console. For example, if you attempt to register an empty Xib for your cell, following will be logged into console:

```
[DTTableViewManager] Attempted to register xib VideoPostCell for VideoPostCell, but this xib does not contain any views."
```

You can customize behavior of anomalies by setting an anomaly handler, and for example sending any anomalies to your analytics provider. You can also silence any particular anomaly, if you don't think it's emitted correctly, or silence all anomalies altogether, if you choose to.

Read more about anomalies [here](Anomalies.md).

## More

If you are interested in bringing the same approach to UICollectionView, [DTCollectionViewManager](https://github.com/DenTelezhkin/DTCollectionViewManager) is a framework built with the same principles, and the same interfaces, but tailored specifically for `UICollectionView` usage.

There is also much more stuff under the hood: perfomance optimizations for reloading instead of animating when UITableView is not visible, trampolining of delegate methods if you need them, enhanced support for Drag&Drop, and more, all of which is described in other documents in Documentation directory.

`DTTableViewManager` is stable and used in production by dozens of apps (that I know of). If you use UITableView, give it a try, and you will not be disappointed!
