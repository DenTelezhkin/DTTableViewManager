//
//  BaseTableViewCell.h
//  Messenger
//
//  Created by Denys Telezhkin on 9/11/12.
//  Copyright (c) 2012 Denys Telezhkin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseTableViewCell : UITableViewCell

-(void)updateWithModel:(id)model;

-(id)initWithStyle:(UITableViewCellStyle)style
   reuseIdentifier:(NSString *)reuseIdentifier
          andModel:(id)model;

-(id)model;
@end
