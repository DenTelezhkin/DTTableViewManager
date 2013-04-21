//
//  DTTableViewManager.h
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 6/19/12.
//  Copyright (c) 2012 MLSDev. All rights reserved.
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
#import "DTTableViewCellCreation.h"

/**
 `DTTableViewManager` manages all `UITableView` datasource methods and provides API for managing your data models in the table. 
 
 ## Setup
 
 # General steps
 - You should have custom `UITableViewCell` subclasses that manage cell layout, using given data model.
 - Every cell class should be mapped to model class using mapping methods.
 - `UITableView` delegate should be set to DTTableViewManager object.
 
 # Subclassing
 
 This is recommended and easier approach. In this case `UITableView` delegate and datasource is your controller. Any `UITableViewDatasource` and `UITableViewDelegate` method can be overridden in your controller.
 
 # Separate manager
 
 This is needed, when your controller inherits from custom class, and you need to have `DTTableViewManager` as a separate object. In this case you should create `DTTableViewManager` object using [DTTableViewManager managerWithDelegate:andTableView:], and make it a property in your controller. Current implementation sets `UITableView`'s delegate and datasource property to `DTTableViewManager` object. Delegate methods are then trampolined to your controller if it implements them.
 
 There's a `DTTableViewCellCreation` protocol that can be used to modify cell after it has been created.
 
 ## Managing table items
 
 Every action that is done to table items - add, delete, insert etc. is applied immediately. There's no need to manually reload data on your table view. Group insertion, addition or deletion is processed inside `UITableView` `beginUpdates` and `endUpdates` block.
 
 ## Loading cells from NIB
 
 `DTTableViewManager` internally uses `registerNib:forCellReuseIdentifier:` method for making this happen, which requires iOS 5.0 and higher to work. Use setCellMappingForNib:cellClass:modelClass: for mapping NIB to cell class and model. 
 
 Discussion. Before executing setCellMappingForNib:cellClass:modelClass:, make sure that tableView property is set and tableView is created. Good spot to call setCellMappingForNib:cellClass:modelClass: is in viewDidLoad method.
 
 ## Loading headers/footers from NIB
 
 To register custom NIB for header/footer use methods `setHeaderMappingForNibName:headerClass:modelClass:` and `setFooterMappingForNibName:footerClass:modelClass:` methods. 
 For iOS 6 and higher, UITableView's `registerNib:forHeaderFooterViewReuseIdentifier:` will be used. For iOS 5, `DTTableViewManager` will use `loadFromNibName:bundle:` method.
 
 To set header/footer models on the  tableView, use `setHeaderModels:` and `setFooterModels:` method.
 
 */

@interface DTTableViewManager : UIViewController
                                     <UITableViewDataSource, UITableViewDelegate>

///---------------------------------------
/// @name Properties
///---------------------------------------

/**
 
 Table view that will present your data models.
 */

@property (nonatomic, strong) IBOutlet UITableView * tableView;


/**
 Set this property to YES if you don't want to reuse cells.
 
 @warning By default, `reuseIdentifier` for cells is set to `NSStringFromClass(<model class>)`
 */
@property (nonatomic,assign) BOOL doNotReuseCells;


///---------------------------------------
/// @name Initialization
///---------------------------------------

/**
 Initializer for DTTableViewManager. Can be used when you are using it as a separate object.
 
 @param delegate Your controller, that wishes to get delegate and datasource calls from `DTTableViewManager`.
 
 @param tableView tableView on your controller you want to manager.
 
 @return DTTableViewManager object
 */
-(id)initWithDelegate:(id <UITableViewDelegate>)delegate andTableView:(UITableView *)tableView;

/**
 Returns autoreleased DTTableViewManager object. Can be used when you are using it as a separate object.
 
 @param delegate Your controller, that wishes to get delegate and datasource calls from `DTTableViewmanager`.
 
 @param tableView tableView on your controller you want to manager.
 
 @return autoreleased DTTableViewManager object
 */
+(id)managerWithDelegate:(id <UITableViewDelegate>)delegate andTableView:(UITableView *)tableView;

///---------------------------------------
/// @name Search
///---------------------------------------

/**
 If item exists at `indexPath`, it's model will be returned. If section or row does not exist, method will return `nil`.
 
 @param indexPath Index of the item you wish to retrieve. 
 
 @return model at indexPath. If section or row does not exist - `nil`.
 */
- (id)tableItemAtIndexPath:(NSIndexPath *)indexPath;
//this method returns lowest index item, that is equal to tableItem

/**
 Searches for tableItem and returns it's indexPath. If there are many equal tableItems, indexPath of the first one will be returned
 
 @param tableItem Model of the item you wish to find.
 
 @return indexPath of `tableItem`.If there are many equal tableItems, indexPath of the first one will be returned
 */
- (NSIndexPath *)indexPathOfTableItem:(NSObject *)tableItem;

/**
 Searches for tableItems and returns `NSArray` of their indexPaths.
 
 @param tableItems Array of tableItems, that need to be found.
 
 @discussion If tableItem not found, `NSNull` object is added to indexPaths array. That means you shouldn't call this method if you are not sure, that all tableItems exist. This method uses `indexPathOfTableItem:` internally.
 
 @return Array of tableItem's indexes. If at least one tableItem was not found - `nil`.
 */
- (NSArray *)indexPathArrayForTableItems:(NSArray *)tableItems;

/**
 Returns array of table items at indexPaths.
 
 @param indexPaths indexPaths of array you want to find.
 
 @discussion if `indexPath` is not found, `NSNull` object is added instead of the table item. This method uses `tableItemAtIndexPath:` internally.
 
 @return array of table items at indexPaths
 */
- (NSArray *)tableItemsArrayForIndexPaths:(NSArray *)indexPaths;

/**
 Returns array with table items in section
 
 @param section Number of the section in table.
 
 @return array of table items in section. Empty array if section does not exist.
 */
- (NSArray *)tableItemsInSection:(int)section;

/**
 Returns number of sections, contained in `DTTableViewManager`.

 @return number of sections in `DTTableViewManager`.
 */
- (int)numberOfSections;

/**
 Returns number of table items in a given `section`.
 
 @param section section, which items will be counted.
 
 @return number of table items in a given `section`. 0, if section does not exist
 */
- (int)numberOfTableItemsInSection:(NSInteger)section;

///---------------------------------------
/// @name Section headers/footers
///---------------------------------------

/**
 Sets sections header titles, using `headerTitles` array. Titles must be `NSString` type. 
 
 @param headerTitles header titles for all sections of the table.
 
 @discussion This method is identical to implementing `tableView:titleForHeaderInSection:` datasource method. If you want to have custom section header view, use usual `UITableView` delegate methods.
 */
- (void)setSectionHeaderTitles:(NSArray *)headerTitles;

/**
 Sets sections header models. Header model class should be previously registered with `setHeaderMappingForNibName:headerClass:modelClass:` method. 
 
 @param headerModels header models for all sections of the table.
 
 @discussion This method is used to set header models. `DTTableViewManager` will then load NIB, registered for headerClass and will call `updateWithModel:` method on each header object. On iOS 5, view will be loaded using loadFromNibName:bundle: method. On iOS 6, if registered header class subclassed from UITableViewHeaderFooterView, it'll use iOS6 `registerNib:forHeaderFooterViewReuseIdentifier:` method.
 */
- (void)setSectionHeaderModels:(NSArray *)headerModels;

/**
 Sets sections footer titles, using `footerTitles` array. Titles must be `NSString` type.
 
 @param footerTitles footer titles for all sections of the table.
 
 @discussion These method is identical to implementing `tableView:titleForFooterInSection:` datasource method. If you want to have custom section footer view, use usual `UITableView` delegate methods.
 */
- (void)setSectionFooterTitles:(NSArray *)footerTitles;

/**
 Sets sections footer models. Footer model class should be previously registered with `setFooterMappingForNibName:headerClass:modelClass:` method.
 
 @param footerModels footer models for all sections of the table.
 
 @discussion This method is used to set footer models. `DTTableViewManager` will then load NIB, registered for footerClass and will call `updateWithModel:` method on each footer object. On iOS 5, view will be loaded using loadFromNibName:bundle: method. On iOS 6, if registered footer class subclassed from UITableViewHeaderFooterView, it'll use iOS6 `registerNib:forHeaderFooterViewReuseIdentifier:` method.
 */
- (void)setSectionFooterModels:(NSArray *)footerModels;

///---------------------------------------
/// @name Add table items
///---------------------------------------

/**
 Add tableItem to section 0. Table will be automatically updated with UITableViewRowAnimationNone.
 
 @param tableItem Model you want to add to the table
 */
- (void)addTableItem:(NSObject *)tableItem;

/**
 Add table items to section 0. Table will be automatically updated using UITableViewRowAnimationNone.
 
 @param tableItems models to add.
 */
- (void)addTableItems:(NSArray *)tableItems;

/**
 Add table items to section `section`. Table will be automatically updated using UITableViewRowAnimationNone.
 
 @param tableItem Model to add.
 
 @param section Section, where item will be added
 */
- (void)addTableItem:(NSObject *)tableItem toSection:(NSInteger)section;

/**
 Add table items to section `section`. Table will be automatically updated using UITableViewRowAnimationNone.
 
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
- (void)moveSection:(int)indexFrom toSection:(int)indexTo;

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
 Reloads one or more sections in the receiver, with `animation` animation.
 
 @param indexSet An index set that specifies the sections to reload from the receiving table view. 
 
 @param animation Row animation style to be used when reloading sections.
 */
- (void)reloadSections:(NSIndexSet *)indexSet withRowAnimation:(UITableViewRowAnimation)animation;


///---------------------------------------
/// @name Mapping
///---------------------------------------

/**
 This method is used to set mapping from model class to custom cell class. 
 
 @param cellClass Class of the cell you want to be created for model with modelClass.
 
 @param modelClass Class of the model you want to be mapped to cellClass.
 
 @discussion This is the designated mapping method. It can be called anywhere, but probably the best place to call - is in your controller -init method. Inner implementation of this method trampolines mapping to DTCellFactory. You can also call this method of DTCellFactory as well.
 
 */
-(void)setCellMappingforClass:(Class)cellClass modelClass:(Class)modelClass;

/**
 This method is used to set mapping from model to custom cell created from XIB with `nibName` name. Cell data is then populated by `cellClass` class.
 
 @param nibName Name of custom XIB that is used to create a cell.
 
 @param cellClass Class of the cell you want to be created for model with modelClass.
 
 @param modelClass Class of the model you want to be mapped to cellClass.
 
 @warning This method needs to be called after tableView has been created, in `viewDidLoad`, for example. This method uses UITableView `registerNib:forCellReuseIdentifier:` underneath.
 
 */
-(void)setCellMappingForNib:(NSString *)nibName
                  cellClass:(Class)cellClass
                 modelClass:(Class)modelClass;

/**
 Use this method to set mapping from model to custom header view with `nibName` name. `headerClass` object is called with `updateWithModel:` method to update presentation of header view.
 
 @param nibName Name of custom XIB that is used to create a header.
 
 @param headerClass Class of the header you want to be created for model with modelClass.
 
 @param modelClass Class of the model you want to be mapped to headerClass.
 
 @warning If you are building for iOS 5, use UIView subclass, for iOS 6 and higher you can use UITableViewHeaderFooterView with reuse capability. `DTTableViewManager` will automatically figure out which class is used.
 
 */
-(void)setHeaderMappingForNibName:(NSString *)nibName
                      headerClass:(Class)headerClass
                       modelClass:(Class)modelClass;

/**
 Use this method to set mapping from model to custom footer view with `nibName` name. `footerClass` object is called with `updateWithModel:` method to update presentation of footer view.
 
 @param nibName Name of custom XIB that is used to create a footer.
 
 @param footerClass Class of the footer you want to be created for model with modelClass.
 
 @param modelClass Class of the model you want to be mapped to footerClass.
 
 @warning If you are building for iOS 5, use UIView subclass, for iOS 6 and higher you can use UITableViewHeaderFooterView with reuse capability. `DTTableViewManager` will automatically figure out which class is used.
 
 */
-(void)setFooterMappingForNibName:(NSString *)nibName
                      footerClass:(Class)footerClass
                       modelClass:(Class)modelClass;



@end
