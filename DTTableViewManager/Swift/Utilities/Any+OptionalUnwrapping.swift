//
//  Any+OptionalUnwrapping.swift
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 15.07.15.
//  Copyright (c) 2015 Denys Telezhkin. All rights reserved.
//

import Foundation

func recursiveUnwrapValue(any: Any) -> Any?
{
    let mirror = reflect(any)
    if mirror.disposition != .Optional
    {
        return any
    }
    if mirror.count == 0
    {
        return nil
    }
    let (_,some) = mirror[0]
    return recursiveUnwrapValue(some.value)
}