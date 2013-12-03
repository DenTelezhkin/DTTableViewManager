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
#import "DTTableViewSectionModel.h"
#import "DTTableViewMemoryStorage.h"

@interface DTTableViewController ()
<DTTableViewFactoryDelegate>

@property (nonatomic, assign) int currentSearchScope;
@property (nonatomic, copy) NSString * currentSearchString;
@property (nonatomic, retain) DTCellFactory * cellFactory;
@end

static BOOL loggingEnabled = YES;

@implementation DTTableViewController

#pragma mark - initialize, clean

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
    {
        [self setup];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        [self setup];
    }
    return self;
}

-(void)dealloc
{
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    self.searchBar.delegate = nil;
}

-(void)setup
{
    _currentSearchScope = -1;
    _sectionHeaderStyle = DTTableViewSectionStyleTitle;
    _sectionFooterStyle = DTTableViewSectionStyleTitle;
    _insertSectionAnimation = UITableViewRowAnimationNone;
    _deleteSectionAnimation = UITableViewRowAnimationAutomatic;
    _reloadSectionAnimation = UITableViewRowAnimationAutomatic;
    
    _insertRowAnimation = UITableViewRowAnimationAutomatic;
    _deleteRowAnimation = UITableViewRowAnimationAutomatic;
    _reloadRowAnimation = UITableViewRowAnimationAutomatic;
    
    _dataStorage = [DTTableViewMemoryStorage storageWithDelegate:self];
}

#pragma mark - getters, setters

-(DTCellFactory *)cellFactory {
    if (!_cellFactory)
    {
        _cellFactory = [DTCellFactory new];
        _cellFactory.delegate = self;
    }
    return _cellFactory;
}

#pragma mark - mapping

-(void)registerCellClass:(Class)cellClass forModelClass:(Class)modelClass
{
    [self.cellFactory registerCellClass:cellClass forModelClass:modelClass];
}

-(void)registerHeaderClass:(Class)headerClass forModelClass:(Class)modelClass
{
    [self.cellFactory registerHeaderClass:headerClass forModelClass:modelClass];
}

-(void)registerFooterClass:(Class)footerClass forModelClass:(Class)modelClass
{
    [self.cellFactory registerFooterClass:footerClass forModelClass:modelClass];
}

-(void)registerNibNamed:(NSString *)nibName forCellClass:(Class)cellClass modelClass:(Class)modelClass
{
    [self.cellFactory registerNibNamed:nibName
                          forCellClass:cellClass
                            modelClass:modelClass];
}

-(void)registerNibNamed:(NSString *)nibName forHeaderClass:(Class)headerClass modelClass:(Class)modelClass
{
    [self.cellFactory registerNibNamed:nibName
                        forHeaderClass:headerClass
                            modelClass:modelClass];
}

-(void)registerNibNamed:(NSString *)nibName forFooterClass:(Class)footerClass modelClass:(Class)modelClass
{
    [self.cellFactory registerNibNamed:nibName
                        forFooterClass:footerClass
                            modelClass:modelClass];
}

#pragma mark - search

-(BOOL)isSearching
{
    // If search scope is selected, we are already searching, even if dataset is all items
    if (((self.currentSearchString) && (![self.currentSearchString isEqualToString:@""]))
        ||
        self.currentSearchScope>-1)
    {
        return YES;
    }
    return NO;
}

-(void)filterTableItemsForSearchString:(NSString *)searchString
{
    [self filterTableItemsForSearchString:searchString inScope:-1];
}

-(void)filterTableItemsForSearchString:(NSString *)searchString
                               inScope:(NSInteger)scopeNumber
{
    BOOL wereSearching = [self isSearching];
    
    if (![searchString isEqualToString:self.currentSearchString] ||
        scopeNumber!=self.currentSearchScope)
    {
        self.currentSearchScope = scopeNumber;
        self.currentSearchString = searchString;
    }
    else {
        return;
    }
    
    if (wereSearching && ![self isSearching])
    {
        [self.tableView reloadData];
        return;
    }
    if ([self.dataStorage respondsToSelector:@selector(searchingStorageForSearchString:inSearchScope:)])
    {
        self.searchingDataStorage = [self.dataStorage searchingStorageForSearchString:searchString
                                                                        inSearchScope:scopeNumber];
        [self.tableView reloadData];
    }
}

-(id)headerViewModelForIndex:(NSInteger)index
{
    if ([self isSearching])
    {
        id <DTTableViewSection> section = [self.searchingDataStorage sections][index];
        if ([section respondsToSelector:@selector(headerModel)])
        {
            return [section headerModel];
        }
    }
    else
    {
        id <DTTableViewSection> section = [self.dataStorage sections][index];
        if ([section respondsToSelector:@selector(headerModel)])
        {
            return [section headerModel];
        }
    }
    
    return nil;
}

-(id)footerViewModelForIndex:(NSInteger)index
{
    if ([self isSearching])
    {
        id <DTTableViewSection> section = [self.searchingDataStorage sections][index];
        if ([section respondsToSelector:@selector(footerModel)])
        {
            return [section footerModel];
        }
    }
    else
    {
        id <DTTableViewSection> section = [self.dataStorage sections][index];
        if ([section respondsToSelector:@selector(footerModel)])
        {
            return [section footerModel];
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
    else {
        return [[self.dataStorage sections] count];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self isSearching])
    {
        DTTableViewSectionModel * sectionModel = [self.searchingDataStorage sections][section];
        return [sectionModel numberOfObjects];
    }
    else {
        DTTableViewSectionModel * sectionModel = [self.dataStorage sections][section];
        return [sectionModel numberOfObjects];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)sectionNumber
{
    if ([self isSearching])
    {
        if (self.sectionHeaderStyle == DTTableViewSectionStyleTitle)
        {
            id <DTTableViewSection> section = [self.searchingDataStorage sections][sectionNumber];
            if ([section respondsToSelector:@selector(headerModel)])
            {
                return [section headerModel];
            }
        }
    }
    else {
        id <DTTableViewSection> section = [self.dataStorage sections][sectionNumber];
        
        if (self.sectionHeaderStyle == DTTableViewSectionStyleTitle)
        {
            if ([section respondsToSelector:@selector(headerModel)])
            {
                return [section headerModel];
            }
        }
    }
    
    return nil;
}

-(NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)sectionNumber
{
    if ([self isSearching])
    {
        if (self.sectionFooterStyle == DTTableViewSectionStyleTitle)
        {
            id <DTTableViewSection> section = [self.searchingDataStorage sections][sectionNumber];
            if ([section respondsToSelector:@selector(footerModel)])
            {
                return [section footerModel];
            }
        }
    }
    else {
        if (self.sectionFooterStyle == DTTableViewSectionStyleTitle)
        {
            id <DTTableViewSection> section = [self.dataStorage sections][sectionNumber];
            if ([section respondsToSelector:@selector(footerModel)])
            {
                return [section footerModel];
            }
        }
    }
    
    return nil;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)sectionNumber
{
    if (self.sectionHeaderStyle == DTTableViewSectionStyleTitle)
    {
        return nil;
    }
    id model = [self headerViewModelForIndex:sectionNumber];
    
    if (!model) {
        return nil;
    }
    
    return [self.cellFactory headerViewForModel:model];
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)sectionNumber
{
    if (self.sectionFooterStyle == DTTableViewSectionStyleTitle)
    {
        return nil;
    }
    id model = [self footerViewModelForIndex:sectionNumber];
    
    if (!model) {
        return nil;
    }
    
    return [self.cellFactory footerViewForModel:model];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)sectionNumber
{
    id <DTTableViewDataStorage> currentDataStorage = [self isSearching] ? self.searchingDataStorage : self.dataStorage;
    DTTableViewSectionModel * section = [currentDataStorage sections][sectionNumber];
    
    // Default table view section header titles, size defined by UILabel sizeToFit method
    if (self.sectionHeaderStyle == DTTableViewSectionStyleTitle)
    {
        if (!section.headerModel)
        {
            return 0;
        }
        else {
            return UITableViewAutomaticDimension;
        }
    }
    
    // Custom table view headers
    if (section.headerModel)
    {
        return self.tableView.sectionHeaderHeight;
    }
    else {
        return 0;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)sectionNumber
{
    id <DTTableViewDataStorage> currentDataStorage = [self isSearching] ? self.searchingDataStorage : self.dataStorage;
    DTTableViewSectionModel * section = [currentDataStorage sections][sectionNumber];
    
    // Default table view section header titles, size defined by UILabel sizeToFit method
    if (self.sectionFooterStyle == DTTableViewSectionStyleTitle)
    {
        if (!section.footerModel)
        {
            return 0;
        }
        else {
            return UITableViewAutomaticDimension;
        }
    }
    
    // Custom table view headers
    if (section.footerModel)
    {
        return self.tableView.sectionFooterHeight;
    }
    else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id model = nil;
    if ([self isSearching])
    {
         DTTableViewSectionModel * sectionModel = [self.searchingDataStorage sections][indexPath.section];
        model = [sectionModel.objects objectAtIndex:indexPath.row];
    }
    else {
         DTTableViewSectionModel * sectionModel = [self.dataStorage sections][indexPath.section];
        model = [sectionModel.objects objectAtIndex:indexPath.row];
    }
    
    return [self.cellFactory cellForModel:model];
}

#pragma mark - private

- (void)tableView:(UITableView *)tableView
moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath
      toIndexPath:(NSIndexPath *)destinationIndexPath
{
    id <DTTableViewDataStorage> currentStorage = [self isSearching] ? self.searchingDataStorage : self.dataStorage;

    DTTableViewSectionModel * fromSection = [currentStorage sections][sourceIndexPath.section];
    DTTableViewSectionModel * toSection = [currentStorage sections][destinationIndexPath.section];
    id tableItem = fromSection.objects[sourceIndexPath.row];
    
    [fromSection.objects removeObjectAtIndex:sourceIndexPath.row];
    [toSection.objects insertObject:tableItem atIndex:destinationIndexPath.row];
}

#pragma  mark - UISearchBarDelegate

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self filterTableItemsForSearchString:searchText];
}

-(void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope
{
    [self filterTableItemsForSearchString:searchBar.text inScope:selectedScope];
}

#pragma mark - logging

+(void)setLogging:(BOOL)isEnabled
{
    loggingEnabled = isEnabled;
}

+(BOOL)loggingEnabled
{
    return loggingEnabled;
}

-(void)performUpdate:(DTTableViewUpdate *)update
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

-(void)performAnimation:(void (^)(UITableView *))animationBlock
{
    animationBlock(self.tableView);
}

@end
