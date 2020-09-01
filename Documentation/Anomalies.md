### Anomaly handler

`DTTableViewManager` is built on some conventions. For example, your cell needs to have reuseIdentifier that matches the name of your class, XIB files need to be named also identical to the name of your class(to work with default mapping without customization). However when those conventions are not followed, or something unexpected happens, your app may crash or behave inconsistently. Most of the errors are reported by `UITableView` API, but there's space to improve.

 `DTTableViewManager` as well as `DTCollectionViewManager` and `DTModelStorage` have dedicated anomaly analyzers, that try to find inconsistencies and programmer errors when using those frameworks. They detect stuff like missing mappings, inconsistencies in xib files, and even unused events. By default, detected anomalies will be printed in console while you are debugging your app. For example, if you try to register an empty xib to use for your cell, here's what you'll see in console:

```
⚠️[DTTableViewManager] Attempted to register xib EmptyXib for PostCell, but this xib does not contain any views.
```

Messages are prefixed, so for `DTTableViewManager` messages will have `[DTTableViewManager]` prefix.

By default, anomaly handler only prints information into console and does not do anything beyond that, but you can change it's behavior by assigning a custom handler for anomalies:

```swift
manager.anomalyHandler.anomalyAction = { anomaly in
  // invoke custom action
}
```

For example, you may want to send all detected anomalies to analytics you have in your app. For this case anomalies implement shorter description, that is more suitable for analytics, that often have limits for amount of data you can put in. To do that globally for all instances of `DTTableViewManager` that will be created during runtime of your app, set default action:

```swift
DTTableViewManagerAnomalyHandler.defaultAction = { anomaly in
  print(anomaly.debugDescription)

  analytics.postEvent("DTTableViewManager", anomaly.description)
}
```

If you use `DTTableViewManager` and `DTCollectionViewManager`, you can override 3 default actions for both manager frameworks and `DTModelStorage`, presumably during app initialization, before any views are loaded:

```swift
DTTableViewManagerAnomalyHandler.defaultAction = { anomaly in }
DTCollectionViewManagerAnomalyHandler.defaultAction = { anomaly in }
MemoryStorageAnomalyHandler.defaultAction = { anomaly in }
```

### Silencing anomalies

If you feel, that anomaly reported actually is not an anomaly, you can silence it for this specific case:

```swift
// silence single anomaly case
manager.anomalyHandler.silenceAnomaly(.nilCellModel(IndexPath(item: 0, section: 0)))

// silence several anomalies:
manager.anomalyHandler.silenceAnomaly { anomaly -> Bool in
    switch anomaly {
        case .nilCellModel, .unusedEventDetected: return true
        default: return false
    }
}
```
