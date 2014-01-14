//
//  DTSectionModel+HeaderFooterModel.h
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 10.01.14.
//  Copyright (c) 2014 Denys Telezhkin. All rights reserved.
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

#import "DTSectionModel.h"

static NSString * const DTTableViewElementSectionHeader = @"DTTableViewElementSectionHeader";
static NSString * const DTTableViewElementSectionFooter = @"DTTableViewElementSectionFooter";

/**
 This category adds ability to set and get section footer and header model for current section.
 */

@interface DTSectionModel (HeaderFooterModel)

/**
 Set header model for current section. Header presentation depends on `DTTableViewController` sectionHeaderStyle property.
 
@param headerModel headerModel for current section
 */
-(void)setHeaderModel:(id)headerModel;

/**
 Footer model for current section. Footer presentation depends on `DTTableViewController` sectionFooterStyle property.
 
 @param footerModel footer model for current section
 */
-(void)setFooterModel:(id)footerModel;

/**
 Header model for current section.
 
 @return headerModel
 */
-(id)headerModel;

/**
 Footer model for current section.
 
 @return footerModel
 */
-(id)footerModel;

@end
