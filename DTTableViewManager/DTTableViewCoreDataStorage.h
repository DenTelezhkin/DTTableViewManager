//
//  DTTableViewCoreDataStorage.h
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 07.12.13.
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

#import "DTTableViewDataStorage.h"
#import <CoreData/CoreData.h>

/**
 This class is used to provide CoreData storage for `DTTableViewController` instance. Storage object will automatically react to NSFetchResultsController changes and will call `DTTableViewController` instance to update UI accordingly.
 
 ## Searching
 
 To implement search, subclass `DTTableViewCoreDataStorage` and provide implementation for method `searchingStorageForSearchString:inSearchScope:`. New searching storage should probably contain similar NSFetchedResultsController, but with NSPredicate, filtering results.
 */

@interface DTTableViewCoreDataStorage : NSObject <DTTableViewDataStorage,NSFetchedResultsControllerDelegate>

/**
 Use this method to create `DTTableViewCoreDataStorage` object with your NSFetchedResultsController.
 
 @param controller NSFetchedResultsController instance, that will be used to populate UITableView.
 
 @return `DTTableViewCoreDataStorage` object.
 */

+(instancetype)storageWithFetchResultsController:(NSFetchedResultsController *)controller;

/**
 Delegate object, that gets notified about data storage updates, in this scenario - NSFetchedResultsController updates. This property is automatically set by `DTTableViewController` instance, when setter for dataStorage property is called.
 */
@property (nonatomic, weak) id <DTTableViewDataStorageUpdating> delegate;

/**
 NSFetchedResultsController of current `DTTableViewCoreDataStorage` object.
 */
@property (nonatomic, strong, readonly) NSFetchedResultsController * fetchedResultsController;

@end
