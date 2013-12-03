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
 Method to enable/disable logging. Logging is on by default, and will print out any critical messages, that DTTableViewController is encountering. Call this method, if you want to turn logging off. It is enough to call this method once, and this value will be used by all instances of DTTableViewController.
 
  @param isEnabled Flag, that indicates, whether logging is enabled.
 */

/**
 Returns whether search is active, based on current searchString and searchScope, retrieved from UISearchBarDelegate methods.
 */

-(BOOL)isSearching;


+(void)setLogging:(BOOL)isEnabled;

+(BOOL)loggingEnabled;

@end
