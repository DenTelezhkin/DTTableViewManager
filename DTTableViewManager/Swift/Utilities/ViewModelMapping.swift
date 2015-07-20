//
//  CellModelMapping.swift
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 15.07.15.
//  Copyright (c) 2015 Denys Telezhkin. All rights reserved.
//

import ModelStorage

enum ViewType
{
    case Cell
    case Header
    case Footer
}

struct ViewModelMapping
{
    let viewType : ViewType
    let viewTypeMirror: MirrorType
    let modelTypeMirror: MirrorType
    let updateBlock : (Any, Any) -> ()
}