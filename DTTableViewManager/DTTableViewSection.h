//
//  DTTableViewSection.h
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 29.11.13.
//  Copyright (c) 2013 Denys Telezhkin. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DTTableViewSection <NSObject>

- (NSArray *)objects;

- (NSUInteger)numberOfObjects;

@optional

- (NSString *)indexTitle;

- (id)headerModel;
- (id)footerModel;

@end
