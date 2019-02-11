## Swift 2

The biggest change in DTTableViewManager is, of course, programming language. It was rewritten from scratch, leveraging best technics possible in Swift 2. Those include generics, default protocol implementations, error handling model, Swift structs, enums and tuples. Changes are not limited to framework internals, but externals as well. This makes it not possible to support ObjectiveC and Swift 1.x.

If you choose to migrate to `DTTableViewManager` 4.0, you can only use Swift2 and XCode 7.

## ModelTransfer and registration

Transferring model from storage to cell was always one of the most important features of `DTTableViewManager` - you register a cell, and a model to pass to cell, when cell is created. However, in ObjectiveC, there was no way to make this model correct type, so it was an `id` type, which needed type casting. Now, new `ModelTransfer` protocol with associated type allows model to be specific type:

```swift
class PostCell: UITableViewCell, ModelTransfer
{
    func updateWithModel(model: Post) {
         // Update UI
    }
}
```

`DTTableViewCell` class was removed, as it's no longer necessary. Thanks to improved `ModelTransfer` protocol cell, header and footer registration become shorter:

```swift
// Old version:
     registerCellClass(PostCell.self, forModelClass: Post.self)
```

```swift
// New version:
    manager.registerCellClass(PostCell)
```

## `DTTableViewManager` object

In 3.x release you had to always subclass `DTTableViewController` and were limited to using `UIViewController` with `UITableView`. In 4.x release `DTTableViewManager` is a separate object. There are several consequences of this design decision:

1. `DTTableViewController` class is removed - there's no need to subclass anything
2. Added support for `UITableViewController`, and basically any view controller or view, that contains `UITableView`.
3. `DTTableViewManager` is now central object of a framework, and serves as `UITableViewDelegate` and `UITableViewDatasource`.

There are several steps required to start using `DTTableViewManager`.

1. Declare your view controller as `DTTableViewManageable`:

```swift
class PostsViewController: UITableViewController, DTTableViewManageable {}
```

ObjectiveC and Swift runtimes will work together by automatically providing `manager` property on your class.

2. Call `startManagingWithDelegate` method:

```swift
override func viewDidLoad() {
    super.viewDidLoad()
    manager.startManagingWithDelegate(self)
}
```

3. Call registration methods and storage methods as usual

```swift
    manager.registerCellClass(PostCell)
    manager.memoryStorage.addItems(posts)
```

## Reacting to events

Reacting to events is a new API, that allows you to register callbacks for various events happening in a framework. It replaces 3.x `DTTableViewControllerEvents` protocol.

**Important!** All event closures are stored on `DTTableViewManager` instance, so be sure to declare weak self in capture lists.

Previously, if you needed for example add a UIButton event on your UITableViewCell, it was common to override `tableView(_:cellForRowAtIndexPath:)` method, call super to retrieve cell, cast it to correct type, and configure it as needed. 4.x release provides more flexible way to do this:

```swift
    manager.configureCell(PostCell.self) { postCell, post, indexPath in
        // Configure PostCell at concrete indexPath
    }
```

There are two important things to understand here. When closure will be executed, PostCell is already created, and `updateWithModel` is already called. And second - postCell and post are already correct type! There's no need to cast and check types.

Of course, there are similar `configureHeader(_:closure:)` and `configureFooter(_:closure)` methods.

There is selection event, that is executed when `tableView(_:didSelectRowAtIndexPath:)` is fired:

```swift
    manager.whenSelected(PostCell.self) { postCell, post, indexPath in
        // Some action
    }
```

and a shortcut, that combines registration and selection:

```swift
    manager.registerCellClass(PostCell.self, whenSelected: { postCell, post, indexPath in })
```

Other events:

```swift
    manager.beforeContentUpdate {}
    manager.afterContentUpdate {}
```

## UITableViewDelegate and UITableViewDataSource method forwarding

Any `UITableViewDelegate` and `UITableViewDataSource` method, that is not implemented by `DTTableViewManager`, will be redirected to `DTTableViewManageable` instance, aka your View Controller, if it implements it.

There are also two methods, that are implemented by `DTTableViewManager`, but you may choose to override them in your ViewController:

```swift
func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
```

Although in most cases, you won't need to do this.

## Configuration

There are a lot of configuration properties, such as displayHeaderOnEmptySection, row animation and section animation. Previously, they existed on `DTTableViewController`, now in 4.x all these properties have been moved to separate class - `TableViewConfiguration`, and are accessible via `DTTableViewManager` `configuration` property.

```swift
    manager.configuration.displayHeaderOnEmptySection = false
```

## Retrieving objects

In 3.x there were a couple of ways you could retrieve data models from storage:

```swift
    // Old methods
    let post = memoryStorage.objectAtIndexPath(indexPath) as! Post
    let arrayOfPosts = memoryStorage.sectionAtIndex(0).objects as! [Post]
```

Those methods remain the same in 4.x release, but instead of returning AnyObject and [AnyObject] they return Any? and [Any] respectively. While you can continue to use these methods, 4.x release provides a better way to retrieve models:

```swift
    // New getter methods
    let post = manager.objectForCellClass(PostCell.self, atIndexPath: indexPath) // returns Post?
    let postHeaderModel = manager.objectForHeaderClass(PostHeaderClass.self, atSectionIndex: sectionIndex)
    let postFooterModel = manager.objectForFooterClass(PostFooterClass.self, atSectionIndex: sectionIndex)
```

All result values are optional, however they are of concrete type, and type checks and casting are no longer needed.

There's also a shorter method, that works, if your cell is visible:

```swift
    let post = manager.objectForVisibleCell(postCell) // Post?
```

## Supported types

Thanks to new storage implementation, `DTTableViewManager` now supports all Swift types - classes, structs, enums, tuples as data models. It also has even more extended support for ObjectiveC Foundation classes - you can read all about it [on wiki](https://github.com/DenTelezhkin/DTTableViewManager/wiki/Mapping-and-registration).

## Summary

`DTTableViewManager` is my daily tool for a long time. I use it in almost every app that I build at work. And now, with 4.x release it's more powerful and convenient than ever. I'm sure there is a lot more stuff that can be done with Swift 2 default protocol implementations, generics, and associated types, and can't wait to see, what you as developer will be able to do with it.
