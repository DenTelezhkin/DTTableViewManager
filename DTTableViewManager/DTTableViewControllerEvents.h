//
//  DTTableViewControllerEvents.h
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 23.09.14.
//  Copyright (c) 2014 Denys Telezhkin. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DTTableViewControllerEvents <NSObject>

@optional

// updating content

- (void)controllerWillUpdateContent;
- (void)controllerDidUpdateContent;

// searching

- (void)controllerWillBeginSearch;
- (void)controllerDidEndSearch;
- (void)controllerDidCancelSearch;

@end
