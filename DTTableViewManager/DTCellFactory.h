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

 You shouldn't call any of it's methods. Use `DTTableViewManager` API's.
 */

@interface DTCellFactory : NSObject

-(void)setCellClassMapping:(Class)cellClass forModelClass:(Class)modelClass;

-(void)setHeaderClassMapping:(Class)headerClass forModelClass:(Class)modelClass;

-(void)setFooterClassMapping:(Class)footerClass forModelClass:(Class)modelClass;

- (UITableViewCell *)cellForModel:(NSObject *)model
                          inTable:(UITableView *)table;

-(UIView *)headerViewForModel:(id)model
                  inTableView:(UITableView *)tableView;

-(UIView *)footerViewForModel:(id)model
                  inTableView:(UITableView*)tableView;

-(NSString *)reuseIdentifierForClass:(Class)class;

@end
