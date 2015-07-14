//
//  TableViewCellFactory.swift
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 13.07.15.
//  Copyright (c) 2015 Denys Telezhkin. All rights reserved.
//

import UIKit
import Foundation
import DTModelStorage

class TableViewFactory
{
    typealias AnyBlock = (Any, Any) -> ()
    
    private let tableView: UITableView
    private var cellMappings = [String: String]()
    private var headerMappings = [String:String]()
    private var footerMappings = [String:String]()
    private var updateModelBlocks = [String: AnyBlock]()
    
    init(tableView: UITableView)
    {
        self.tableView = tableView
    }
    
    func registerCellClass<T:ModelTransfer>(cellType : T.Type)
    {
        let typeMirror = reflect(T.CellModel.self)
        let cellTypeMirror = reflect(cellType)
        
        let updateBlock : (Any,Any) -> Void = { view, model in
            (view as! T).updateWithModel(model as! T.CellModel)
        }
        self.updateModelBlocks[typeMirror.summary] = updateBlock
        
        let reuseIdentifier = RuntimeHelper.classNameFromReflection(cellTypeMirror)
        if self.tableView.dequeueReusableCellWithIdentifier(reuseIdentifier) == nil
        {
            // Storyboard prototype cell
            self.tableView.registerClass(T.self as! UITableViewCell.Type, forCellReuseIdentifier: reuseIdentifier)
            
            if UINib.nibExistsWithNibName(reuseIdentifier) {
                self.registerNibName(reuseIdentifier, cellType: T.self)
            }
        }
        
        self.cellMappings[typeMirror.summary] = cellTypeMirror.summary
    }
    
    func registerNibName<T:ModelTransfer>(nibName : String, cellType: T.Type)
    {
        assert(UINib.nibExistsWithNibName(nibName), "Register nib method should be called only if nix exists")
        
        let nib = UINib(nibName: nibName, bundle: NSBundle(forClass: self.dynamicType))
        let typeMirror = reflect(T.CellModel.self)
        let cellTypeMirror = reflect(cellType)
        let reuseIdentifier = RuntimeHelper.classNameFromReflection(cellTypeMirror)
        self.tableView.registerNib(nib, forCellReuseIdentifier: reuseIdentifier)
        
        self.cellMappings[typeMirror.summary] = cellTypeMirror.summary
    }
    
    func cellForModel(model: Any, atIndexPath indexPath:NSIndexPath) -> UITableViewCell
    {
        let typeMirror = reflect(model.dynamicType)
        if let cellSummary = self.cellMappings[typeMirror.summary]
        {
            let cellClassName = RuntimeHelper.classNameFromReflectionSummary(cellSummary)
            let cell = tableView.dequeueReusableCellWithIdentifier(cellClassName, forIndexPath: indexPath) as! UITableViewCell
            let updateBlock = self.updateModelBlocks[typeMirror.summary]
            updateBlock?(cell, model)
            return cell
        }
        
        assertionFailure("Unable to find cell mappings for type: \(typeMirror)")
        
        return UITableViewCell()
    }
}
