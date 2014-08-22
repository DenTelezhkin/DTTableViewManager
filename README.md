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
* Support for creating cells from code, XIBs or storyboards.
* Easy UITableView search 
* Core data / NSFetchedResultsController support

## Workflow

Here are 4 simple steps you need to use DTTableViewManager:

1. Your view controller should subclass `DTTableViewController`, and set tableView property.
2. You should have subclass of `DTTableViewCell`.
3. In your viewDidLoad method, call mapping methods to establish relationship between data models and UITableViewCells.
4. Add data models to memoryStorage, or use CoreData storage class.

## API quickstart

<table>
<tr><th colspan=2 style="text-align:center;">Key classes</th></tr>
	<tr>
	<td> DTTableViewController </td>
	<td>Your UIViewController, that presents tableView, needs to subclass* this class. This class implements all UITableViewDatasource methods.</td>
	</tr>
	<tr>
	<td>DTMemoryStorage</td>
	<td>Class responsible for holding tableView models. It is used as a default storage by DTTableViewManager.</td>
	</tr>
	<tr>
	<td>DTCoreDataStorage</td>
	<td>Class used to display data, using `NSFetchedResultsController`.</td>
	</tr>
	<tr>
	<td>DTSectionModel</td>
	<td> Object, representing section in UITableView. Basically has three properties - array of objects, headerModel and footerModel.</td>
	</tr>
<tr><th colspan=2 style="text-align:center;">Protocols</th></tr>
	<tr>
	<td>DTModelTransfer</td>
	<td> Protocol, which methods are used to transfer model to UITableViewCell subclass, that will be representing it.</td>
	</tr>
<tr><th colspan=2 style="text-align:center;">Convenience classes (optional)</th></tr>
	<tr>
	<td>DTTableViewCell</td>
	<td> UITableViewCell subclass, conforming to `DTModelTransfer` protocol. </td>
	</tr>
	<tr>
	<td>DTDefaultCellModel</td>
	<td>Custom model class, that allows to use UITableViewCell without subclassing.</td>
	</tr>
	<tr>
	<td>DTDefaultHeaderFooterModel</td>
	<td>Custom model class, that allows to use UITableViewHeaderFooterView without subclassing.</td>
	</tr>
</table>

* If you need your view controller to be subclassed from something else than DTTableViewController, it's good practice to use [UIViewController containment API](http://www.objc.io/issue-1/containment-view-controller.html), and embed DTTableViewController subclass as a child inside inside parent controller.

## Mapping

* Cells
```objective-c
[self registerCellClass:[Cell class] forModelClass:[Model class]];
```

* Headers/Footers
```objective-c
[self registerHeaderClass:[HeaderView class] forModelClass:[Model class]];
[self registerFooterClass:[FooterView class] forModelClass:[Model class]];
```

This will also register nibs with `Cell`, `HeaderView` and `FooterView` name, if any of them exist. 

#### Storyboards

If you use storyboards and prototype cells, you will need to set reuseIdentifier for corresponding cell in storyboard. Reuse identifier needs to be identical to your cell class name. 

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

* iOS 6.0 and later
* ARC
        
## Installation

Simplest option is to use [CocoaPods](http://www.cocoapods.org):

	pod 'DTTableViewManager', '~> 2.7.0'

## Documentation

You can view documentation online or you can install it locally using [cocoadocs](http://cocoadocs.org/docsets/DTTableViewManager)!

## Thanks

* [Alexey Belkevich](https://github.com/belkevich) for providing initial implementation of CellFactory.
* [Michael Fey](https://github.com/MrRooni) for providing insight into NSFetchedResultsController updates done right. 

