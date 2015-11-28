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

/// Internal class, that is used to create table view cells, headers and footers.
class TableViewFactory
{
    private let tableView: UITableView
    
    private var mappings = [ViewModelMapping]()
    
    var bundle = NSBundle.mainBundle()
    
    init(tableView: UITableView)
    {
        self.tableView = tableView
    }
    
    func registerCellClass<T:ModelTransfer where T: UITableViewCell>(cellClass : T.Type)
    {
        let reuseIdentifier = String(T)
        if self.tableView.dequeueReusableCellWithIdentifier(reuseIdentifier) == nil
        {
            // Storyboard prototype cell
            self.tableView.registerClass(T.self, forCellReuseIdentifier: reuseIdentifier)
            
            if UINib.nibExistsWithNibName(reuseIdentifier, inBundle: bundle) {
                self.registerNibNamed(reuseIdentifier, forCellClass: T.self)
            }
        }
        mappings.addMappingForViewType(.Cell, viewClass: T.self)
    }
    
    func registerNibNamed<T:ModelTransfer where T: UITableViewCell>(nibName : String, forCellClass cellClass: T.Type)
    {
        assert(UINib.nibExistsWithNibName(nibName, inBundle: bundle), "Register cell nib method should be called only if nib exists")
        
        let nib = UINib(nibName: nibName, bundle: bundle)
        let reuseIdentifier = String(T)
        self.tableView.registerNib(nib, forCellReuseIdentifier: reuseIdentifier)
        mappings.addMappingForViewType(.Cell, viewClass: T.self)
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
        mappings.addMappingForViewType(.SupplementaryView(kind: DTTableViewElementSectionHeader), viewClass: T.self)
    }
    
    func registerNibNamed<T:ModelTransfer where T:UIView>(nibName: String, forFooterClass footerClass: T.Type)
    {
        assert(UINib.nibExistsWithNibName(nibName, inBundle: bundle), "Register footer nib method should be called only if nib exists")
        let reuseIdentifier = String(T.self)
        
        if T.isSubclassOfClass(UITableViewHeaderFooterView.self) {
            self.tableView.registerNib(UINib(nibName: nibName, bundle: bundle), forHeaderFooterViewReuseIdentifier: reuseIdentifier)
        }
        mappings.addMappingForViewType(.SupplementaryView(kind: DTTableViewElementSectionFooter), viewClass: T.self)
    }
    
    func cellForModel(model: Any, atIndexPath indexPath:NSIndexPath) -> UITableViewCell
    {
        guard let unwrappedModel = RuntimeHelper.recursivelyUnwrapAnyValue(model) else {
            preconditionFailure("Received nil model at indexPath: \(indexPath)")
        }
        
        if let mapping = mappings.mappingCandidatesForViewType(.Cell, model: unwrappedModel).first
        {
            let cellClassName = String(mapping.viewClass)
            let cell = tableView.dequeueReusableCellWithIdentifier(cellClassName, forIndexPath: indexPath)
            mapping.updateBlock(cell, unwrappedModel)
            return cell
        }
        
        preconditionFailure("Unable to find cell mappings for type: \(model)")
    }
    
    func headerFooterViewWithMapping(mapping: ViewModelMapping, unwrappedModel: Any) -> UIView?
    {
        let viewClassName = String(mapping.viewClass)
        if let view = self.tableView.dequeueReusableHeaderFooterViewWithIdentifier(viewClassName) {
            mapping.updateBlock(view,unwrappedModel)
            return view
        }
        else {
            let view : UIView?
            
            // Unfortunately, Swift 2.1 does not allow casting AnyClass.Type to UIView.Type even conditionally,
            // that's why we're forced to cast through reflect value
            let mirror = _reflect(mapping.viewClass)
            if let type = mirror.value as? UIView.Type  {
                view = type.dt_loadFromXibInBundle(bundle)
            }
            else {
                view = nil
            }
            
            precondition(view != nil,"failed creating view of type: \(viewClassName) for model: \(unwrappedModel)")
            
            mapping.updateBlock(view!,unwrappedModel)
            return view
        }
    }
    
    private func headerFooterViewOfType(type: ViewType, model : Any) -> UIView?
    {
        let unwrappedModel = RuntimeHelper.recursivelyUnwrapAnyValue(model)
        
        precondition(unwrappedModel != nil, "Received nil model for headerFooterViewModel")
        
        if let mapping = mappings.mappingCandidatesForViewType(type, model: unwrappedModel).first {
            return self.headerFooterViewWithMapping(mapping, unwrappedModel: unwrappedModel!)
        }
        
        return nil
    }
    
    func headerViewForModel(model: Any) -> UIView?
    {
        return self.headerFooterViewOfType(.SupplementaryView(kind: DTTableViewElementSectionHeader), model: model)
    }
    
    func footerViewForModel(model: Any) -> UIView?
    {
        return self.headerFooterViewOfType(.SupplementaryView(kind: DTTableViewElementSectionFooter), model: model)
    }
}
