//
//  DTHeaderFooterModel.h
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 12.01.14.
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
 `DTDefaultHeaderFooterModel` is a custom model class, that allows to use UITableViewHeaderFooterView without subclassing.
 */
@interface DTDefaultHeaderFooterModel : NSObject

/**
 Reuse identifier for header footer view, that will be used for current model.
 */
@property (nonatomic, retain) NSString * reuseIdentifier;

/**
 Configuration block, that will be executed on UITableViewHeaderFooterView after it will be created/reused.
 */
@property (nonatomic, copy) DTHeaderFooterViewConfigurationBlock viewConfigurationBlock;

/**
 Convenience method, allowing to create `DTDefaultHeaderFooterModel` instance.
 
 @param reuseIdentifier reuse identifier to use for header footer view
 
 @param configurationBlock block to execute when header footer view is created
 
 @return `DTDefaultHeaderFooterModel` instance.
 */
+(instancetype)modelWithReuseIdentifier:(NSString *)reuseIdentifier
                     configurationBlock:(DTHeaderFooterViewConfigurationBlock)configurationBlock;

@end
