## TableViewConfiguration

`TableViewConfiguration` is a class, available on `DTTableViewManager` instance through `configuration` property, that allows you to customize several aspects of `UITableView` and `DTTableViewManager` behaviors.

#### Displaying headers/footers on empty sections

If you don't want table view section headers to show, if data model for those sections is nil, set `displayHeaderOnEmptySections` property to false:

```swift
manager.configuration.displayHeaderOnEmptySections = false
manager.configuration.displayFooterOnEmptySections = false
```

#### Section styles

`UITableView` has two ways of displaying section headers and footers - as a view and as a title. In the latter case, `String` model is used to show section title.

`DTTableViewManager` defaults to using `.title` style, but automatically switches to `.view` style if you register a view for header or footer. You can control those behaviors:

```swift
manager.configuration.sectionHeaderStyle = .title
manager.configuration.sectionFooterStyle = .view
```

#### Semantic heights

`DTTableViewManager` implements `tableView(_:heightForHeaderInSection:)` and `tableView(_:heightForFooterInSection:)` delegate methods with several behaviors:

1. Checks .displayHeader/displayFooterOnEmptySections property on `TableViewConfiguration` instance
2. Checks whether header/footer model is not nil
3. Checks whether TableViewConfiguration.sectionHeader/FooterStyle is title or view.
4. Checks whether UITableView.Style is .plain or .grouped.

Depending on all of those, `DTTableViewManager` attempts to automatically return appropriate height for header/footer.

This semantic height calculation can be nice, but can be an obstacle, especially if you have a lot of sections, and therefore a lot of section headers/footers, which may hurt performance, if you are not using self-sized headers/footers. In order to give you control, this behavior can be turned off:

```swift
manager.configuration.semanticHeaderHeight = false
manager.configuration.semanticFooterHeight = false
```

When those properties are turned off, `DTTableViewManager` will pretend that `tableView(_:heightForHeaderInSection:)` and `tableView(_:heightForFooterInSection:)` delegate methods are not implemented(unless you specify reaction closure through `heightForHeader/Footer` methods or implement delegate methods yourself).

#### Minimal heights

If the height needs to be .zero, `UITableView` actually expects different values for .grouped(CGFloat.leastNormalMagnitude) and .plain(CGFloat.zero) styles. Those zero heights can be customized through `minimalHeader/FooterHeightForTableView` properties.
