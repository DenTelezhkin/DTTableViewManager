# Conditional mappings

Conditional mappings is a feature, that allows you to specify, where this mapping will be active. It's useful in cases, where you want the same data model to be displayed in different cells or using different layouts.

## Section condition

Section condition allows you to limit mapping to a single section:

```swift
manager.register(PostCell.self) { mapping in
  // This mapping will only be used in PostCell.ModelType is displayed in first section
  mapping.condition = .section(0)
}
```

## Model condition

Model condition gives you fine-grained control over which mapping is used:

```swift
manager.register(OddCell.self) { mapping in
  mapping.condition = mapping.modelCondition { model, indexPath in
    return indexPath.item.isOdd
  }
}
```

## Limitations

Keep in mind, that while `DTTableViewManager` implements conditional mappings, `UITableView` does not have a clue, that this is happening. This may cause issues in several cases, shown below:

##### Matching reuse identifiers

```swift
manager.register(PostCell.self) { mapping in
  mapping.condition = .section(0)
}

mapping.register(PostCell.self) { mapping in
  mapping.condition = .section(1)
  mapping.xibName = "CustomPostCell"
}
```

In this example we are trying to show two different designs of cells in first and second section. The issue is, even if we have different xib names, reuse identifier for both of those registrations is the same - "PostCell". So when the cell is dequeued, the last registration would be used by `UITableView`, breaking the first mapping. Appropriate fix for this situation would be setting custom reuseIdentifier:

```swift
manager.register(PostCell.self) { mapping in
  mapping.condition = .section(0)
}

mapping.register(PostCell.self) { mapping in
  mapping.condition = .section(1)
  mapping.xibName = "CustomPostCell"
  mapping.reuseIdentifier = "custom-post-cell"
}
```

This way cells would get registered under different reuse identifiers, and dequeue will work correctly.

##### Intersecting model conditions

```swift
manager.register(PostCell.self)

manager.register(VideoPostCell.self) { mapping in
  mapping.condition = mapping.modelCondition { indexPath, model in
    return model.containsVideo
  }
}
```

In this case, we have two mappings for the same data model - `Post`. Second mapping needs to work when post contains video, and first mapping - in other cases. The issue here is that first mapping does not have condition, and therefore when `DTTableViewManager` starts searching for mapping for post with Video, it finds two mappings instead of one. The first mapping would be used, which, in this case, is incorrect.

The fix to this would be to use mapping conditions, that don't intersect between each other:

```swift
manager.register(PostCell.self) { mapping in
  mapping.condition = mapping.modelCondition { indexPath, model in
    return !model.containsVideo
  }
}

manager.register(VideoPostCell.self) { mapping in
  mapping.condition = mapping.modelCondition { indexPath, model in
    return model.containsVideo
  }
}
```
