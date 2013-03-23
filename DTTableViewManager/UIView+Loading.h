//
//  UIView+Laoding.h
//  WorldlifeNMP
//
//  Created by Evgeniy Kirpichenko on 7/13/12.
//  Copyright (c) 2012 MLS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Loading)
+ (id) loadFromXibNamed:(NSString *) xibName;
+ (id) loadFromXib;
@end
