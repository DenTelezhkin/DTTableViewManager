# Registering views

`DTTableViewManager` supports registering reusable views designed in code, xib file, or storyboard. It also supports registering relationship between view and it's data model through `ModelTransfer` protocol and without it.

While [Mapping document](Mapping.md) focuses on relationship between view and it's model, and [Events document](Events.md) follows on how to attach delegate methods to those mappings, this document instead focuses on registration aspect itself, and what is possible within `DTTableViewManager` architecture.

## Registration

In general, registering any reusable view with `DTTableViewManager` looks like:

```swift
manager.register(View.self) { mapping in

} handler: { view, model, indexPath in

}
```

In case of `ModelTransfer`, both `mapping` and `handler` closures are optional. If `ModelTransfer` protocol is not used, `handler` closure is required, and registration looks like:

```swift
manager.register(View.self, for: Model.self) { mapping in

} handler: { view, model, indexPath in

}
```

When any of registration methods is called, `DTTableViewManager` does several things:

1. Create ViewModelMapping object, and immediately run `mapping` closure on it, to give you a chance to customize any values you need. Those may include custom xib name, custom reuse identifier and others.
2. Check whether xib-file with specified name(defaults to name of the View class) exists.
3. Register view(cell/header/footer view) with UITableView either using nib registration or registration from code.

## Dequeue

When it's time to dequeue registered view(which is determined by model type and mapping conditions, which you can read about in [Mapping](Mapping.md) document), several things happen:

1. View is dequeued from code/xib/storyboard.
2. Handler closure is called with view, model and indexPath.
3. If `View` conforms to `ModelTransfer` protocol, `update(with:)` method is called.

## Code

Registering cells to dequeue them from code:

```swift
manager.register(TableViewCell.self)
manager.register(UITableViewCell.self, for: Model.self) { cell, model, indexPath in }
```

Registering headers/footers to dequeue them from code:

manager.registerHeader(HeaderView.self)
manager.registerHeader(UITableViewHeaderFooterView.self, for: Model.self) { view, model, indexPath in }

manager.registerFooter(FooterView.self)
manager.registerFooter(UITableViewHeaderFooterView.self, for: Model.self) { view, model, indexPath in }
```

There's no need to explicitly specify that views are created from code, unless you have a xib file, which name exactly matches name of registered view, in which case you can explicitly set xibName parameter to nil to make sure view is created from code:

```swift
manager.register(TableViewCell.self) { mapping in
  mapping.xibName = nil
}
```

## Xib file

Creating views using xib-files follow the same syntax described in previous section, defaulting name of the xib file to the name of registered class. If you need to load view from xib with another name, you can specify that name in the mapping closure:

```swift
// If "PostCell.xib" exists, it will be used
manager.register(PostCell.self)

// If "CustomPostCell.xib" exists, it will be used
manager.register(PostCell.self) { mapping in
  mapping.xibName = "CustomPostCell"
}
```

For headers/footers, it's possible to register views, that inherit from `UIView`, not `UITableViewHeaderFooterView`. In this case, they will be loaded from xib with provided name(equal to name of the class by default). Please note though, that for such registrations, attaching events in mapping closure is not supported. Using `UITableViewHeaderFooterView` is recommended approach.

## Storyboard

Registering views, designed in storyboard, has the same syntax as in two previous sections of this document.

## Conditional mappings

It's possible to register views to work on specific conditions, such as concrete section, or model condition, which you can read more about in [Conditional mappings guide](Conditional%20mappings.md).

## Can I unregister mappings?

You can unregister cells, headers and footers from `DTTableViewManager` and `UITableView` by calling:

```swift
manager.unregister(FooCell.self)
manager.unregisterHeader(HeaderView.self)
manager.unregisterFooter(FooterView.self)
```

This is equivalent to calling table view register methods with nil class or nil nib. Please note, that all events tied to specified mapping are also removed.
