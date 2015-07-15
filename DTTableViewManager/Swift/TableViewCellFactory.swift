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
        self.registerUpdateBlockForType(T)
        
        let reuseIdentifier = RuntimeHelper.classNameFromReflection(cellTypeMirror)
        if self.tableView.dequeueReusableCellWithIdentifier(reuseIdentifier) == nil
        {
            // Storyboard prototype cell
            self.tableView.registerClass(T.self as! UITableViewCell.Type, forCellReuseIdentifier: reuseIdentifier)
            
            if UINib.nibExistsWithNibName(reuseIdentifier, inBundle: NSBundle(forClass: self.dynamicType)) {
                self.registerNibName(reuseIdentifier, cellType: T.self)
            }
        }
        self.registerUpdateBlockForType(T)
        self.cellMappings[typeMirror.summary] = cellTypeMirror.summary
    }
    
    private func registerUpdateBlockForType<T:ModelTransfer>(type: T.Type)
    {
        let typeMirror = reflect(T.CellModel.self)
        let updateBlock : (Any,Any) -> Void = { view, model in
            (view as! T).updateWithModel(model as! T.CellModel)
        }
        self.updateModelBlocks[typeMirror.summary] = updateBlock
    }
    
    func registerNibName<T:ModelTransfer>(nibName : String, cellType: T.Type)
    {
        assert(UINib.nibExistsWithNibName(nibName, inBundle: NSBundle(forClass: self.dynamicType)), "Register nib method should be called only if nix exists")
        
        let nib = UINib(nibName: nibName, bundle: NSBundle(forClass: self.dynamicType))
        let typeMirror = reflect(T.CellModel.self)
        let cellTypeMirror = reflect(cellType)
        let reuseIdentifier = RuntimeHelper.classNameFromReflection(cellTypeMirror)
        self.tableView.registerNib(nib, forCellReuseIdentifier: reuseIdentifier)
        
        self.registerUpdateBlockForType(T)
        self.cellMappings[typeMirror.summary] = cellTypeMirror.summary
    }
    
    func cellForModel(model: Any, atIndexPath indexPath:NSIndexPath) -> UITableViewCell
    {
        // MARK: TODO replace with guard in Swift 2
        let unwrappedModel = recursiveUnwrapAnyValue(model)
        if unwrappedModel == nil {
            assertionFailure("Received nil model at indexPath: \(indexPath)")
        }
        
        let typeMirror = reflect(unwrappedModel!.dynamicType)
        if let cellSummary = self.cellMappings[typeMirror.summary]
        {
            let cellClassName = RuntimeHelper.classNameFromReflectionSummary(cellSummary)
            let cell = tableView.dequeueReusableCellWithIdentifier(cellClassName, forIndexPath: indexPath) as! UITableViewCell
            let updateBlock = self.updateModelBlocks[typeMirror.summary]
            updateBlock?(cell, unwrappedModel!)
            return cell
        }
        
        assertionFailure("Unable to find cell mappings for type: \(typeMirror)")
        
        return UITableViewCell()
    }
}
