//
//  UIView+Laoding.h
//  WorldlifeNMP
//
//  Created by Evgeniy Kirpichenko on 7/13/12.
//  Copyright (c) 2012 MLS. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 `UIView+Loading` is a category on UIView, allowing to load view from .xib file.
 
 */

@interface UIView (Loading)

/**
 Loads view object from <xibName>.xib file.
 
 @param xibName Name of the xib file to load from
 
 @return view object
 */

+ (id) loadFromXibNamed:(NSString *) xibName;

/**
 Loads view from xib with name identical to name of the current view class
 
 @return view object
 */

+ (id) loadFromXib;
@end
