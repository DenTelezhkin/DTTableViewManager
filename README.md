![Build Status](https://travis-ci.org/DenHeadless/DTTableViewManager.png?branch=master) &nbsp;
![CocoaPod platform](https://cocoapod-badges.herokuapp.com/p/DTTableViewManager/badge.png) &nbsp; 
![CocoaPod version](https://cocoapod-badges.herokuapp.com/v/DTTableViewManager/badge.png) &nbsp; 
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
![License MIT](https://go-shields.herokuapp.com/license-MIT-blue.png)

DTTableViewManager
================
> This is a sister-project for [DTCollectionViewManager](https://github.com/DenHeadless/DTCollectionViewManager) - great tool for UICollectionView management, built on the same principles.

Target of this project is to create powerful architecture for UITableView сontrollers. It combines several ideas to make UITableView management easy, clean, and delightful. 

Try it out! =)

```bash
pod try DTTableViewManager
```

## Features

* Powerful mapping system between data models and table view cells, headers and footers
* Automatic datasource and interface synchronization.
* Support for creating cells from XIBs or storyboards.
* Support for UITableViewHeaderFooterView or custom UIView for table headers and footers
* Easy UITableView search 
* Core data / NSFetchedResultsController support
* Swift support

## Quick start

Let's say you have an array of Posts you want to display in UITableView. To quickly show them using DTTableViewManager, here's what you need to do:

Subclass DTTableViewController, create xib, or storyboard with your view controller, wire up tableView outlet. Add following code to viewDidLoad:

```objective-c
[self registerCellClass:[PostCell class] forModelClass:[Post class]];
[self.memoryStorage addItems:posts];
```
or in Swift:
```swift
self.registerCellClass(PostCell.self, forModelClass:Post.self)
self.memoryStorage().addItems(posts)
```

Subclass DTTableViewCell, and implement updateWithModel method
```objective-c
-(void)updateWithModel:(id)model
{
    Post * post = model;
    self.postTextView.text = post.content;
}
```
or in Swift:
```swift
func updateWithModel(model: AnyObject!)
{
    let post = model as Post
    self.postTextView.text = post.content
}
```

That's it! For more detailed look at available API - **[API quickstart](https://github.com/DenHeadless/DTTableViewManager/wiki/API-quickstart)** page on wiki.

## Mapping and registration

Registering cell class and xib is 1 line of code:

```objective-c
[self registerCellClass:[Cell class] forModelClass:[Model class]];
```
Similarly, for headers and footers:

```objective-c
[self registerHeaderClass:[HeaderView class] forModelClass:[Model class]];
[self registerFooterClass:[FooterView class] forModelClass:[Model class]];
```

For more detailed look at mapping in DTTableViewManager, check out dedicated *[Mapping wiki page](https://github.com/DenHeadless/DTTableViewManager/wiki/Mapping)*.

## Managing table items

Storage classes for DTTableViewManager have been moved to [separate repo](https://github.com/DenHeadless/DTModelStorage). Two data storage classes are provided - memory and core data storage. 

### Memory storage

`DTMemoryStorage` encapsulates storage of table view data models in memory. It's basically NSArray of `DTSectionModel` objects, which contain array of objects for current section, section header and footer model.

**You can take a look at all provided methods for manipulating items here: [DTMemoryStorage methods](https://github.com/DenHeadless/DTModelStorage/blob/master/README.md#adding-items)**

DTTableViewManager adds several methods to `DTMemoryStorage`, that are specific to UITableView. Take a look at them here: **[DTMemoryStorage additions](https://github.com/DenHeadless/DTTableViewManager/wiki/DTMemoryStorage-additions)**

### NSFetchedResultsController and DTCoreDataStorage

`DTCoreDataStorage` is meant to be used with NSFetchedResultsController. It automatically monitors all NSFetchedResultsControllerDelegate methods and updates UI accordingly to it's changes. All you need to do to display CoreData models in your UITableView, is create DTCoreDataStorage object and set it on your DTTableViewController subclass.

```objective-c
self.dataStorage = [DTCoreDataStorage storageWithFetchResultsController:controller];
```

**Important** Keep in mind, that DTMemoryStorage is not limited to objects in memory. For example, if you have CoreData database, and you now for sure, that number of items is not big, you can choose not to use DTCoreDataStorage and NSFetchedResultsController. You can fetch all required models, and store them in DTMemoryStorage, just like you would do with NSObject subclasses.

##### Search

DTTableViewManager has a built-in search system, that is easy to use and flexible. Read all about it in a dedicated **[Implementing search](https://github.com/DenHeadless/DTTableViewManager/wiki/Implementing-search)** wiki page.	


## Requirements

* XCode 6.3 and higher
* iOS 7.x, 8.x
* ARC
        
## Installation

[CocoaPods](http://www.cocoapods.org):

    pod 'DTTableViewManager', '~> 3.1.0'
	
[Carthage](https://github.com/Carthage/Carthage):

    github "DenHeadless/DTTableViewManager"
    
Carthage uses dynamic frameworks, which require iOS 8 and higher. After running `carthage update` drop DTTableViewManager.framework and DTModelStorage.framework to XCode project embedded binaries.

## Documentation

You can view documentation online or you can install it locally using [cocoadocs](http://cocoadocs.org/docsets/DTTableViewManager)!

Also check out [wiki page](https://github.com/DenHeadless/DTTableViewManager/wiki) for lot's of information on DTTableViewManager internals and best practices.

## Thanks

* [Alexey Belkevich](https://github.com/belkevich) for providing initial implementation of CellFactory.
* [Michael Fey](https://github.com/MrRooni) for providing insight into NSFetchedResultsController updates done right. 
* [Nickolay Sheika](https://github.com/hawk-ukr) for great feedback, that helped shaping 3.0 release.
