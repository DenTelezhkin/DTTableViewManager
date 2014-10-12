//
// DTTableViewControllerEvents.h
// DTTableViewManager
//
// Created by Denys Telezhkin on 23.09.14.
// Copyright (c) 2014 Denys Telezhkin. All rights reserved.
//
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

#import <Foundation/Foundation.h>

/**
 Protocol, that allows you to react to different DTTableViewController events. This protocol is adopted by DTTableViewController instance.
 */
@protocol DTTableViewControllerEvents <NSObject>

@optional

// updating content

/**
 This method will be called every time after storage contents changed, and just before UI will be updated with these changes.
 */
- (void)tableControllerWillUpdateContent;

/**
 This method will be called every time after storage contents changed, and after UI has been updated with these changes.
 */
- (void)tableControllerDidUpdateContent;

// searching

/**
 This method is called when DTTableViewController will start searching in current storage. After calling this method DTTableViewController starts using searchingStorage instead of storage to provide search results.
 */
- (void)tableControllerWillBeginSearch;

/**
 This method is called after DTTableViewController ended searching in storage and updated UITableView UI.
 */
- (void)tableControllerDidEndSearch;

/**
 This method is called, when search string becomes empty. DTTableViewController switches to default storage instead of searchingStorage and reloads data of the UITableView.
 */
- (void)tableControllerDidCancelSearch;

@end
