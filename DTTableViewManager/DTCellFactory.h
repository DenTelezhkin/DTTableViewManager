//
//  DTCellFactory.h
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 6/19/12.
//  Copyright (c) 2012 MLSDev. All rights reserved.
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
 `DTCellFactory` is a singleton object that is used to create cells for your tableView. 
 
 ## Mapping
 You should add mapping from model class to cell class, so that `DTCellFactory` could correctly create custom cells of the correct type, and pass them to `DTTableViewManager`. Use `setCellClassMapping:forModelClass:` for setting that connection.
 */

@interface DTCellFactory : NSObject

/**
 Copy of NSDictionary with all model -> cell class mappings.
 */

@property (readonly) NSDictionary * classMappingDictionary;


///---------------------------------------
/// @name Accessing factory
///---------------------------------------

/**
 Singleton object of `DTCellFactory`
 */
+ (DTCellFactory *)sharedInstance;

///---------------------------------------
/// @name Mapping
///---------------------------------------

/**
 Designated mapping method.
 
 @param cellClass Class of the cell you want to be created for model with `modelClass`.
 
 @param modelClass Class of the model you want to be mapped to `cellClass`.
 
 @warning If you want to use custom XIB for creating cells, use `[DTTableViewManager setCellMappingForNib:cellClass:modelClass:]` instead.
 */

-(void)setCellClassMapping:(Class)cellClass forModelClass:(Class)modelClass;

/**
 @name Internal use
 */

- (UITableViewCell *)cellForModel:(NSObject *)model
                          inTable:(UITableView *)table
                  reuseIdentifier:(NSString *)reuseIdentifier;

- (Class)cellClassForModel:(NSObject *)model;

@end
