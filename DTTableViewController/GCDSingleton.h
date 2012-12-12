//
//  GCDSingleton.h
//  TableViewFactory
//
//  Created by Denys Telezhkin on 12/12/12.
//  Copyright (c) 2012 Denys Telezhkin. All rights reserved.
//

#ifndef TableViewFactory_GCDSingleton_h
#define TableViewFactory_GCDSingleton_h

#define DEFINE_SHARED_INSTANCE_USING_BLOCK(block) \
static dispatch_once_t pred = 0; \
__strong static id _sharedObject = nil; \
dispatch_once(&pred, ^{ \
_sharedObject = block(); \
}); \
return _sharedObject; \

#endif
