//
//  TableViewModelProtocol.h
//  TableViewFactory
//
//  Created by Denys Telezhkin on 10/4/12.
//  Copyright (c) 2012 Denys Telezhkin. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DTTableViewModelProtocol <NSObject>
@required
- (void)updateWithModel:(id)model;
@optional
- (id)model;
@end
