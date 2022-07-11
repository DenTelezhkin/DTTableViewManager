# SwiftUI in UITableViewCells

`DTTableViewManager` introduces support for rendering SwiftUI views in UITableViewCells starting with 11.x release.  Registering SwiftUI view is done similarly to registering usual cells:

```swift
manager.registerHostingCell(for: Post.self) { model, indexPath in
    PostSwiftUICell(model: model)
}
```

This functionality is supported on iOS 13 + / tvOS 13+ / macCatalyst 13+. It's important to understand, that this method of showing SwiftUI views in table / collection view cells is not supported by Apple, and has some hacks implemented to make it work.

Implementation for iOS 16+ method of showing SwiftUI views via hosting configuration (https://developer.apple.com/documentation/SwiftUI/UIHostingConfiguration) is hopefully coming a bit later.

Registration of SwiftUI views follows the same pattern as registering other table view cells, however there are some important distinctions:

* SwiftUI lifecycle management is done by special subclass of UITableViewCell - `HostingTableViewCell`, provided by `DTTableViewManager`.
* SwiftUI views need to be hosted in UIHostingController, which needs to be added as a child to view controller hierarchy, or appearance and sizing methods will not work in SwiftUI view. This is done automatically by `HostingTableViewCell`, but may have some unintended consequences, which you can read about below.
* Because SwiftUI views are generally self-sizing, it's recommended to use this approach with self-sizing UITableView.

Let's dive into those topics, as they are important to understand how to use this approach correctly.

# UIHostingController hacks

When SwiftUI view (it's UIHostingController) is added to view controller hierarchy, it tries to control several things that may be surprizing in context of UITableViewCell content:

* Navigation bar appearance
* Keyboard avoidance / safe area insets
* Other view controller behaviors I did not encounter yet

For example, in the app I'm working on, adding such hosted cell in view controller that had navigation bar hidden, immediately forced navigation bar to appear. In order to fix this problem, `DTTableViewManager` provides a way to customize `UIHostingController` used to host table view cells.

To always hide navigation bar in my view hierarchy, I implemented following subclass of UIHostingController (full credit to this answer on [StackOverflow answer](https://stackoverflow.com/questions/57627641/add-swiftui-view-to-an-uitableviewcell-contentview/68624676#68624676):

```swift
class ControlledNavigationHostingController<Content: View>: UIHostingController<Content> {

    public override init(rootView: Content) {
        super.init(rootView: rootView)
    }

    @objc dynamic required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
}
```

Using this subclass with `DTTableViewManager` requires modifiying hosting configuration, available via mapping closure:

```swift
manager.registerHostingCell(for: Post.self) { model, _ in
    PostSwiftUICell(model: model)
} mapping: { mapping in
    mapping.configuration.hostingControllerMaker = {
        ControlledNavigationHostingController(rootView: $0) 
    }
}
```

I'm assuming other potential issues, like keyboard avoidance, can also be solved by custom UIHostingController subclass, or swizzling UIHostingController methods. For example, here is [great article by Peter Steinberger](https://steipete.com/posts/disabling-keyboard-avoidance-in-swiftui-uihostingcontroller/), that shows how to disable keyboard avoidance for SwiftUI views embedded in table view or collection view cells.

# Parent view controller

`HostingTableViewCell` requires parent view controller to add SwiftUI to view controller hierarchy. `DTTableViewManager` provides default parent view controller by typecasting `DTTableViewManageable` instance to UIViewController type. If your class implementing `DTTableViewManageable` is a view controller, you don't need to do anything.

However, if `DTTableViewManageable` instance is not a view controller, you would need to specify parent view controller explicitly in mapping closure:
```swift
mapping.configuration.parentController = customParentViewController
```

# Determining cell size

Because SwiftUI views are generally self-sized, it's recommended to use self-sizing table view with them. To do that, use automatic height and provide estimated height for cell:

```swift
tableView.rowHeight = UITableView.automaticDimension

manager.registerHostingCell(for: Post.self) { model, _ in
    PostSwiftUICell(model: model)
} mapping: { mapping in
    mapping.estimatedHeightForCell { model, indexPath in
     100 // pick appropriate cell height 
    }
}
```

If you can't or don't want to use automatic cell sizing, make sure SwiftUI view and cells have equal heights, otherwise SwiftUI and autolayout system may fight and produce unexpected results.

# Cell state and tap events

While `HostingTableViewCell` hosts SwiftUI view, it does not communicate to `UITableView` with any special information on doing so. So, if for example, you simultaneously implement SwiftUI.Button in a cell, and .didSelect event (`tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)`), they will not play together nicely.

Instead, consider implementing `.onTapGesture` modifier on SwiftUI view and passing events through it's data model (view model would probably fit better here).

`HostingTableViewCell` also supresses selection state by default to prevent clashing of different cell states SwiftUI is not aware of (`UITableViewCell.SelectionStyle = .none`).

# Customizing hosting cell

`HostingTableViewCell` is designed to be just a container for SwiftUI view, so all it's views have background of UIColor.clear by default, and cell is not selectable. If you need, you can customize colors and selection state of the cell using configuration:

```swift
mapping.configuration.backgroundColor = customColor
mapping.configuration.contentViewBackgroundColor = customColor
mapping.configuration.hostingViewBackgroundColor = customColor

mapping.configuration.selectionStyle = .default
```

If you need any other changes on `HostingTableViewCell`, you can also provide a closure, that is run after all cell updates:

```swift
mapping.configuration.configureCell = { cell in
   // Customize cell
}
```

# Perfomance

Each cell creates only one hosting controller, that is reused when cell is updated with new data.

In order to preserve perfomance, background colors and selection state is set only once when cell is first created. When cell is being reused, only `configureCell` closure is called on each cell update.

# Is it worth it?

I leave answer to this question for your consideration, since Apple does not support this, and some hacks may be required to work with hosted cells.

For me, however, it was 100% worth it. After applying navigation bar hack, I've encountered no problems, and live previewing table view cells in different view states is super helpful in implementing complex views, and is overall much simpler and efficient than doing it in UIKit.

# What about delegate methods for hosted cells?

SwiftUI hosted cells support all delegate methods implemenented for non-hosted cells, for example:

```swift
manager.registerHostingCell(for: Post.self) { model, _ in
    PostSwiftUICell(model: model)
} mapping: { mapping in
    mapping.willDisplay { cell, model, indexPath in
    
    }
}
```

# Can I use SwiftUI in table view headers / footers?

It seems possible, and code infrastructure is prepared to implement SwiftUI views in table view headers and footers, but I'm not rushing there yet. It's possible there might be some more hacks there, and I'm not sure at this point, if it's worth doing that, since Apple only introduced support for cells in iOS 16.

However, I might reconsider this, if there's demand for this feature.

# When will DTTableViewManager support UIHostingConfiguration on iOS 16?

If everything goes well, in the next 11.x release.