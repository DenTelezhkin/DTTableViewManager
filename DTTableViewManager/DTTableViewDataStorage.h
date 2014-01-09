//
//  DTTableViewDataStorage.h
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 24.11.13.
//  Copyright (c) 2013 Denys Telezhkin. All rights reserved.
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

#import "DTStorageUpdate.h"
#import "DTStorage.h"

/**
 `DTTableViewDataStorageUpdating` protocol is used to transfer data storage updates to `DTTableViewController` object.
 */

@protocol DTTableViewDataStorageUpdating <DTStorageUpdating>

@optional

/**
 This method allows to perform animations you need for changes in UITableView. Performing manual animations requires to manually change datasource objects before animation method is called.
 
 @param animationBlock AnimationBlock to be executed with UITableView.
 
 @warning You need to update data storage object before executing this method.
 */
- (void)performAnimatedUpdate:(void(^)(UITableView *))animationBlock;

@end

/**
 `DTTableViewDataStorage` protocol is used to define common interface for data storage objects used by `DTTableViewController` instance. `DTTableViewManager` provides 2 implementations - `DTTableViewMemoryStorage` and `DTTableViewCoreDataStorage`. `DTTableViewMemoryStorage` is used by default.
 */

@protocol DTTableViewDataStorage <DTStorage>

@optional

/**
 Method to create searching data storage, based on current data storage. This method will be called automatically by `DTTableViewController` instance.
 
 @param searchString String, used to search in data storage
 
 @param searchScope Search scope for current search.
 
 @return searching data storage.
 */

- (instancetype)searchingStorageForSearchString:(NSString *)searchString
                                  inSearchScope:(NSInteger)searchScope;

/**
 Getter method for header model for current section.
 
 @param index Number of section.
 
 @return Header model for section at index.
 */
- (id)headerModelForSectionIndex:(NSInteger)index;

/**
 Getter method for footer model for current section.
 
 @param index Number of section.
 
 @return Footer model for section at index.
 */
- (id)footerModelForSectionIndex:(NSInteger)index;

@end
