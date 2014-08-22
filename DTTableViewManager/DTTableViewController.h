//
//  DTTableViewController.h
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 10/24/13.
//  Copyright (c) 2013 MLSDev. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "DTModelTransfer.h"
#import "DTTableViewDataStorage.h"
#import "DTMemoryStorage_DTTableViewManagerAdditions.h"
#import "DTSectionModel+HeaderFooterModel.h"

typedef NS_ENUM(NSUInteger,DTTableViewSectionStyle)
{
    DTTableViewSectionStyleTitle = 1,
    DTTableViewSectionStyleView
};

/**
 `DTTableViewController` manages all `UITableView` datasource methods and provides API for managing your data models in the table. 
 
 ## Setup
 
 # General steps
 - You should have custom `UITableViewCell` subclasses that manage cell layout, using given data model (or `DTTableViewCell`, which is UITableViewCell subclass, that conforms to `DTModelTransfer` protocol)
 - Every cell class should be mapped to model class using mapping methods.
 - `UITableView` datasource and delegate is your `DTTableViewController` subclass.
 - If you need CoreData storage, you should create DTTableViewCoreDataStorage and assign it to `dataStorage` property.
  
 ## Managing table items
 
 Depending on data storage you choose to have, table items can be managed differently. But the pattern is the same - `DTTableViewController` reacts to changes in data storage object and updates table view appropriately. `DTTableViewManager` provides two data storage classes - `DTMemoryStorage` and `DTTableViewCoreDataStorage`. `DTMemoryStorage` is used by default.
 
 ## Mapping cells
 
 Use `registerCellClass:forModelClass` for mapping cell class to model. 'DTTableViewController' will automatically check, if there's a nib with the same name as cellClass. If it is - this nib is registered for modelClass. If there's no nib - then cell will be created using initWithStyle: method on cellClass. If you need nib name for the cell to differ from cellClass name, use `registerNibName:forCellClass:modelClass:`.
 
 Before executing mapping methods, make sure that tableView property is set and tableView is created. Good spot to call `registerCellClass:forModelClass` is in viewDidLoad method.

 ## Search
 
 Search implementation depends on what data storage you use. In both cases it's recommended to use this class as UISearchBarDelegate. Then searching data storage will be created automatically for every change in UISearchBar.
 
 # DTMemoryStorage
 
Call memoryStorage setSearchingBlock:forModelClass: to determine, whether model of passed class should show for current search criteria. This method can be called as many times as you need.
 
 # DTCoreDataStorage
 
 Subclass DTCoreDataStorage and implement single method: -searchingStorageForSearchString:inSearchScope:. You will need to provide a storage with NSFetchedResultsController and appropriate NSPredicate.
 
 ## Loading headers/footers from NIB
 
 To register custom NIB for header/footer use methods `registerHeaderClass:modelClass:` and `registerFooterClass:modelClass:` methods. If nib name is different from the class name, use `registerNibName:forHeaderClass:modelClass:` or `registerNibName:forFooterClass:modelClass:` method.
 
 You can use either UITableViewHeaderFooterView or a simple UIView,`DTTableViewManager` will automatically figure, how view should be loaded.
 
 ### Examples and questions
 
 I recommend looking through provided examples https://github.com/DenHeadless/DTTableViewManager . I tried to cover most interesting and often use cases for table view that you might encounter.
 
 If you still are missing something, feel free to contact me or create issue on github!
*/

@interface DTTableViewController : UIViewController
                                       <UITableViewDataSource,
                                        UITableViewDelegate,
                                        UISearchBarDelegate,
                                        DTStorageUpdating>

///---------------------------------------
/// @name Properties
///---------------------------------------

/**
 Table view that will present your data models.
 */
@property (nonatomic, strong) IBOutlet UITableView * tableView;


/**
 Data storage object. Create storage you need and set this property to populate table view with data. `DTTableViewManager` provides two data storage classes - `DTTableViewStorage` and `DTTableViewCoreDataStorage`. DTTableViewMemory storage used by default.
 */

@property (nonatomic, strong) id <DTStorage> dataStorage;


/**
 Convenience method, returning memory storage. If custom storage is used, this method will return nil.
 
 @return DTMemoryStorage instance.
 */
- (DTMemoryStorage *)memoryStorage;


/**
 Searching data storage object. It will be created automatically, responding to changes in UISearchBar, or after method filterTableItemsForSearchString:inScope: is called.
 */

@property (nonatomic, strong) id <DTStorage> searchingDataStorage;

/*
 Property to store UISearchBar, attached to your UITableView. Attaching it to this property is completely optional.
 */
@property (nonatomic, strong) IBOutlet UISearchBar * searchBar;

/**
 Style of section headers for table view. Depending on style, datasource methods will return title for section or view for section. Default is DTTableViewSectionStyleTitle.
 */

@property (nonatomic, assign) DTTableViewSectionStyle sectionHeaderStyle;

/**
 Style of section footers for table view. Depending on style, datasource methods will return title for section or view for section. Default is DTTableViewSectionStyleTitle.
 */
@property (nonatomic, assign) DTTableViewSectionStyle sectionFooterStyle;

/**
 Determines, whether header should be displayed, if section does not contain any items. Default value is YES.
 */
@property (nonatomic, assign) BOOL displayHeaderOnEmptySection;

/**
 Determines, whether footer should be displayed, if section does not contain any items. Default value is YES.
 */
@property (nonatomic, assign) BOOL displayFooterOnEmptySection;

/**
 Animation, used for inserting sections. Default - UITableViewRowAnimationNone.
 */

@property (nonatomic, assign) UITableViewRowAnimation insertSectionAnimation;

/**
 Animation, used for deleting sections. Default - UITableViewRowAnimationAutomatic.
 */

@property (nonatomic, assign) UITableViewRowAnimation deleteSectionAnimation;

/**
 Animation, used for reloading sections. Default - UITableViewRowAnimationAutomatic.
 */
@property (nonatomic, assign) UITableViewRowAnimation reloadSectionAnimation;

/**
 Animation, used for inserting table view rows. Default - UITableViewRowAnimationAutomatic.
 */
@property (nonatomic, assign) UITableViewRowAnimation insertRowAnimation;

/**
 Animation, used for deleting table view rows. Default - UITableViewRowAnimationAutomatic.
 */
@property (nonatomic, assign) UITableViewRowAnimation deleteRowAnimation;

/**
 Animation, used for reloading table view rows. Default - UITableViewRowAnimationAutomatic.
 */
@property (nonatomic, assign) UITableViewRowAnimation reloadRowAnimation;

///---------------------------------------
/// @name Mapping
///---------------------------------------

/**
 This method is used to register mapping from model class to custom cell class. It will automatically check for nib with the same name as `cellClass`. If it exists - nib will be registered instead of class.
 
 @param cellClass Class of the cell you want to be created for model with modelClass.
 
 @param modelClass Class of the model you want to be mapped to cellClass.
 
 @discussion This is the designated mapping method. Best place to call it - in viewDidLoad method.
 
 */
-(void)registerCellClass:(Class)cellClass forModelClass:(Class)modelClass;

/**
 This method is used, when your NIB for cell has a different name than `cellClass`. Otherwise you should use `registerCellClass:forModelClass:` method.
 
 @param nibName Name of XIB that is used to create a cell.
 
 @param cellClass Class of the cell you want to be created for model with modelClass.
 
 @param modelClass Class of the model you want to be mapped to `cellClass`.
 */
-(void)registerNibNamed:(NSString *)nibName
           forCellClass:(Class)cellClass
             modelClass:(Class)modelClass;

/**
 This method registers nib with `headerClass` name. `headerClass` should be a UIView subclass, conforming to `DTModelTransfer` protocol. On iOS 6 it can be a subclass of `UITableViewHeaderFooterView` for reusability.
 
 @param headerClass headerClass to be mapped for `modelClass`
 
 @param modelClass modelClass to be mapped to `headerClass`
 */

-(void)registerHeaderClass:(Class)headerClass forModelClass:(Class)modelClass;

/**
 This method registers nib with `nibName` name. `headerClass` should be a UIView subclass, conforming to `DTModelTransfer` protocol. On iOS 6 it can be a subclass of `UITableViewHeaderFooterView` for reusability.
 
 @param nibName Name of custom XIB that is used to create a header.
 
 @param headerClass headerClass to be mapped for `modelClass`
 
 @param modelClass modelClass to be mapped to `headerClass`
 */
-(void)registerNibNamed:(NSString *)nibName
         forHeaderClass:(Class)headerClass
             modelClass:(Class)modelClass;

/**
 This method registers nib with `footerClass` name. `footerClass` should be a UIView subclass, conforming to `DTModelTransfer` protocol. On iOS 6 it can be a subclass of `UITableViewHeaderFooterView` for reusability.
 
 @param footerClass footerClass to be mapped for `modelClass`
 
 @param modelClass modelClass to be mapped to `footerClass`
 */

-(void)registerFooterClass:(Class)footerClass forModelClass:(Class)modelClass;

/**
 This method registers nib with `nibName` name. `footerClass` should be a UIView subclass, conforming to `DTModelTransfer` protocol. On iOS 6 it can be a subclass of `UITableViewHeaderFooterView` for reusability.
 
 @param nibName Name of custom XIB that is used to create a header.
 
 @param footerClass footerClass to be mapped for `modelClass`
 
 @param modelClass modelClass to be mapped to `footerClass`
 */
-(void)registerNibNamed:(NSString *)nibName
         forFooterClass:(Class)footerClass
             modelClass:(Class)modelClass;

///---------------------------------------
/// @name Search
///---------------------------------------

/**
 This method filters presented table items, using searchString as a criteria. Current dataStorage is queried with `searchingStorageForSearchString:inSearchScope:` method. If searchString is not empty, UITableViewDataSource is assigned to searchingDataStorage and table view is reloaded automatically.
 
 @param searchString Search string used as a criteria for filtering.
 */
-(void)filterTableItemsForSearchString:(NSString *)searchString;

/**
 This method filters presented table items, using searchString as a criteria. Current dataStorage is queried with `searchingStorageForSearchString:inSearchScope:` method. If searchString or scopeNUmber is not empty, UITableViewDataSource is assigned to searchingDataStorage and table view is reloaded automatically.
 
 @param searchString Search string used as a criteria for filtering.
 
 @param scopeNumber Scope number of UISearchBar
 */
-(void)filterTableItemsForSearchString:(NSString *)searchString
                               inScope:(NSInteger)scopeNumber;

/**
 Returns whether search is active, based on current searchString and searchScope, retrieved from UISearchBarDelegate methods.
 */

-(BOOL)isSearching NS_REQUIRES_SUPER;

/**
 This method allows to perform animations you need for changes in UITableView. It can be used for complex animations, that should be run simultaneously. For example, `DTTableViewManagerAdditions` category on `DTMemoryStorage` uses it to implement moving items between indexPaths.
 
 @param animationBlock AnimationBlock to be executed with UITableView.
 
 @warning You need to update data storage object before executing this method.
 */
- (void)performAnimatedUpdate:(void (^)(UITableView *))animationBlock;


@end
