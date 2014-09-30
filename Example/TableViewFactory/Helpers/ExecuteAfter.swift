//
//  ExecuteAfter.swift
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 27.09.14.
//  Copyright (c) 2014 Denys Telezhkin. All rights reserved.
//

import Foundation

func executeAfter(when: Double, block: dispatch_block_t!) {
    let delay = when * Double(NSEC_PER_SEC)
    let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
    dispatch_after(time, dispatch_get_main_queue(), block)
}