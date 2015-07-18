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
import Swift

class TableViewFactory
{
    private let tableView: UITableView
    
    private var mappings = [ViewModelMapping]()
    
    init(tableView: UITableView)
    {
        self.tableView = tableView
    }
    
    private func mappingForViewType(type: ViewType,modelTypeMirror: MirrorType) -> ViewModelMapping?
    {
        return self.mappings.filter({ (mapping) -> Bool in
            return mapping.viewType == type && mapping.modelTypeMirror.summary == modelTypeMirror.summary
        }).first
    }
    
    private func addMappingForViewType<T:ModelTransfer>(type: ViewType, viewClass : T.Type)
    {
        if self.mappingForViewType(type, modelTypeMirror: reflect(T.CellModel.self)) == nil
        {
            self.mappings.append(ViewModelMapping(viewType : type,
                viewTypeMirror : reflect(T),
                modelTypeMirror: reflect(T.CellModel.self),
                updateBlock: { (view, model) in
                    (view as! T).updateWithModel(model as! T.CellModel)
            }))
        }
    }
    
    func registerCellClass<T:ModelTransfer where T: UITableViewCell>(cellType : T.Type)
    {
        let reuseIdentifier = RuntimeHelper.classNameFromReflection(reflect(cellType))
        if self.tableView.dequeueReusableCellWithIdentifier(reuseIdentifier) == nil
        {
            // Storyboard prototype cell
            self.tableView.registerClass(T.self, forCellReuseIdentifier: reuseIdentifier)
            
            if UINib.nibExistsWithNibName(reuseIdentifier, inBundle: NSBundle(forClass: T.self)) {
                self.registerNibName(reuseIdentifier, cellType: T.self)
            }
        }
        self.addMappingForViewType(.Cell, viewClass: T.self)
    }
    
    func registerNibName<T:ModelTransfer where T: UITableViewCell>(nibName : String, cellType: T.Type)
    {
        assert(UINib.nibExistsWithNibName(nibName, inBundle: NSBundle(forClass: T.self)), "Register nib method should be called only if nix exists")
        
        let nib = UINib(nibName: nibName, bundle: NSBundle(forClass: T.self))
        let reuseIdentifier = RuntimeHelper.classNameFromReflection(reflect(cellType))
        self.tableView.registerNib(nib, forCellReuseIdentifier: reuseIdentifier)
        self.addMappingForViewType(.Cell, viewClass: T.self)
    }
    
    func cellForModel(model: Any, atIndexPath indexPath:NSIndexPath) -> UITableViewCell
    {
        // MARK: TODO replace with guard in Swift 2
        let unwrappedModel = recursiveUnwrapAnyValue(model)
        if unwrappedModel == nil {
            assertionFailure("Received nil model at indexPath: \(indexPath)")
        }
        
        let typeMirror = reflect(unwrappedModel!.dynamicType)
        if let mapping = self.mappingForViewType(.Cell, modelTypeMirror: typeMirror)
        {
            let cellClassName = RuntimeHelper.classNameFromReflection(mapping.viewTypeMirror)
            let cell = tableView.dequeueReusableCellWithIdentifier(cellClassName, forIndexPath: indexPath) as! UITableViewCell
            mapping.updateBlock(cell, unwrappedModel!)
            return cell
        }
        
        assertionFailure("Unable to find cell mappings for type: \(typeMirror)")
        
        return UITableViewCell()
    }
}
