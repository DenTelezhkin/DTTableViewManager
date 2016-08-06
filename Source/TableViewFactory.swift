//
//  TableViewCellFactory.swift
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 13.07.15.
//  Copyright (c) 2015 Denys Telezhkin. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit
import Foundation
import DTModelStorage

public enum DTTableViewFactoryError : Error {
    case nilCellModel(IndexPath)
    case noCellMappings(model: Any)
    case nilHeaderFooterModel(section: Int)
    
    public var description : String {
        switch self {
        case .nilCellModel(let indexPath):
            return "Received nil model for cell at index path: \(indexPath)"
        case .nilHeaderFooterModel(let section):
            return "Received nil model for header or footer model in section: \(section)"
        case .noCellMappings(let model):
            return "Cell mapping is missing for model: \(model)"
        }
    }
}

/// Internal class, that is used to create table view cells, headers and footers.
class TableViewFactory
{
    private let tableView: UITableView
    
    var mappings = [ViewModelMapping]()
    
    weak var mappingCustomizableDelegate : DTViewModelMappingCustomizable?
    
    init(tableView: UITableView)
    {
        self.tableView = tableView
    }
    
    func registerCellClass<T:ModelTransfer where T: UITableViewCell>(_ cellClass : T.Type)
    {
        let reuseIdentifier = String(T.self)
        if tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) == nil
        {
            self.tableView.register(T.self, forCellReuseIdentifier: reuseIdentifier)
            
            if UINib.nibExistsWithNibName(reuseIdentifier, inBundle: Bundle(for: T.self)) {
                registerNibNamed(reuseIdentifier, forCellClass: T.self)
            }
            else {
                mappings.addMappingForViewType(.cell, viewClass: T.self)
            }
        }
        else {
            // Storyboard prototype cell
            mappings.addMappingForViewType(.cell, viewClass: T.self)
        }
    }
    
    func registerNibNamed<T:ModelTransfer where T: UITableViewCell>(_ nibName : String, forCellClass cellClass: T.Type)
    {
        assert(UINib.nibExistsWithNibName(nibName, inBundle: Bundle(for: T.self)), "Register cell nib method should be called only if nib exists")
        
        let nib = UINib(nibName: nibName, bundle: Bundle(for: T.self))
        let reuseIdentifier = String(T.self)
        self.tableView.register(nib, forCellReuseIdentifier: reuseIdentifier)
        mappings.addMappingForViewType(.cell, viewClass: T.self, xibName: nibName)
    }
    
    func registerNiblessHeaderClass<T:ModelTransfer where T: UIView>(_ headerClass : T.Type)
    {
        let reuseIdentifier = String(T.self)
        tableView.register(headerClass, forHeaderFooterViewReuseIdentifier: reuseIdentifier)
        mappings.addMappingForViewType(.supplementaryView(kind: DTTableViewElementSectionHeader), viewClass: T.self)
    }
    
    func registerNiblessFooterClass<T:ModelTransfer where T: UIView>(_ footerClass : T.Type)
    {
        let reuseIdentifier = String(T.self)
        tableView.register(footerClass, forHeaderFooterViewReuseIdentifier: reuseIdentifier)
        mappings.addMappingForViewType(.supplementaryView(kind: DTTableViewElementSectionFooter), viewClass: T.self)
    }
    
    func registerHeaderClass<T:ModelTransfer where T: UIView>(_ headerClass : T.Type)
    {
        self.registerNibNamed(String(T.self), forHeaderClass: headerClass)
    }
    
    func registerFooterClass<T:ModelTransfer where T:UIView>(_ footerClass: T.Type)
    {
        self.registerNibNamed(String(T.self), forFooterClass: footerClass)
    }
    
    func registerNibNamed<T:ModelTransfer where T:UIView>(_ nibName: String, forHeaderClass headerClass: T.Type)
    {
        assert(UINib.nibExistsWithNibName(nibName, inBundle: Bundle(for: T.self)), "Register header nib method should be called only if nib exists")
        let reuseIdentifier = String(T.self)
        
        if T.isSubclass(of: UITableViewHeaderFooterView.self) {
            self.tableView.register(UINib(nibName: nibName, bundle: Bundle(for: T.self)), forHeaderFooterViewReuseIdentifier: reuseIdentifier)
        }
        mappings.addMappingForViewType(.supplementaryView(kind: DTTableViewElementSectionHeader), viewClass: T.self, xibName: nibName)
    }
    
    func registerNibNamed<T:ModelTransfer where T:UIView>(_ nibName: String, forFooterClass footerClass: T.Type)
    {
        assert(UINib.nibExistsWithNibName(nibName, inBundle: Bundle(for: T.self)), "Register footer nib method should be called only if nib exists")
        let reuseIdentifier = String(T.self)
        
        if T.isSubclass(of: UITableViewHeaderFooterView.self) {
            self.tableView.register(UINib(nibName: nibName, bundle: Bundle(for: T.self)), forHeaderFooterViewReuseIdentifier: reuseIdentifier)
        }
        mappings.addMappingForViewType(.supplementaryView(kind: DTTableViewElementSectionFooter), viewClass: T.self, xibName: nibName)
    }
    
    func viewModelMappingForViewType(_ viewType: ViewType, model: Any) -> ViewModelMapping?
    {
        guard let unwrappedModel = RuntimeHelper.recursivelyUnwrapAnyValue(model) else {
            return nil
        }
        let mappingCandidates = mappings.mappingCandidatesForViewType(viewType, model: unwrappedModel)
        
        if let customizedMapping = mappingCustomizableDelegate?.viewModelMappingFromCandidates(mappingCandidates, forModel: unwrappedModel) {
            return customizedMapping
        } else if let defaultMapping = mappingCandidates.first {
            return defaultMapping
        } else {
            return nil
        }
    }
    
    func cellForModel(_ model: Any, atIndexPath indexPath:IndexPath) throws -> UITableViewCell
    {
        guard let unwrappedModel = RuntimeHelper.recursivelyUnwrapAnyValue(model) else {
            throw DTTableViewFactoryError.nilCellModel(indexPath)
        }
        
        if let mapping = viewModelMappingForViewType(.cell, model: unwrappedModel)
        {
            let cellClassName = String(mapping.viewClass)
            let cell = tableView.dequeueReusableCell(withIdentifier: cellClassName, for: indexPath)
            mapping.updateBlock(cell, unwrappedModel)
            return cell
        }
        
        throw DTTableViewFactoryError.noCellMappings(model: unwrappedModel)
    }
    
    func headerFooterViewWithMapping(_ mapping: ViewModelMapping, unwrappedModel: Any) -> UIView?
    {
        let viewClassName = String(mapping.viewClass)
        if let view = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: viewClassName) {
            mapping.updateBlock(view,unwrappedModel)
            return view
        }
        else {
            var view : UIView? = nil
            
            if let type = mapping.viewClass as? UIView.Type {
                view = type.dt_loadFromXib()
            }
            
            if view != nil {
                mapping.updateBlock(view!,unwrappedModel)
            }
            return view
        }
    }
    
    func headerFooterViewOfType(_ type: ViewType, model : Any, atIndexPath indexPath: IndexPath) throws -> UIView?
    {
        guard let unwrappedModel = RuntimeHelper.recursivelyUnwrapAnyValue(model) else {
            throw DTTableViewFactoryError.nilHeaderFooterModel(section: (indexPath as NSIndexPath).section)
        }
        
        if let mapping = viewModelMappingForViewType(type, model: unwrappedModel) {
            return headerFooterViewWithMapping(mapping, unwrappedModel: unwrappedModel)
        }
        
        return nil
    }
    
    func headerViewForModel(_ model: Any, atIndexPath indexPath: IndexPath) throws -> UIView?
    {
        return try headerFooterViewOfType(.supplementaryView(kind: DTTableViewElementSectionHeader),
            model: model, atIndexPath: indexPath)
    }
    
    func footerViewForModel(_ model: Any, atIndexPath indexPath: IndexPath) throws -> UIView?
    {
        return try headerFooterViewOfType(.supplementaryView(kind: DTTableViewElementSectionFooter),
            model: model, atIndexPath: indexPath)
    }
}
