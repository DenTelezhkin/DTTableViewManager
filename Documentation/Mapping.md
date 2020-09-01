# Mapping

DTTableViewManager provides two ways two establish mapping between UITableViewCell/UITableViewHeaderFooterView and data model:

1. Through `ModelTransfer` protocol, provided by DTModelStorage framework.
2. Explicitly specifying both types at registration.

## ModelTransfer

`ModelTransfer` is a protocol, that your reusable views can conform to, which consists of a single method, that transfers data model to your view, providing an opportunity to update it's interface:

```swift
class FoodTableViewCell : UITableViewCell, ModelTransfer {
    func update(with model: Food) {
        // Display food in a cell
    }
}
```

Model can be of any type, value type, reference type, or even protocol:

```swift
protocol Food {}
class Apple : Food {}
class Carrot: Food {}
```

Registering such mapping is easy:

```swift
manager.register(FoodTableViewCell.self)
```

By doing so, `DTTableViewManager` establishes mapping between Food type and FoodTableViewCell.

Displaying two cells for those data models:

```swift
manager.memoryStorage.setItems([Apple(),Carrot()])
```

It's important to note, that when mapping is resolved, cell type is not available, storage only contains `Any` model. Therefore, when `DTTableViewManager` searches for mapping for this model, it tries to cast this model to any types that have been registered, and find appropriate match.

If you need same model type to resolve to different cells, you can use conditional mappings:

```swift
manager.register(VeganFoodTableViewCell.self) { mapping in
  mapping.condition = mapping.modelCondition { food, indexPath in
      food.isVegan
  }
}
manager.register(MeatContainingFoodTableViewCell.self) { mapping in
  mapping.condition = mapping.modelCondition { food, indexPath in
      food.containsMeat
  }
}
```

In both cases, those cells model is Food, but by providing specific mapping conditions, we can make sure, that only one mapping candidate is found when dequeueing cell for this model.

For more information on conditional mappings, head on to [Conditional mappings](Conditional%20mappings.md). To find out how mappings interact with delegate event closures, read more in [Events](Events.md).

## Without ModelTransfer

Although usage of `ModelTransfer` protocol is recommended, it's not required. You can register cells without explicitly transferring it's model, which is useful for simple cells(for example UITableViewCell with default styles /accessories):

```swift
manager.register(UITableViewCell.self, for: MenuItem.self) { mapping in
  mapping.didSelect { cell, model, indexPath in
    // did select menu item \(model) at \(indexPath)
  }
} handler: { cell, model, indexPath in
  cell.textLabel.text = model
}
```

In this kind of registration method, `handler` parameter is required, because there's no other way to update cell with it's data model.

## Headers/Footers

Headers/Footers support both kinds of mapping, with `ModelTransfer` protocol and without it:

```swift
manager.registerHeader(HeaderFooterView.self, ofKind: "Header")
manager.registerHeader(UITableViewHeaderFooterView.self, for: String.self) { header, model, indexPath in

}
```
