![Build Status](https://travis-ci.org/DenHeadless/DTTableViewManager.png?branch=master) &nbsp;
![CocoaPod platform](https://cocoapod-badges.herokuapp.com/p/DTTableViewManager/badge.png) &nbsp; 
![CocoaPod version](https://cocoapod-badges.herokuapp.com/v/DTTableViewManager/badge.png) &nbsp; 
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
[self registerCellClass:[Post class] forModelClass:[PostCell class]];
[self.memoryStorage addItems:posts];
```
or in Swift:
```swift
self.registerCellClass(Post.self, forModelClass:PostCell.self)
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

That's it! For more detailed look at available API - [API quickstart](https://github.com/DenHeadless/DTTableViewManager/wiki/API-quickstart) page on wiki.

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

For more detailed look at mapping in DTTableViewManager, check out dedicated [Mapping wiki page](https://github.com/DenHeadless/DTTableViewManager/wiki/Mapping).

## Managing table items

Storage classes for DTTableViewManager have been moved to [separate repo](https://github.com/DenHeadless/DTModelStorage). Two data storage classes are provided - memory and core data storage. Let's start with `DTMemoryStorage`, that is used by default.

### Memory storage

`DTMemoryStorage` encapsulates storage of table view data models in memory. It's basically NSArray of `DTSectionModel` objects, which contain array of objects for current section, section header and footer model.

To work with memory storage, you will need to get it's instance from your `DTTableViewController` subclass.

```objective-c
- (DTMemoryStorage *)memoryStorage;
```

**You can take a look at all provided methods for manipulating items here: [DTMemoryStorage methods](https://github.com/DenHeadless/DTModelStorage/blob/master/README.md#adding-items)**

In most cases, adding items to memory storage is as simple as calling:

```objective-c
- (void)addItem:(NSObject *)item;
- (void)addItems:(NSArray *)items toSection:(NSInteger)sectionNumber;
```

DTTableViewManager adds several methods to `DTMemoryStorage`, that are specific to UITableView. Two most relevant of them are 

```objective-c
- (void)setSectionHeaderModels:(NSArray *)headerModels;
- (void)setSectionFooterModels:(NSArray *)footerModels;
```
These methods allow setting header and footer models for multiple sections in single method call.

##### Search
	
Set UISearchBar's delegate property to your `DTTableViewController` subclass. 	

Call memoryStorage setSearchingBlock:forModelClass: to determine, whether model of passed class should show for current search criteria. This method can be called as many times as you need.
```objective-c
[self.memoryStorage setSearchingBlock:^BOOL(id model, NSString *searchString, NSInteger searchScope, DTSectionModel *section) 
	{
        Example * example  = model;
        if ([example.text rangeOfString:searchString].location == NSNotFound)
        {
            return NO;
        }
        return YES;
    } forModelClass:[Example class]];
```

Searching data storage will be created automatically for current search, and it will be used as a datasource for UITableView.
	
### Core Data storage

`DTCoreDataStorage` is meant to be used with NSFetchedResultsController. It automatically monitors all NSFetchedResultsControllerDelegate methods and updates UI accordingly to it's changes. All you need to do to display CoreData models in your UITableView, is create DTCoreDataStorage object and set it on your DTTableViewController subclass.

```objective-c
self.dataStorage = [DTCoreDataStorage storageWithFetchResultsController:controller];
```	

##### Search

Subclass DTCoreDataStorage and implement single method 
```objective-c
- (instancetype)searchingStorageForSearchString:(NSString *)searchString
                                  inSearchScope:(NSInteger)searchScope;
```	

You will need to provide a storage with NSFetchedResultsController and appropriate NSPredicate. Take a look at example application, that does just that.

## Requirements

* iOS 7.x, 8.x
* ARC
        
## Installation

Simplest option is to use [CocoaPods](http://www.cocoapods.org):

	pod 'DTTableViewManager', '~> 2.7.0'

## Documentation

You can view documentation online or you can install it locally using [cocoadocs](http://cocoadocs.org/docsets/DTTableViewManager)!

## Thanks

* [Alexey Belkevich](https://github.com/belkevich) for providing initial implementation of CellFactory.
* [Michael Fey](https://github.com/MrRooni) for providing insight into NSFetchedResultsController updates done right. 

