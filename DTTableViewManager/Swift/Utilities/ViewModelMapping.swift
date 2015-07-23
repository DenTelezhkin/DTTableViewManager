//
//  CellModelMapping.swift
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 15.07.15.
//  Copyright (c) 2015 Denys Telezhkin. All rights reserved.
//

import ModelStorage

enum ViewType : String
{
    case Cell = "Cell"
    case Header = "Header"
    case Footer = "Footer"
}

struct ViewModelMapping
{
    let viewType : ViewType
    let viewTypeMirror: MirrorType
    let modelTypeMirror: MirrorType
    let updateBlock : (Any, Any) -> ()
}

extension ViewModelMapping : Printable
{
    var description : String
    {
        return "Mapping type : \(viewType.rawValue) \n" +
            "View Type : \(viewTypeMirror.value) \n" +
            "Model Type : \(modelTypeMirror.value) \n"
    }
}