//
//  DTTableViewModelTransfer.h
//  TableViewFactory
//
//  Created by Denys Telezhkin on 10/4/12.
//  Copyright (c) 2012 Denys Telezhkin. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
 `DTTableViewModelTransfer` protocol is used to pass `model` data to your cell. Every UITableViewCell subclass you have should implement this protocol.
*/

@protocol DTTableViewModelTransfer
@required

/**
  This method will be called, when controller needs to display model on current cell
 
  @param model Model object to display on current cell
 
*/
- (void)updateWithModel:(id)model;

@optional

/**
 This method can be used to retrieve cell model from the cell
*/
- (id)model;

@end
