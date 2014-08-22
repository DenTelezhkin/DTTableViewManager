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
#import "DTCellFactory.h"
#import "DTMemoryStorage_DTTableViewManagerAdditions.h"
#import "DTTableViewDataStorage.h"

@interface DTTableViewController ()
        <DTTableViewFactoryDelegate>

@property (nonatomic, assign) NSInteger currentSearchScope;
@property (nonatomic, copy) NSString * currentSearchString;
@property (nonatomic, retain) DTCellFactory * cellFactory;
@end

@implementation DTTableViewController

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
    _cellFactory = [DTCellFactory new];
    _cellFactory.delegate = self;

    _dataStorage = [DTMemoryStorage storage];
    _dataStorage.delegate = self;

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
}

#pragma mark - getters, setters

- (DTMemoryStorage *)memoryStorage
{
    if ([self.dataStorage isKindOfClass:[DTMemoryStorage class]])
    {
        return (DTMemoryStorage *)self.dataStorage;
    }
    return nil;
}

- (void)setDataStorage:(id <DTTableViewDataStorage>)dataStorage
{
    _dataStorage = dataStorage;
    _dataStorage.delegate = self;
}

- (void)setSearchingDataStorage:(id <DTTableViewDataStorage>)searchingDataStorage
{
    _searchingDataStorage = searchingDataStorage;
    _searchingDataStorage.delegate = self;
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

    [self.cellFactory registerHeaderClass:headerClass forModelClass:modelClass];
}

- (void)registerFooterClass:(Class)footerClass forModelClass:(Class)modelClass
{
    NSParameterAssert(footerClass);
    NSParameterAssert(modelClass);

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

    [self.cellFactory registerNibNamed:nibName
                        forHeaderClass:headerClass
                            modelClass:modelClass];
}

- (void)registerNibNamed:(NSString *)nibName forFooterClass:(Class)footerClass modelClass:(Class)modelClass
{
    NSParameterAssert(nibName);
    NSParameterAssert([footerClass conformsToProtocol:@protocol(DTModelTransfer)]);
    NSParameterAssert(modelClass);

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
        return;
    }
    if ([self.dataStorage respondsToSelector:@selector(searchingStorageForSearchString:inSearchScope:)])
    {
        self.searchingDataStorage = [(DTMemoryStorage *)self.dataStorage searchingStorageForSearchString:searchString
                                                                                                    inSearchScope:scopeNumber];
        [self.tableView reloadData];
    }
}

- (id)headerModelForIndex:(NSInteger)index
{
    if ([self isSearching])
    {
        if ([[self.searchingDataStorage sections][index] numberOfObjects] || self.displayHeaderOnEmptySection)
        {
            if ([self.searchingDataStorage respondsToSelector:@selector(headerModelForSectionIndex:)])
            {
                return [(DTMemoryStorage *)self.searchingDataStorage headerModelForSectionIndex:index];
            }
        }
    }
    else
    {
        if ([[self.dataStorage sections][index] numberOfObjects] || self.displayHeaderOnEmptySection)
        {
            if ([self.dataStorage respondsToSelector:@selector(headerModelForSectionIndex:)])
            {
                return [(DTMemoryStorage *)self.dataStorage headerModelForSectionIndex:index];
            }
        }
    }
    return nil;
}

- (id)footerModelForIndex:(NSInteger)index
{
    if ([self isSearching])
    {
        if ([[self.searchingDataStorage sections][index] numberOfObjects] || self.displayFooterOnEmptySection)
        {
            if ([self.searchingDataStorage respondsToSelector:@selector(footerModelForSectionIndex:)])
            {
                return [(DTMemoryStorage *)self.searchingDataStorage footerModelForSectionIndex:index];
            }
        }
    }
    else
    {
        if ([[self.dataStorage sections][index] numberOfObjects] || self.displayFooterOnEmptySection)
        {
            if ([self.dataStorage respondsToSelector:@selector(footerModelForSectionIndex:)])
            {
                return [(DTMemoryStorage *)self.dataStorage footerModelForSectionIndex:index];
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
        return [[self.searchingDataStorage sections] count];
    }
    else
    {
        return [[self.dataStorage sections] count];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self isSearching])
    {
        id <DTSection> sectionModel = [self.searchingDataStorage sections][section];
        return [sectionModel numberOfObjects];
    }
    else
    {
        id <DTSection> sectionModel = [self.dataStorage sections][section];
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
            return 0;
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
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)sectionNumber
{
    // Default table view section header titles, size defined by UILabel sizeToFit method
    if (self.sectionFooterStyle == DTTableViewSectionStyleTitle)
    {
        if (![self footerModelForIndex:sectionNumber])
        {
            return 0;
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
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id model = nil;
    if ([self isSearching])
    {
        model = [self.searchingDataStorage objectAtIndexPath:indexPath];
    }
    else
    {
        model = [self.dataStorage objectAtIndexPath:indexPath];
    }

    return [self.cellFactory cellForModel:model];
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
}

- (void)performAnimatedUpdate:(void (^)(UITableView *))animationBlock
{
    animationBlock(self.tableView);
}

@end
