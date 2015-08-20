//
//  Associator.swift
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 20.08.15.
//  Copyright © 2015 Denys Telezhkin. All rights reserved.
//

import Foundation

class AssociatedObjectHolder
{
    let object: Any
    
    init(object: Any)
    {
        self.object = object
    }
}

public protocol Associatable: class {
    func associateObject<T>(object: T, inout key: String)
    func retrieveObject<T>(inout key: String) -> T
}

public extension Associatable
{
    func associateObject<T>(object: T, inout key: String)
    {
        let holder = AssociatedObjectHolder(object: object)
        objc_setAssociatedObject(self, &key, holder, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    func retrieveObject<T>(inout key: String) -> T
    {
        return (objc_getAssociatedObject(self, &key) as! AssociatedObjectHolder).object as! T
    }
}
