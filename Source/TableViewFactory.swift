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

/// Enum with possible `DTTableViewManager` errors.
///
/// - SeeAlso: `DTTableViewManager.viewFactoryErrorHandler` and `DTTableViewManager.handleTableViewFactoryError()`
public enum DTTableViewFactoryError : Error {
    
    /// `UITableView` requested a cell, however model at indexPath is nil.
    case nilCellModel(IndexPath)
    
    /// `UITableView` requested a cell for `model`, however `DTTableViewManager` does not have mapping for it
    case noCellMappings(model: Any)
    
    /// `UITableView` requested a header or footer, however header or footer at `section` is nil.
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
final class TableViewFactory
{
    fileprivate let tableView: UITableView
    
    var mappings = [ViewModelMapping]()
    
    weak var mappingCustomizableDelegate : ViewModelMappingCustomizing?
    
    init(tableView: UITableView)
    {
        self.tableView = tableView
    }
    
    func registerCellClass<T:ModelTransfer>(_ cellClass : T.Type) where T: UITableViewCell
    {
        let reuseIdentifier = String(describing: T.self)
        if tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) == nil
        {
            self.tableView.register(T.self, forCellReuseIdentifier: reuseIdentifier)
            
            if UINib.nibExists(withNibName: reuseIdentifier, inBundle: Bundle(for: T.self)) {
                registerNibNamed(reuseIdentifier, forCellClass: T.self)
            }
            else {
                mappings.addMapping(for: .cell, viewClass: T.self)
            }
        }
        else {
            // Storyboard prototype cell
            mappings.addMapping(for: .cell, viewClass: T.self)
        }
    }
    
    func registerNibNamed<T:ModelTransfer>(_ nibName : String, forCellClass cellClass: T.Type) where T: UITableViewCell
    {
        assert(UINib.nibExists(withNibName: nibName, inBundle: Bundle(for: T.self)), "Register cell nib method should be called only if nib exists")
        
        let nib = UINib(nibName: nibName, bundle: Bundle(for: T.self))
        let reuseIdentifier = String(describing: T.self)
        self.tableView.register(nib, forCellReuseIdentifier: reuseIdentifier)
        mappings.addMapping(for: .cell, viewClass: T.self, xibName: nibName)
    }
    
    func registerNiblessHeaderClass<T:ModelTransfer>(_ headerClass : T.Type) where T: UIView
    {
        let reuseIdentifier = String(describing: T.self)
        tableView.register(headerClass, forHeaderFooterViewReuseIdentifier: reuseIdentifier)
        mappings.addMapping(for: .supplementaryView(kind: DTTableViewElementSectionHeader), viewClass: T.self)
    }
    
    func registerNiblessFooterClass<T:ModelTransfer>(_ footerClass : T.Type) where T: UIView
    {
        let reuseIdentifier = String(describing: T.self)
        tableView.register(footerClass, forHeaderFooterViewReuseIdentifier: reuseIdentifier)
        mappings.addMapping(for: .supplementaryView(kind: DTTableViewElementSectionFooter), viewClass: T.self)
    }
    
    func registerHeaderClass<T:ModelTransfer>(_ headerClass : T.Type) where T: UIView
    {
        self.registerNibNamed(String(describing: T.self), forHeaderClass: headerClass)
    }
    
    func registerFooterClass<T:ModelTransfer>(_ footerClass: T.Type) where T:UIView
    {
        self.registerNibNamed(String(describing: T.self), forFooterClass: footerClass)
    }
    
    func registerNibNamed<T:ModelTransfer>(_ nibName: String, forHeaderClass headerClass: T.Type) where T:UIView
    {
        assert(UINib.nibExists(withNibName: nibName, inBundle: Bundle(for: T.self)), "Register header nib method should be called only if nib exists")
        let reuseIdentifier = String(describing: T.self)
        
        if T.isSubclass(of: UITableViewHeaderFooterView.self) {
            self.tableView.register(UINib(nibName: nibName, bundle: Bundle(for: T.self)), forHeaderFooterViewReuseIdentifier: reuseIdentifier)
        }
        mappings.addMapping(for: .supplementaryView(kind: DTTableViewElementSectionHeader), viewClass: T.self, xibName: nibName)
    }
    
    func registerNibNamed<T:ModelTransfer>(_ nibName: String, forFooterClass footerClass: T.Type) where T:UIView
    {
        assert(UINib.nibExists(withNibName: nibName, inBundle: Bundle(for: T.self)), "Register footer nib method should be called only if nib exists")
        let reuseIdentifier = String(describing: T.self)
        
        if T.isSubclass(of: UITableViewHeaderFooterView.self) {
            tableView.register(UINib(nibName: nibName, bundle: Bundle(for: T.self)), forHeaderFooterViewReuseIdentifier: reuseIdentifier)
        }
        mappings.addMapping(for: .supplementaryView(kind: DTTableViewElementSectionFooter), viewClass: T.self, xibName: nibName)
    }
    
    func unregisterCellClass<T:ModelTransfer>(_ cellClass: T.Type) where T: UITableViewCell {
        mappings = mappings.filter({ mapping in
            if mapping.viewClass is T.Type && mapping.viewType == .cell { return false }
            return true
        })
        let nilClass : AnyClass? = nil
        let nilNib : UINib? = nil
        tableView.register(nilClass, forCellReuseIdentifier: String(describing: T.self))
        tableView.register(nilNib, forCellReuseIdentifier: String(describing: T.self))
    }
    
    func unregisterHeaderClass<T:ModelTransfer>(_ headerClass: T.Type) where T: UIView {
        mappings = mappings.filter({ mapping in
            if mapping.viewClass is T.Type && mapping.viewType == .supplementaryView(kind: DTTableViewElementSectionHeader) { return false }
            return true
        })
        let nilClass : AnyClass? = nil
        let nilNib : UINib? = nil
        tableView.register(nilClass, forHeaderFooterViewReuseIdentifier: String(describing: T.self))
        tableView.register(nilNib, forHeaderFooterViewReuseIdentifier: String(describing: self))
    }
    
    func unregisterFooterClass<T:ModelTransfer>(_ footerClass: T.Type) where T: UIView {
        mappings = mappings.filter({ mapping in
            if mapping.viewClass is T.Type && mapping.viewType == .supplementaryView(kind: DTTableViewElementSectionFooter) { return false }
            return true
        })
        let nilClass : AnyClass? = nil
        let nilNib : UINib? = nil
        tableView.register(nilClass, forHeaderFooterViewReuseIdentifier: String(describing: T.self))
        tableView.register(nilNib, forHeaderFooterViewReuseIdentifier: String(describing: self))
    }
    
    func viewModelMapping(for viewType: ViewType, model: Any) -> ViewModelMapping?
    {
        guard let unwrappedModel = RuntimeHelper.recursivelyUnwrapAnyValue(model) else {
            return nil
        }
        let mappingCandidates = mappings.mappingCandidates(for: viewType, withModel: unwrappedModel)
        
        if let customizedMapping = mappingCustomizableDelegate?.viewModelMapping(fromCandidates: mappingCandidates, forModel: unwrappedModel) {
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
        
        if let mapping = viewModelMapping(for: .cell, model: unwrappedModel)
        {
            let cellClassName = String(describing: mapping.viewClass)
            let cell = tableView.dequeueReusableCell(withIdentifier: cellClassName, for: indexPath)
            mapping.updateBlock(cell, unwrappedModel)
            return cell
        }
        
        throw DTTableViewFactoryError.noCellMappings(model: unwrappedModel)
    }
    
    func updateCellAt(_ indexPath : IndexPath, with model: Any) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        guard let unwrappedModel = RuntimeHelper.recursivelyUnwrapAnyValue(model) else { return }
        if let mapping = viewModelMapping(for: .cell, model: unwrappedModel) {
            mapping.updateBlock(cell, unwrappedModel)
        }
    }
    
    func headerFooterViewWithMapping(_ mapping: ViewModelMapping, unwrappedModel: Any) -> UIView?
    {
        let viewClassName = String(describing: mapping.viewClass)
        if let view = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: viewClassName) {
            mapping.updateBlock(view,unwrappedModel)
            return view
        }
        else {
            var view : UIView? = nil
            
            if let type = mapping.viewClass as? UIView.Type {
                view = type.dt_loadFromXib()
            }
            
            if let view = view {
                mapping.updateBlock(view,unwrappedModel)
            }
            return view
        }
    }
    
    func headerFooterView(of type: ViewType, model : Any, atIndexPath indexPath: IndexPath) throws -> UIView?
    {
        guard let unwrappedModel = RuntimeHelper.recursivelyUnwrapAnyValue(model) else {
            throw DTTableViewFactoryError.nilHeaderFooterModel(section: (indexPath as NSIndexPath).section)
        }
        
        if let mapping = viewModelMapping(for: type, model: unwrappedModel) {
            return headerFooterViewWithMapping(mapping, unwrappedModel: unwrappedModel)
        }
        
        return nil
    }
    
    func headerViewForModel(_ model: Any, atIndexPath indexPath: IndexPath) throws -> UIView?
    {
        return try headerFooterView(of: .supplementaryView(kind: DTTableViewElementSectionHeader),
            model: model, atIndexPath: indexPath)
    }
    
    func footerViewForModel(_ model: Any, atIndexPath indexPath: IndexPath) throws -> UIView?
    {
        return try headerFooterView(of: .supplementaryView(kind: DTTableViewElementSectionFooter),
            model: model, atIndexPath: indexPath)
    }
}
