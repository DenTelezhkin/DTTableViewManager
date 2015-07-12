//
//  DTTableViewController.m
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

#import "DTTableViewController.h"
#import "DTTableViewFactory.h"
#import "DTMemoryStorage_DTTableViewManagerAdditions.h"

@interface DTTableViewController () <DTStorageUpdating, DTTableViewFactoryDelegate>

@property (nonatomic, assign) NSInteger currentSearchScope;
@property (nonatomic, copy) NSString * currentSearchString;
@property (nonatomic, retain) DTTableViewFactory * cellFactory;
@end

@implementation DTTableViewController

@synthesize storage = _storage;

#pragma mark - initialize, clean

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
    {
        [self setupTableViewControllerDefaults];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        [self setupTableViewControllerDefaults];
    }
    return self;
}

- (void)dealloc
{
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    self.searchBar.delegate = nil;
}

- (void)setupTableViewControllerDefaults
{
    _cellFactory = [DTTableViewFactory new];
    _cellFactory.delegate = self;

    _currentSearchScope = -1;
    _sectionHeaderStyle = DTTableViewSectionStyleTitle;
    _sectionFooterStyle = DTTableViewSectionStyleTitle;
    _insertSectionAnimation = UITableViewRowAnimationNone;
    _deleteSectionAnimation = UITableViewRowAnimationAutomatic;
    _reloadSectionAnimation = UITableViewRowAnimationAutomatic;

    _insertRowAnimation = UITableViewRowAnimationAutomatic;
    _deleteRowAnimation = UITableViewRowAnimationAutomatic;
    _reloadRowAnimation = UITableViewRowAnimationAutomatic;
    
    _displayFooterOnEmptySection = YES;
    _displayHeaderOnEmptySection = YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.searchBar.delegate = self;
}

#pragma mark - getters, setters

- (DTMemoryStorage *)memoryStorage
{
    if ([self.storage isKindOfClass:[DTMemoryStorage class]])
    {
        return (DTMemoryStorage *)self.storage;
    }
    return nil;
}

-(id<DTStorageProtocol>)storage
{
    if (!_storage)
    {
        DTMemoryStorage * storage = [DTMemoryStorage new];
        _storage = storage;
        [_storage setSupplementaryHeaderKind:DTTableViewElementSectionHeader];
        [_storage setSupplementaryFooterKind:DTTableViewElementSectionFooter];
        _storage.delegate = self;
    }
    return _storage;
}

- (void)setStorage:(id <DTStorageProtocol>)storage
{
    _storage = storage;
    _storage.delegate = self;
    [_storage setSupplementaryHeaderKind:DTTableViewElementSectionHeader];
    [_storage setSupplementaryFooterKind:DTTableViewElementSectionFooter];
}

- (void)setSearchingStorage:(id <DTStorageProtocol>)searchingStorage
{
    _searchingStorage = searchingStorage;
    _searchingStorage.delegate = self;
    [_searchingStorage setSupplementaryHeaderKind:DTTableViewElementSectionHeader];
    [_searchingStorage setSupplementaryFooterKind:DTTableViewElementSectionFooter];
}

#pragma mark - mapping

- (void)registerCellClass:(Class)cellClass forModelClass:(Class)modelClass
{
    NSParameterAssert([cellClass isSubclassOfClass:[UITableViewCell class]]);
    NSParameterAssert([cellClass conformsToProtocol:@protocol(DTModelTransfer)]);
    NSParameterAssert(modelClass);

    [self.cellFactory registerCellClass:cellClass forModelClass:modelClass];
}

- (void)registerHeaderClass:(Class)headerClass forModelClass:(Class)modelClass
{
    NSParameterAssert([headerClass conformsToProtocol:@protocol(DTModelTransfer)]);
    NSParameterAssert(modelClass);
    
    self.sectionHeaderStyle = DTTableViewSectionStyleView;

    [self.cellFactory registerHeaderClass:headerClass forModelClass:modelClass];
}

- (void)registerFooterClass:(Class)footerClass forModelClass:(Class)modelClass
{
    NSParameterAssert(footerClass);
    NSParameterAssert(modelClass);
    
    self.sectionFooterStyle = DTTableViewSectionStyleView;

    [self.cellFactory registerFooterClass:footerClass forModelClass:modelClass];
}

- (void)registerNibNamed:(NSString *)nibName forCellClass:(Class)cellClass modelClass:(Class)modelClass
{
    NSParameterAssert(nibName);
    NSParameterAssert([cellClass conformsToProtocol:@protocol(DTModelTransfer)]);
    NSParameterAssert(modelClass);

    [self.cellFactory registerNibNamed:nibName
                          forCellClass:cellClass
                            modelClass:modelClass];
}

- (void)registerNibNamed:(NSString *)nibName forHeaderClass:(Class)headerClass modelClass:(Class)modelClass
{
    NSParameterAssert(nibName);
    NSParameterAssert([headerClass conformsToProtocol:@protocol(DTModelTransfer)]);
    NSParameterAssert(modelClass);
    
    self.sectionHeaderStyle = DTTableViewSectionStyleView;

    [self.cellFactory registerNibNamed:nibName
                        forHeaderClass:headerClass
                            modelClass:modelClass];
}

- (void)registerNibNamed:(NSString *)nibName forFooterClass:(Class)footerClass modelClass:(Class)modelClass
{
    NSParameterAssert(nibName);
    NSParameterAssert([footerClass conformsToProtocol:@protocol(DTModelTransfer)]);
    NSParameterAssert(modelClass);
    
    self.sectionFooterStyle = DTTableViewSectionStyleView;

    [self.cellFactory registerNibNamed:nibName
                        forFooterClass:footerClass
                            modelClass:modelClass];
}

#pragma mark - search

- (BOOL)isSearching
{
    // If search scope is selected, we are already searching, even if dataset is all items
    if (((self.currentSearchString) && (![self.currentSearchString isEqualToString:@""]))
            ||
            self.currentSearchScope > -1)
    {
        return YES;
    }
    return NO;
}

- (void)filterTableItemsForSearchString:(NSString *)searchString
{
    [self filterTableItemsForSearchString:searchString inScope:-1];
}

- (void)filterTableItemsForSearchString:(NSString *)searchString
                                inScope:(NSInteger)scopeNumber
{
    BOOL wereSearching = [self isSearching];

    if (![searchString isEqualToString:self.currentSearchString] ||
            scopeNumber != self.currentSearchScope)
    {
        self.currentSearchScope = scopeNumber;
        self.currentSearchString = searchString;
    }
    else
    {
        return;
    }

    if (wereSearching && ![self isSearching])
    {
        [self.tableView reloadData];
        [self tableControllerDidCancelSearch];
        return;
    }
    if ([self.storage respondsToSelector:@selector(searchingStorageForSearchString:inSearchScope:)])
    {
        [self tableControllerWillBeginSearch];
        DTMemoryStorage * searchStorage =[self.storage searchingStorageForSearchString:searchString
                                                                         inSearchScope:scopeNumber];
        self.searchingStorage = (DTMemoryStorage *)searchStorage;
        [self.tableView reloadData];
        [self tableControllerDidEndSearch];
    }
}

- (id)headerModelForIndex:(NSInteger)index
{
    if ([self isSearching])
    {
        if ([[self.searchingStorage sections][index] numberOfObjects] || self.displayHeaderOnEmptySection)
        {
            if ([self.searchingStorage respondsToSelector:@selector(headerModelForSectionIndex:)])
            {
                return [(DTMemoryStorage *)self.searchingStorage headerModelForSectionIndex:index];
            }
        }
    }
    else
    {
        if ([[self.storage sections][index] numberOfObjects] || self.displayHeaderOnEmptySection)
        {
            if ([self.storage respondsToSelector:@selector(headerModelForSectionIndex:)])
            {
                return [(DTMemoryStorage *)self.storage headerModelForSectionIndex:index];
            }
        }
    }
    return nil;
}

- (id)footerModelForIndex:(NSInteger)index
{
    if ([self isSearching])
    {
        if ([[self.searchingStorage sections][index] numberOfObjects] || self.displayFooterOnEmptySection)
        {
            if ([self.searchingStorage respondsToSelector:@selector(footerModelForSectionIndex:)])
            {
                return [(DTMemoryStorage *)self.searchingStorage footerModelForSectionIndex:index];
            }
        }
    }
    else
    {
        if ([[self.storage sections][index] numberOfObjects] || self.displayFooterOnEmptySection)
        {
            if ([self.storage respondsToSelector:@selector(footerModelForSectionIndex:)])
            {
                return [(DTMemoryStorage *)self.storage footerModelForSectionIndex:index];
            }
        }
    }
    return nil;
}

#pragma mark - table delegate/data source implementation

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([self isSearching])
    {
        return [[self.searchingStorage sections] count];
    }
    else
    {
        return [[self.storage sections] count];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self isSearching])
    {
        id <DTSection> sectionModel = [self.searchingStorage sections][section];
        return [sectionModel numberOfObjects];
    }
    else
    {
        id <DTSection> sectionModel = [self.storage sections][section];
        return [sectionModel numberOfObjects];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)sectionNumber
{
    if (self.sectionHeaderStyle != DTTableViewSectionStyleTitle)
    {
        return nil;
    }

    return [self headerModelForIndex:sectionNumber];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)sectionNumber
{
    if (self.sectionFooterStyle != DTTableViewSectionStyleTitle)
    {
        return nil;
    }

    return [self footerModelForIndex:sectionNumber];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)sectionNumber
{
    if (self.sectionHeaderStyle == DTTableViewSectionStyleTitle)
    {
        return nil;
    }
    id model = [self headerModelForIndex:sectionNumber];

    if (!model)
    {
        return nil;
    }

    return [self.cellFactory headerViewForModel:model];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)sectionNumber
{
    if (self.sectionFooterStyle == DTTableViewSectionStyleTitle)
    {
        return nil;
    }
    id model = [self footerModelForIndex:sectionNumber];

    if (!model)
    {
        return nil;
    }

    return [self.cellFactory footerViewForModel:model];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)sectionNumber
{
    // Default table view section header titles, size defined by UILabel sizeToFit method
    if (self.sectionHeaderStyle == DTTableViewSectionStyleTitle)
    {
        if (![self headerModelForIndex:sectionNumber])
        {
            return CGFLOAT_MIN;
        }
        else
        {
            return UITableViewAutomaticDimension;
        }
    }

    // Custom table view headers
    if ([self headerModelForIndex:sectionNumber])
    {
        return self.tableView.sectionHeaderHeight;
    }
    else
    {
        return CGFLOAT_MIN;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)sectionNumber
{
    // Default table view section header titles, size defined by UILabel sizeToFit method
    if (self.sectionFooterStyle == DTTableViewSectionStyleTitle)
    {
        if (![self footerModelForIndex:sectionNumber])
        {
            return CGFLOAT_MIN;
        }
        else
        {
            return UITableViewAutomaticDimension;
        }
    }

    // Custom table view headers
    if ([self footerModelForIndex:sectionNumber])
    {
        return self.tableView.sectionFooterHeight;
    }
    else
    {
        return CGFLOAT_MIN;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id model = nil;
    if ([self isSearching])
    {
        model = [self.searchingStorage objectAtIndexPath:indexPath];
    }
    else
    {
        model = [self.storage objectAtIndexPath:indexPath];
    }

    return [self.cellFactory cellForModel:model atIndexPath:indexPath];
}

#pragma mark - actions

- (void) tableView:(UITableView *)tableView
moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath
       toIndexPath:(NSIndexPath *)destinationIndexPath
{
    DTMemoryStorage * storage = [self memoryStorage];
    if (!storage)
    {
        // silencing static analyzer =). This probably will never happen.
        return;
    }

    DTSectionModel * fromSection = [storage sections][sourceIndexPath.section];
    DTSectionModel * toSection = [storage sections][destinationIndexPath.section];
    id tableItem = fromSection.objects[sourceIndexPath.row];

    [fromSection.objects removeObjectAtIndex:sourceIndexPath.row];
    [toSection.objects insertObject:tableItem atIndex:destinationIndexPath.row];
}

#pragma  mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self filterTableItemsForSearchString:searchText];
}

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope
{
    [self filterTableItemsForSearchString:searchBar.text inScope:selectedScope];
}

#pragma mark - DTStorageUpdate delegate methods

- (void)storageDidPerformUpdate:(DTStorageUpdate *)update
{
    [self tableControllerWillUpdateContent];
    
    [self.tableView beginUpdates];

    [self.tableView deleteSections:update.deletedSectionIndexes
                  withRowAnimation:self.deleteSectionAnimation];
    [self.tableView insertSections:update.insertedSectionIndexes
                  withRowAnimation:self.insertSectionAnimation];
    [self.tableView reloadSections:update.updatedSectionIndexes
                  withRowAnimation:self.reloadSectionAnimation];

    [self.tableView deleteRowsAtIndexPaths:update.deletedRowIndexPaths
                          withRowAnimation:self.deleteRowAnimation];
    [self.tableView insertRowsAtIndexPaths:update.insertedRowIndexPaths
                          withRowAnimation:self.insertRowAnimation];
    [self.tableView reloadRowsAtIndexPaths:update.updatedRowIndexPaths
                          withRowAnimation:self.reloadRowAnimation];

    [self.tableView endUpdates];
    
    [self tableControllerDidUpdateContent];
}

- (void)storageNeedsReload
{
    [self tableControllerWillUpdateContent];
    
    [self.tableView reloadData];
    
    [self tableControllerDidUpdateContent];
}

- (void)performAnimatedUpdate:(void (^)(UITableView *))animationBlock
{
    animationBlock(self.tableView);
}

#pragma mark - DTTableViewControllerEvents protocol

-(void)tableControllerWillUpdateContent
{
    
}

-(void)tableControllerDidUpdateContent
{
    
}

-(void)tableControllerWillBeginSearch
{
    
}

-(void)tableControllerDidEndSearch
{
    
}

-(void)tableControllerDidCancelSearch
{
    
}

@end
