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

#import "DTTableViewModelTransfer.h"
#import "DTTableViewModelSearching.h"
#import "DTTableViewDataStorage.h"

typedef NS_ENUM(NSUInteger,DTTableViewSectionStyle)
{
    DTTableViewSectionStyleTitle = 1,
    DTTableViewSectionStyleView
};

/**
 `DTTableViewController` manages all `UITableView` datasource methods and provides API for managing your data models in the table. 
 
 ## Setup
 
 # General steps
 - You should have custom `UITableViewCell` subclasses that manage cell layout, using given data model (or `DTTableViewCell`, which is UITableViewCell subclass, that conforms to `DTTableViewModelTransfer` protocol)
 - Every cell class should be mapped to model class using mapping methods.
 - `UITableView` datasource and delegate is your `DTTableViewController` subclass.
  
 ## Managing table items
 
 Every action that is done to table items - add, delete, insert etc. is applied immediately. There's no need to manually reload data on your table view. Group insertion, addition or deletion is processed inside `UITableView` `beginUpdates` and `endUpdates` block. All methods for tableItems manipulation will automatically update both original tableView and filtered tableView, when search is active.
 
 ## Mapping cells
 
 Use `registerCellClass:forModelClass` for mapping cell class to model. 'DTTableViewController' will automatically check, if there's a nib with the same name as cellClass. If it is - this nib is registered for modelClass. If there's no nib - then cell will be created using initWithStyle: method on cellClass. If you need nib name for the cell to differ from cellClass name, use `registerNibName:forCellClass:modelClass:`.
 
 Before executing mapping methods, make sure that tableView property is set and tableView is created. Good spot to call `registerCellClass:forModelClass` is in viewDidLoad method.

 ## Search
 
 Your data models should conform to `DTTableViewModelSearching` protocol. You need to implement method shouldShowInSearchResultsForSearchString:inScopeIndex: on your data model, this way DTTableViewController will know, when to show data models.
 
 # Automatic
 
Set UISearchBar's delegate property to your `DTTableViewController` subclass. That's it, you've got search implemented!
 
 # Manual
 
 Any time you need your models sorted, call method filterTableItemsForSearchString:. Every data model in the table will be called with method shouldShowInSearchResultsForSearchString:inScopeIndex: and tableView will be automatically updated with results.
 
 ## Loading headers/footers from NIB
 
 To register custom NIB for header/footer use methods `registerHeaderClass:modelClass:` and `registerFooterClass:modelClass:` methods. If nib name is different from the class name, use `registerNibName:forHeaderClass:modelClass:` or `registerNibName:forFooterClass:modelClass:` method.
 
 For iOS 6 and higher, UITableView's `registerNib:forHeaderFooterViewReuseIdentifier:` will be used. 
 
 To set header/footer models on the  tableView, use `sectionHeaderModels` and `sectionFooterModels` properties. Keep in mind, there's no public method to reload header/footer views, so after header/footer models are set, you will need to manually reload table with `reloadData` or `reloadSections:withRowAnimation` method.
*/

@interface DTTableViewController : UIViewController
                                       <UITableViewDataSource,
                                        UITableViewDelegate,
                                        UISearchBarDelegate,
                                        DTTableViewDataStorageUpdating>

///---------------------------------------
/// @name Properties
///---------------------------------------

/**
 
 Table view that will present your data models.
 */
@property (nonatomic, strong) IBOutlet UITableView * tableView;

/**
 Data storage object. DTTableViewMemory storage used by default.
 */

@property (nonatomic, strong) id <DTTableViewDataStorage> dataStorage;

@property (nonatomic, strong) id <DTTableViewDataStorage> searchingDataStorage;

/*
 Property to store UISearchBar, attached to your UITableView. Attaching it to this property is completely optional.
 */
@property (nonatomic, strong) IBOutlet UISearchBar * searchBar;

/**
 Array of NSString header titles, used in UITableViewDatasource `tableView:titleForHeaderInSection:` method.
 */
@property (nonatomic,strong) NSMutableArray * sectionHeaderTitles;

/**
 Array of NSString footer titles, used in UITableViewDatasource `tableView:titleForFooterInSection:` method.
 */
@property (nonatomic,strong) NSMutableArray * sectionFooterTitles;

/**
 Array of header models, used in UITableViewDelegate `tableView:viewForHeaderInSection:` method. All views, that will be created for these models, should conform to `DTTableViewModelTransfer` protocol and will be called with `updateWithModel:` method. After header/footer models are set, you will need to manually reload table with `reloadData` or `reloadSections:withRowAnimation` method.
 */
@property (nonatomic,strong) NSMutableArray * sectionHeaderModels;

/**
 Array of footer models, used in UITableViewDelegate `tableView:viewForFooterInSection:` method. All views, that will be created for these models, should conform to `DTTableViewModelTransfer` protocol and will be called with `updateWithModel:` method. After header/footer models are set, you will need to manually reload table with `reloadData` or `reloadSections:withRowAnimation` method.
 */
@property (nonatomic,strong) NSMutableArray * sectionFooterModels;

@property (nonatomic, assign) DTTableViewSectionStyle sectionHeaderStyle;
@property (nonatomic, assign) DTTableViewSectionStyle sectionFooterStyle;

@property (nonatomic, assign) UITableViewRowAnimation insertSectionAnimation;
@property (nonatomic, assign) UITableViewRowAnimation deleteSectionAnimation;
@property (nonatomic, assign) UITableViewRowAnimation reloadSectionAnimation;

@property (nonatomic, assign) UITableViewRowAnimation insertRowAnimation;
@property (nonatomic, assign) UITableViewRowAnimation deleteRowAnimation;
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
 This method registers nib with `headerClass` name. `headerClass` should be a UIView subclass, conforming to `DTTableViewModelTransfer` protocol. On iOS 6 it can be a subclass of `UITableViewHeaderFooterView` for reusability.
 
 @param headerClass headerClass to be mapped for `modelClass`
 
 @param modelClass modelClass to be mapped to `headerClass`
 */

-(void)registerHeaderClass:(Class)headerClass forModelClass:(Class)modelClass;

/**
 This method registers nib with `nibName` name. `headerClass` should be a UIView subclass, conforming to `DTTableViewModelTransfer` protocol. On iOS 6 it can be a subclass of `UITableViewHeaderFooterView` for reusability.
 
 @param nibName Name of custom XIB that is used to create a header.
 
 @param headerClass headerClass to be mapped for `modelClass`
 
 @param modelClass modelClass to be mapped to `headerClass`
 */
-(void)registerNibNamed:(NSString *)nibName
         forHeaderClass:(Class)headerClass
             modelClass:(Class)modelClass;

/**
 This method registers nib with `footerClass` name. `footerClass` should be a UIView subclass, conforming to `DTTableViewModelTransfer` protocol. On iOS 6 it can be a subclass of `UITableViewHeaderFooterView` for reusability.
 
 @param footerClass footerClass to be mapped for `modelClass`
 
 @param modelClass modelClass to be mapped to `footerClass`
 */

-(void)registerFooterClass:(Class)footerClass forModelClass:(Class)modelClass;

/**
 This method registers nib with `nibName` name. `footerClass` should be a UIView subclass, conforming to `DTTableViewModelTransfer` protocol. On iOS 6 it can be a subclass of `UITableViewHeaderFooterView` for reusability.
 
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
 This method filters presented table items, using searchString as a criteria. All table items are queried with method `shouldShowInSearchResultsForSearchString:
 inScopeIndex:`. All models, which return YES to that method, will be displayed. This method is used, when you want to sort table items manually. If you want to do that automatically, simply set UISearchBarDelegate to your DTTableViewController subclass and this method will get called automatically, when search bar text changes. 
 
 @param searchString Search string used as a criteria for filtering.
 */
-(void)filterTableItemsForSearchString:(NSString *)searchString;

/**
 This method filters presented table items, using searchString and scopeNumber as a criteria. All table items are queried with method `shouldShowInSearchResultsForSearchString:
 inScopeIndex:`. All models, which return YES to that method, will be displayed. This method is used, when you want to sort table items manually. If you want to do that automatically, simply set UISearchBarDelegate to your DTTableViewController subclass and this method will get called automatically, when search bar text or scope changes.
 
 @param searchString Search string used as a criteria for filtering.
 
 @param scopeNumber Scope number of UISearchBar
 */
-(void)filterTableItemsForSearchString:(NSString *)searchString
                               inScope:(NSInteger)scopeNumber;

/**
 If item exists at `indexPath`, it's model will be returned. If section or row does not exist, method will return `nil`. If this method is called when search is active, it will return model with indexPath in filtered table.
 
 @param indexPath Index of the item you wish to retrieve. 
 
 @return model at indexPath. If section or row does not exist - `nil`.
 */
- (id)tableItemAtIndexPath:(NSIndexPath *)indexPath;

/**
 If item exists at `indexPath`, it's model will be returned. If section or row does not exist, method will return `nil`. This method always returns tableItem, using indexPath for original array, not depending on whether search is active or not.
 
 @param indexPath Index of the item you wish to retrieve.
 
 @return model at indexPath. If section or row does not exist - `nil`.
 */
-(id)tableItemAtOriginalIndexPath:(NSIndexPath *)indexPath;

//this method returns lowest index item, that is equal to tableItem

/**
 Searches for tableItem and returns it's indexPath. If there are many equal tableItems, indexPath of the first one will be returned. If this method is called when search is active, it will return indexPath of the item in filtered table.
 
 @param tableItem Model of the item you wish to find.
 
 @return indexPath of `tableItem`. If there are many equal tableItems, indexPath of the first one will be returned.
 */
- (NSIndexPath *)indexPathOfTableItem:(NSObject *)tableItem;

/**
 Searches for tableItem and returns it's indexPath. If there are many equal tableItems, indexPath of the first one will be returned. This method always returns indexPath for original array, not depending on whether search is active or not.
 
 @param tableItem Model of the item you wish to find.
 
 @return indexPath of `tableItem`. If there are many equal tableItems, indexPath of the first one will be returned.
 */
- (NSIndexPath *)originalIndexPathOfTableItem:(NSObject *)tableItem;

/**
 Searches for tableItems and returns `NSArray` of their indexPaths. If search is active, this method will return NSArray of indexPaths in filtered table.
 
 @param tableItems Array of tableItems, that need to be found.
 
 @discussion This method uses `indexPathOfTableItem:` internally. If table item is not found, it's skipped.
 
 @return Array of tableItem's indexes, that were found.
 */
- (NSArray *)indexPathArrayForTableItems:(NSArray *)tableItems;

/**
 Searches for tableItems and returns `NSArray` of their indexPaths. This method always returns indexPaths for original array, not depending on whether search is active or not.
 
 @param tableItems Array of tableItems, that need to be found.
 
 @discussion This method uses `indexPathOfTableItem:` internally. If table item is not found, it's skipped.
 
 @return Array of tableItem's indexes, that were found.
 */
- (NSArray *)originalIndexPathArrayOfTableItems:(NSArray *)tableItems;

/**
 Returns array with table items in section. If search is active, this method will return tableItems in filtered table. Section numbers may differ, since empty sections are not shown in search results.
 
 @param section Number of the section in table.
 
 @return array of table items in section. Empty array if section does not exist.
 */
- (NSArray *)tableItemsInSection:(NSInteger)section;

/**
 Returns array with table items in section. Always returns original section, not depending on whether search is active or not.
 
 @param section Number of the section in table.
 
 @return array of table items in section. Empty array if section does not exist.
 */
-(NSArray *)tableItemsInOriginalSection:(NSInteger)section;

/**
 Returns number of sections, contained in `DTTableViewController`. When search is active, will return number of sections in filtered table.

 @return number of sections in `DTTableViewController`.
 */
- (NSInteger)numberOfSections;

/**
 Returns number of sections, contained in `DTTableViewController`. This method will return number of sections for original section, not depending on search results.
 
 @return number of sections in `DTTableViewController`.
 */
-(NSInteger)numberOfOriginalSections;

/**
 Returns number of table items in a given `section`. This method will use original table, not depending on whether search is active or not.
 
 @param section section, which items will be counted.
 
 @return number of table items in a given `section`. 0, if section does not exist
 */
- (NSInteger)numberOfTableItemsInOriginalSection:(NSInteger)section;

///---------------------------------------
/// @name Add table items
///---------------------------------------

/**
 Add tableItem to section 0. Table will be automatically updated with `UITableViewRowAnimationNone` animation.
 
 @param tableItem Model you want to add to the table
 */
- (void)addTableItem:(NSObject *)tableItem;

/**
 Add table items to section 0. Table will be automatically updated using `UITableViewRowAnimationNone`` animation.
 
 @param tableItems models to add.
 */
- (void)addTableItems:(NSArray *)tableItems;

/**
 Add table items to section `section`. Table will be automatically updated using `UITableViewRowAnimationNone` animation.
 
 @param tableItem Model to add.
 
 @param section Section, where item will be added
 */
- (void)addTableItem:(NSObject *)tableItem toSection:(NSInteger)section;

/**
 Add table items to section `section`. Table will be automatically updated using `UITableViewRowAnimationNone` animation.
 
 @param tableItems Models to add.
 
 @param section Section, where items will be added
 */
- (void)addTableItems:(NSArray *)tableItems
            toSection:(NSInteger)section;
/**
 Add table item to section 0. Table will be automatically updated using `animation` style.
 
 @param tableItem Model to add
 
 @param animation Animation that will be applied when item is added.
 */
- (void)addTableItem:(NSObject *)tableItem withRowAnimation:(UITableViewRowAnimation)animation;

/**
 Add table items to section 0. Table will be automatically updated using `animation` style.
 
 @param tableItems Models to add.
 
 @param animation Animation that will be applied when items are added.
 */
- (void)addTableItems:(NSArray *)tableItems withRowAnimation:(UITableViewRowAnimation)animation;

/**
 Checking, if item already exists in table, if not - adding it. Table will be automatically updated using `animation` style.
 
 @param tableItems Models to add
 
 @param section Section, where items will be added
 
 @param animation Animation that will be applied when items are added.
 */
-(void)addNonRepeatingItems:(NSArray *)tableItems
                  toSection:(NSInteger)section
           withRowAnimation:(UITableViewRowAnimation)animation;
/**
 Add table item to section `section`. Table will be automatically updated using `animation` style.
 
 @param tableItem model to add.
 
 @param section Section, where item will be added
 
 @param animation Animation that will be applied when item is added.
 */
- (void)addTableItem:(NSObject *)tableItem
           toSection:(NSInteger)section
    withRowAnimation:(UITableViewRowAnimation)animation;

/**
 Add table items to section `section`. Table will be automatically updated using `animation` style.
 
 @param tableItems models to add.
 
 @param section Section, where item will be added
 
 @param animation Animation that will be applied when items are added.
 */
- (void)addTableItems:(NSArray *)tableItems
            toSection:(NSInteger)section
     withRowAnimation:(UITableViewRowAnimation)animation;


///---------------------------------------
/// @name Insert table items
///---------------------------------------

/**
 Insert table item to indexPath `indexPath`. Table will be automatically updated using `UITableViewRowAnimationNone` style. 
 
 @param tableItem model to insert.
 
 @param indexPath Index, where item should be inserted.
 
 @warning Inserting item at index, that is not occupied, will not throw an exception, and won't do anything, except logging into console about failure
 */
- (void)insertTableItem:(NSObject *)tableItem toIndexPath:(NSIndexPath *)indexPath;


/**
 Insert table item to indexPath `indexPath`. Table will be automatically updated using `animation` style.
 
 @param tableItem model to insert.
 
 @param indexPath Index, where item should be inserted.
 
 @param animation Animation that will be applied when items are inserted.
 
 @warning Inserting item at index, that is not occupied, will not throw an exception, and won't do anything, except logging into console about failure
 */
- (void)insertTableItem:(NSObject *)tableItem toIndexPath:(NSIndexPath *)indexPath
       withRowAnimation:(UITableViewRowAnimation)animation;

///---------------------------------------
/// @name Reload table items
///---------------------------------------

/**
 Reload UITableViewCell, that currently displays `tableItem`.
 
 @param tableItem model, which needs to be reloaded in the cell
 
 @param animation animation, that will be applied while cell is reloading
 */

-(void)reloadTableItem:(NSObject *)tableItem withRowAnimation:(UITableViewRowAnimation)animation;

/**
 Reload UITableViewCells, that currently display `tableItems`.
 
 @param tableItems models, that need to be reloaded in the cells
 
 @param animation animation, that will be applied while cells are reloading
 */

-(void)reloadTableItems:(NSArray *)tableItems withRowAnimation:(UITableViewRowAnimation)animation;

///---------------------------------------
/// @name Replace table items
///---------------------------------------

/**
 Replace tableItemToReplace with replacingTableItem. Table is immediately updated with `UITableViewRowAnimationNone` animation. If tableItemToReplace is not found, or replacingTableItem is `nil`, this method does nothing. 
 
 @param tableItemToReplace Model object you want to replace.
 
 @param replacingTableItem Model object you are replacing it with.
 */
- (void)replaceTableItem:(NSObject *)tableItemToReplace
           withTableItem:(NSObject *)replacingTableItem;

/**
 Replace tableItemToReplace with replacingTableItem. Table is immediately updated with `animation` animation. If tableItemToReplace is not found, or replacingTableItem is `nil`, this method does nothing.
 
 @param tableItemToReplace Model object you want to replace.
 
 @param replacingTableItem Model object you are replacing it with.
 
 @param animation Row animation style to be used while replacing item.
 */
- (void)replaceTableItem:(NSObject *)tableItemToReplace
           withTableItem:(NSObject *)replacingTableItem
         andRowAnimation:(UITableViewRowAnimation)animation;

///---------------------------------------
/// @name Removing table items
///---------------------------------------

/**
 Removing tableItem. Table is immediately updated with `UITableViewRowAnimationNone` animation. If tableItem is not found,  this method does nothing.
 
 @param tableItem Model object you want to remove.
 */
- (void)removeTableItem:(NSObject *)tableItem;

/**
 Removing tableItem. Table is immediately updated with `animation` animation. If tableItem is not found,  this method does nothing.
 
 @param tableItem Model object you want to remove.
 
 @param animation Row animation style to be used while replacing item.
 */
- (void)removeTableItem:(NSObject *)tableItem withRowAnimation:(UITableViewRowAnimation)animation;

/**
 Removing tableItems. All deletions are made inside beginUpdates and endUpdates tableView block. After all deletions are made, `UITableViewRowAnimationNone` animation is applied. If some tableItem is not found, it is skipped.
 
 @param tableItems Models you want to remove.
 */
- (void)removeTableItems:(NSArray *)tableItems;

/**
 Removing tableItems. All deletions are made inside beginUpdates and endUpdates tableView block. After all deletions are made, `animation` animation is applied. If some tableItem is not found, it is skipped.
 
 @param tableItems Models you want to remove.
 
 @param animation Row animation style to be used while replacing item.
 */
- (void)removeTableItems:(NSArray *)tableItems withRowAnimation:(UITableViewRowAnimation)animation;

/**
 Removes all tableItems. Table view data is reloaded using reloadData method.
 */
- (void)removeAllTableItems;

///---------------------------------------
/// @name Managing sections
///---------------------------------------

/**
 Moves a section to a new location in the table view.
 
 @param indexFrom The index of the section to move.
 
 @param indexTo The index in the table view that is the destination of the move for the section. The existing section at that location slides up or down to an adjoining index position to make room for it.
 */
- (void)moveSection:(NSInteger)indexFrom toSection:(NSInteger)indexTo;

/**
 Deletes one or more sections in the receiver, with `UITableViewRowAnimationNone` animation. 
 
 @param indexSet An index set that specifies the sections to delete from the receiving table view. If a section exists after the specified index location, it is moved up one index location.
 */
- (void)deleteSections:(NSIndexSet *)indexSet;

/**
 Deletes one or more sections in the receiver, with `animation` animation.
 
 @param indexSet An index set that specifies the sections to delete from the receiving table view. If a section exists after the specified index location, it is moved up one index location.
 
 @param animation Row animation style to be used while deleting sections.
 */
- (void)deleteSections:(NSIndexSet *)indexSet withRowAnimation:(UITableViewRowAnimation)animation;

/**
 Method to enable/disable logging. Logging is on by default, and will print out any critical messages, that DTTableViewController is encountering. Call this method, if you want to turn logging off. It is enough to call this method once, and this value will be used by all instances of DTTableViewController.
 
  @param isEnabled Flag, that indicates, whether logging is enabled.
 */
+(void)setLogging:(BOOL)isEnabled;

+(BOOL)loggingEnabled;

@end
