//
//  DTTableViewModelSearching.h
//  DTTableViewController
//
//  Created by Denys Telezhkin on 31.05.13.
//  Copyright (c) 2013 Denys Telezhkin. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 `DTTableViewModelSearching` protocol is used to search within UITableView models. If model does not implement methods of this protocol, DTTableViewController will not add model to search results. Methods of this protocol are invoked for every model every time search occurs.
 */


@protocol DTTableViewModelSearching

/**
 
 Use this method to filter models, that should show up, if search string is equal to searchString
 
 @param searchString search string
 
 @param scope current search scope
 */

- (BOOL)shouldShowInSearchResultsForSearchString:(NSString*)searchString
                                    inScopeIndex:(int)scope;


@end
