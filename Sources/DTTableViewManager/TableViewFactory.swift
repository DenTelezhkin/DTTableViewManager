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
final class TableViewFactory
{
    fileprivate let tableView: UITableView
    
    var mappings = [ViewModelMappingProtocol]()
    
    weak var anomalyHandler : DTTableViewManagerAnomalyHandler?
    
    init(tableView: UITableView)
    {
        self.tableView = tableView
    }
    
    func registerCellClass<T:ModelTransfer>(_ cellClass : T.Type, handler: @escaping (T, T.ModelType, IndexPath) -> Void, mapping: ((ViewModelMapping<T, T.ModelType>) -> Void)?) where T: UITableViewCell
    {
        let mapping = ViewModelMapping<T, T.ModelType>(cellConfiguration: handler, mapping: mapping)
        if let cell = tableView.dequeueReusableCell(withIdentifier: mapping.reuseIdentifier) {
            // Storyboard prototype cell
            if let cellReuseIdentifier = cell.reuseIdentifier, cellReuseIdentifier != mapping.reuseIdentifier {
                anomalyHandler?.reportAnomaly(.differentCellReuseIdentifier(mappingReuseIdentifier: mapping.reuseIdentifier, cellReuseIdentifier: cellReuseIdentifier))
            }
        } else {
            if let xibName = mapping.xibName, UINib.nibExists(withNibName: xibName, inBundle: mapping.bundle) {
                let nib = UINib(nibName: xibName, bundle: mapping.bundle)
                tableView.register(nib, forCellReuseIdentifier: mapping.reuseIdentifier)
            } else {
                tableView.register(T.self, forCellReuseIdentifier: mapping.reuseIdentifier)
            }
        }
        mappings.append(mapping)
        verifyCell(T.self, nibName: mapping.xibName, withReuseIdentifier: mapping.reuseIdentifier, in: mapping.bundle)
    }
    
    func registerCellClass<T: UITableViewCell, U>(_ cellType: T.Type, _ modelType: U.Type, handler: @escaping (T, U, IndexPath) -> Void, mapping: ((ViewModelMapping<T, U>) -> Void)? = nil)
    {
        let mapping = ViewModelMapping<T, U>(cellConfiguration: handler, mapping: mapping)
        if let cell = tableView.dequeueReusableCell(withIdentifier: mapping.reuseIdentifier) {
            // Storyboard prototype cell
            if let cellReuseIdentifier = cell.reuseIdentifier, cellReuseIdentifier != mapping.reuseIdentifier {
                anomalyHandler?.reportAnomaly(.differentCellReuseIdentifier(mappingReuseIdentifier: mapping.reuseIdentifier, cellReuseIdentifier: cellReuseIdentifier))
            }
        } else {
            if UINib.nibExists(withNibName: mapping.xibName ?? "", inBundle: mapping.bundle) {
                let nib = UINib(nibName: mapping.xibName ?? "", bundle: mapping.bundle)
                tableView.register(nib, forCellReuseIdentifier: mapping.reuseIdentifier)
            } else {
                tableView.register(T.self, forCellReuseIdentifier: mapping.reuseIdentifier)
            }
        }
        mappings.append(mapping)
        verifyCell(T.self, nibName: mapping.xibName, withReuseIdentifier: mapping.reuseIdentifier, in: mapping.bundle)
    }
    
    func verifyCell<T:UITableViewCell>(_ cell: T.Type,
                                       nibName: String?,
                                       withReuseIdentifier reuseIdentifier: String,
                                       in bundle: Bundle) {
        var cell = T(frame: .zero)
        if let nibName = nibName, UINib.nibExists(withNibName: nibName, inBundle: bundle) {
            let nib = UINib(nibName: nibName, bundle: bundle)
            let objects = nib.instantiate(withOwner: cell, options: nil)
            if let instantiatedCell = objects.first as? T {
                cell = instantiatedCell
            } else {
                if let first = objects.first {
                    anomalyHandler?.reportAnomaly(.differentCellClass(xibName: nibName,
                                                                      cellClass: String(describing: type(of: first)),
                                                                      expectedCellClass: String(describing: T.self)))
                } else {
                    anomalyHandler?.reportAnomaly(.emptyXibFile(xibName: nibName, expectedViewClass: String(describing: T.self)))
                }
            }
        }
        if let cellReuseIdentifier = cell.reuseIdentifier, cellReuseIdentifier != reuseIdentifier {
            anomalyHandler?.reportAnomaly(.differentCellReuseIdentifier(mappingReuseIdentifier: reuseIdentifier, cellReuseIdentifier: cellReuseIdentifier))
        }
    }
    
    func verifyHeaderFooterView<T:UIView>(_ view: T.Type, nibName: String?, in bundle: Bundle) {
        var view = T(frame: .zero)
        if let nibName = nibName, UINib.nibExists(withNibName: nibName, inBundle: bundle) {
            let nib = UINib(nibName: nibName, bundle: bundle)
            let objects = nib.instantiate(withOwner: view, options: nil)
            if let instantiatedView = objects.first as? T {
                view = instantiatedView
            } else {
                if let first = objects.first {
                    anomalyHandler?.reportAnomaly(.differentHeaderFooterClass(xibName: nibName,
                                                                              viewClass: String(describing: type(of: first)),
                                                                              expectedViewClass: String(describing: T.self)))
                } else {
                    anomalyHandler?.reportAnomaly(.emptyXibFile(xibName: nibName, expectedViewClass: String(describing: T.self)))
                }
            }
        }
    }
    
    func registerSupplementaryClass<T:ModelTransfer>(_ supplementaryClass: T.Type, ofKind kind: String, handler: @escaping (T, T.ModelType, Int) -> Void, mapping: ((ViewModelMapping<T, T.ModelType>) -> Void)?) where T:UIView
    {
        let mapping = ViewModelMapping<T, T.ModelType>(kind: kind, headerFooterConfiguration: handler, mapping: mapping)
        
        if T.isSubclass(of: UITableViewHeaderFooterView.self) {
            if let nibName = mapping.xibName, UINib.nibExists(withNibName: nibName, inBundle: mapping.bundle) {
                let nib = UINib(nibName: nibName, bundle: mapping.bundle)
                tableView.register(nib, forHeaderFooterViewReuseIdentifier: mapping.reuseIdentifier)
            } else {
                tableView.register(T.self, forHeaderFooterViewReuseIdentifier: mapping.reuseIdentifier)
            }
        }
        mappings.append(mapping)
        verifyHeaderFooterView(T.self, nibName: mapping.xibName, in: mapping.bundle)
    }
    
    func registerSupplementaryClass<T, U>(_ supplementaryClass: T.Type, ofKind kind: String, handler: @escaping (T, U, Int) -> Void, mapping: ((ViewModelMapping<T, U>) -> Void)?) where T:UIView
    {
        let mapping = ViewModelMapping<T, U>(kind: kind, headerFooterConfiguration: handler, mapping: mapping)
        
        if T.isSubclass(of: UITableViewHeaderFooterView.self) {
            if let nibName = mapping.xibName, UINib.nibExists(withNibName: nibName, inBundle: mapping.bundle) {
                let nib = UINib(nibName: nibName, bundle: mapping.bundle)
                tableView.register(nib, forHeaderFooterViewReuseIdentifier: mapping.reuseIdentifier)
            } else {
                tableView.register(T.self, forHeaderFooterViewReuseIdentifier: mapping.reuseIdentifier)
            }
        }
        mappings.append(mapping)
        verifyHeaderFooterView(T.self, nibName: mapping.xibName, in: mapping.bundle)
    }
    
    func unregisterCellClass<T:ModelTransfer>(_ cellClass: T.Type) where T: UITableViewCell {
        mappings = mappings.filter({ (mapping) -> Bool in
            if mapping.viewClass is T.Type && mapping.viewType == .cell { return false }
            return true
        })
        tableView.register(nil as AnyClass?, forCellReuseIdentifier: String(describing: T.self))
        tableView.register(nil as UINib?, forCellReuseIdentifier: String(describing: T.self))
    }
    
    func unregisterHeaderClass<T:ModelTransfer>(_ headerClass: T.Type) where T: UIView {
        mappings = mappings.filter({ mapping in
            if mapping.viewClass is T.Type && mapping.viewType == .supplementaryView(kind: DTTableViewElementSectionHeader) { return false }
            return true
        })
        tableView.register(nil as AnyClass?, forHeaderFooterViewReuseIdentifier: String(describing: T.self))
        tableView.register(nil as UINib?, forHeaderFooterViewReuseIdentifier: String(describing: self))
    }
    
    func unregisterFooterClass<T:ModelTransfer>(_ footerClass: T.Type) where T: UIView {
        mappings = mappings.filter({ mapping in
            if mapping.viewClass is T.Type && mapping.viewType == .supplementaryView(kind: DTTableViewElementSectionFooter) { return false }
            return true
        })
        tableView.register(nil as AnyClass?, forHeaderFooterViewReuseIdentifier: String(describing: T.self))
        tableView.register(nil as UINib?, forHeaderFooterViewReuseIdentifier: String(describing: self))
    }
    
    func viewModelMapping(for viewType: ViewType, model: Any, indexPath: IndexPath) -> ViewModelMappingProtocol?
    {
        guard let unwrappedModel = RuntimeHelper.recursivelyUnwrapAnyValue(model) else {
            return nil
        }
        return viewType.mappingCandidates(for: mappings, withModel: unwrappedModel, at: indexPath).first
    }
    
    func cellForModel(_ model: Any, atIndexPath indexPath:IndexPath) -> UITableViewCell?
    {
        if let mapping = viewModelMapping(for: .cell, model: model, indexPath: indexPath)
        {
            return mapping.dequeueConfiguredReusableCell(for: tableView, model: model, indexPath: indexPath)
        }
        anomalyHandler?.reportAnomaly(.noCellMappingFound(modelDescription: String(describing: model), indexPath: indexPath))
        return nil
    }
    
    func updateCellAt(_ indexPath : IndexPath, with model: Any) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        guard let unwrappedModel = RuntimeHelper.recursivelyUnwrapAnyValue(model) else { return }
        if let mapping = viewModelMapping(for: .cell, model: unwrappedModel, indexPath: indexPath) {
            mapping.updateBlock(cell, unwrappedModel)
        }
    }
    
    func headerFooterView(of type: ViewType, model : Any, atIndexPath indexPath: IndexPath) -> UIView?
    {
        guard let mapping = viewModelMapping(for: type, model: model, indexPath: indexPath) else {
            anomalyHandler?.reportAnomaly(.noHeaderFooterMappingFound(modelDescription: String(describing: model), indexPath: indexPath))
            return nil
        }
      
        return mapping.dequeueConfiguredReusableSupplementaryView(for: tableView, kind: type.supplementaryKind() ?? "", model: model, indexPath: indexPath)
    }
}
