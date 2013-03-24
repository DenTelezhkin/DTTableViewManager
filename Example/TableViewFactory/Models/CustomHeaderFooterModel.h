//
//  CustomHeaderFooterModel.h
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 24.03.13.
//  Copyright (c) 2013 Denys Telezhkin. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    kHeaderKind,
    kFooterKind
} kHeaderFooterViewKind;

@interface CustomHeaderFooterModel : NSObject

@property (nonatomic,assign) kHeaderFooterViewKind viewKind;


+(CustomHeaderFooterModel *)footerModel;
+(CustomHeaderFooterModel *)headerModel;
@end
