//
//  DTDefaultCellModel.h
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 11.01.14.
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

#import "DTViewConfiguration.h"

/**
 `DTDefaultCellModel` is a custom model class, that allows to use UITableViewCells without subclassing.
 */
@interface DTDefaultCellModel : NSObject 

/**
 Reuse identifier for cell, that will be used for current cell model.
 */
@property (nonatomic, retain) NSString * reuseIdentifier;

/**
 Cell style for cell, that will be created for current cell model
 */
@property (nonatomic, assign) UITableViewCellStyle cellStyle;

/**
 Configuration block, that will be executed on UITableViewCell after it will be created/reused.
 */
@property (nonatomic, copy) DTCellConfigurationBlock cellConfigurationBlock;

/**
 Convenience method, allowing to create `DTDefaultCellModel` instance.
 
 @param style UITableViewCellStyle to use for cell.
 
 @param reuseIdentifier reuse identifier to use for cell.
 
 @param configurationBlock block to execute when cell is created.
 
 @return `DTDefaultCellModel` instance.
 */
+(instancetype)modelWithCellStyle:(UITableViewCellStyle)style
                  reuseIdentifier:(NSString *)reuseIdentifier
               configurationBlock:(DTCellConfigurationBlock)configurationBlock;

@end
