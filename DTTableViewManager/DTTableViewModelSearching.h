//
//  DTTableViewModelSearching.h
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 31.05.13.
//  Copyright (c) 2013 Denys Telezhkin. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DTTableViewModelSearching 


/**
 
 Use this method to filter models, that should show up, if search string is equal to searchString
 */

- (BOOL)shouldShowInSearchResultsForSearchString:(NSString*)searchString
                                    inScopeIndex:(int)scope;


@end
