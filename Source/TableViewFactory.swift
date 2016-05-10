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

public enum DTTableViewFactoryError : ErrorType, CustomStringConvertible {
    case NilCellModel(NSIndexPath)
    case NoCellMappings(model: Any)
    case NilHeaderFooterModel(section: Int)
    
    public var description : String {
        switch self {
        case .NilCellModel(let indexPath):
            return "Received nil model for cell at index path: \(indexPath)"
        case .NilHeaderFooterModel(let section):
            return "Received nil model for header or footer model in section: \(section)"
        case .NoCellMappings(let model):
            return "Cell mapping is missing for model: \(model)"
        }
    }
}

/// Internal class, that is used to create table view cells, headers and footers.
class TableViewFactory
{
    private let tableView: UITableView
    
    var mappings = [ViewModelMapping]()
    
    var bundle = NSBundle.mainBundle()
    
    var shouldPerformDataBindingForCells = true
    
    weak var mappingCustomizableDelegate : DTViewModelMappingCustomizable?
    
    init(tableView: UITableView)
    {
        self.tableView = tableView
    }
    
    func registerCellClass<T:ModelTransfer where T: UITableViewCell>(cellClass : T.Type)
    {
        let reuseIdentifier = String(T)
        if tableView.dequeueReusableCellWithIdentifier(reuseIdentifier) == nil
        {
            self.tableView.registerClass(T.self, forCellReuseIdentifier: reuseIdentifier)
            
            if UINib.nibExistsWithNibName(reuseIdentifier, inBundle: bundle) {
                registerNibNamed(reuseIdentifier, forCellClass: T.self)
            }
            else {
                mappings.addMappingForViewType(.Cell, viewClass: T.self)
            }
        }
        else {
            // Storyboard prototype cell
            mappings.addMappingForViewType(.Cell, viewClass: T.self)
        }
    }
    
    func registerNibNamed<T:ModelTransfer where T: UITableViewCell>(nibName : String, forCellClass cellClass: T.Type)
    {
        assert(UINib.nibExistsWithNibName(nibName, inBundle: bundle), "Register cell nib method should be called only if nib exists")
        
        let nib = UINib(nibName: nibName, bundle: bundle)
        let reuseIdentifier = String(T)
        self.tableView.registerNib(nib, forCellReuseIdentifier: reuseIdentifier)
        mappings.addMappingForViewType(.Cell, viewClass: T.self, xibName: nibName)
    }
    
    func registerNiblessHeaderClass<T:ModelTransfer where T: UIView>(headerClass : T.Type)
    {
        let reuseIdentifier = String(T)
        tableView.registerClass(headerClass, forHeaderFooterViewReuseIdentifier: reuseIdentifier)
        mappings.addMappingForViewType(.SupplementaryView(kind: DTTableViewElementSectionHeader), viewClass: T.self)
    }
    
    func registerNiblessFooterClass<T:ModelTransfer where T: UIView>(footerClass : T.Type)
    {
        let reuseIdentifier = String(T)
        tableView.registerClass(footerClass, forHeaderFooterViewReuseIdentifier: reuseIdentifier)
        mappings.addMappingForViewType(.SupplementaryView(kind: DTTableViewElementSectionFooter), viewClass: T.self)
    }
    
    func registerHeaderClass<T:ModelTransfer where T: UIView>(headerClass : T.Type)
    {
        self.registerNibNamed(String(T), forHeaderClass: headerClass)
    }
    
    func registerFooterClass<T:ModelTransfer where T:UIView>(footerClass: T.Type)
    {
        self.registerNibNamed(String(T), forFooterClass: footerClass)
    }
    
    func registerNibNamed<T:ModelTransfer where T:UIView>(nibName: String, forHeaderClass headerClass: T.Type)
    {
        assert(UINib.nibExistsWithNibName(nibName, inBundle: bundle), "Register header nib method should be called only if nib exists")
        let reuseIdentifier = String(T)
        
        if T.isSubclassOfClass(UITableViewHeaderFooterView.self) {
            self.tableView.registerNib(UINib(nibName: nibName, bundle: bundle), forHeaderFooterViewReuseIdentifier: reuseIdentifier)
        }
        mappings.addMappingForViewType(.SupplementaryView(kind: DTTableViewElementSectionHeader), viewClass: T.self, xibName: nibName)
    }
    
    func registerNibNamed<T:ModelTransfer where T:UIView>(nibName: String, forFooterClass footerClass: T.Type)
    {
        assert(UINib.nibExistsWithNibName(nibName, inBundle: bundle), "Register footer nib method should be called only if nib exists")
        let reuseIdentifier = String(T.self)
        
        if T.isSubclassOfClass(UITableViewHeaderFooterView.self) {
            self.tableView.registerNib(UINib(nibName: nibName, bundle: bundle), forHeaderFooterViewReuseIdentifier: reuseIdentifier)
        }
        mappings.addMappingForViewType(.SupplementaryView(kind: DTTableViewElementSectionFooter), viewClass: T.self, xibName: nibName)
    }
    
    func viewModelMappingForViewType(viewType: ViewType, model: Any) -> ViewModelMapping?
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
    
    func cellForModel(model: Any, atIndexPath indexPath:NSIndexPath) throws -> UITableViewCell
    {
        guard let unwrappedModel = RuntimeHelper.recursivelyUnwrapAnyValue(model) else {
            throw DTTableViewFactoryError.NilCellModel(indexPath)
        }
        
        if let mapping = viewModelMappingForViewType(.Cell, model: unwrappedModel)
        {
            let cellClassName = String(mapping.viewClass)
            let cell = tableView.dequeueReusableCellWithIdentifier(cellClassName, forIndexPath: indexPath)
            if shouldPerformDataBindingForCells {
                mapping.updateBlock(cell, unwrappedModel)
            }
            return cell
        }
        
        throw DTTableViewFactoryError.NoCellMappings(model: unwrappedModel)
    }
    
    func headerFooterViewWithMapping(mapping: ViewModelMapping, unwrappedModel: Any) -> UIView?
    {
        let viewClassName = String(mapping.viewClass)
        if let view = self.tableView.dequeueReusableHeaderFooterViewWithIdentifier(viewClassName) {
            mapping.updateBlock(view,unwrappedModel)
            return view
        }
        else {
            var view : UIView? = nil
            
            if let type = mapping.viewClass as? UIView.Type {
                view = type.dt_loadFromXibInBundle(bundle)
            }
            
            if view != nil {
                mapping.updateBlock(view!,unwrappedModel)
            }
            return view
        }
    }
    
    func headerFooterViewOfType(type: ViewType, model : Any, atIndexPath indexPath: NSIndexPath) throws -> UIView?
    {
        guard let unwrappedModel = RuntimeHelper.recursivelyUnwrapAnyValue(model) else {
            throw DTTableViewFactoryError.NilHeaderFooterModel(section: indexPath.section)
        }
        
        if let mapping = viewModelMappingForViewType(type, model: unwrappedModel) {
            return headerFooterViewWithMapping(mapping, unwrappedModel: unwrappedModel)
        }
        
        return nil
    }
    
    func headerViewForModel(model: Any, atIndexPath indexPath: NSIndexPath) throws -> UIView?
    {
        return try headerFooterViewOfType(.SupplementaryView(kind: DTTableViewElementSectionHeader),
            model: model, atIndexPath: indexPath)
    }
    
    func footerViewForModel(model: Any, atIndexPath indexPath: NSIndexPath) throws -> UIView?
    {
        return try headerFooterViewOfType(.SupplementaryView(kind: DTTableViewElementSectionFooter),
            model: model, atIndexPath: indexPath)
    }
}
