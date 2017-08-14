
//
//  TableViewController.swift
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 12.07.15.
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

import Foundation
import UIKit
import DTModelStorage

/// Adopting this protocol will automatically inject `manager` property to your object, that lazily instantiates `DTTableViewManager` object.
/// Target is not required to be `UITableViewController`, and can be a regular UIViewController with UITableView, or even different object like UICollectionViewCell.
public protocol DTTableViewManageable : class
{
    /// Table view, that will be managed by DTTableViewManager
    var tableView : UITableView! { get }
}

/// This protocol is similar to `DTTableViewManageable`, but allows using optional `UITableView` property.
public protocol DTTableViewOptionalManageable : class {
    var tableView : UITableView? { get }
}

/// This key is used to store `DTTableViewManager` instance on `DTTableViewManageable` class using object association.
private var DTTableViewManagerAssociatedKey = "DTTableViewManager Associated Key"

/// Default implementation for `DTTableViewManageable` protocol, that will inject `manager` property to any object, that declares itself `DTTableViewManageable`.
extension DTTableViewManageable
{
    /// Lazily instantiated `DTTableViewManager` instance. When your table view is loaded, call startManagingWithDelegate: method and `DTTableViewManager` will take over UITableView datasource and delegate. Any method, that is not implemented by `DTTableViewManager`, will be forwarded to delegate.
    /// - SeeAlso: `startManagingWithDelegate:`
    public var manager : DTTableViewManager {
        get {
            if let manager = objc_getAssociatedObject(self, &DTTableViewManagerAssociatedKey) as? DTTableViewManager {
                return manager
            }
            let manager = DTTableViewManager()
            objc_setAssociatedObject(self, &DTTableViewManagerAssociatedKey, manager, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return manager
        }
        set {
            objc_setAssociatedObject(self, &DTTableViewManagerAssociatedKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

extension DTTableViewOptionalManageable {
    /// Lazily instantiated `DTTableViewManager` instance. When your table view is loaded, call startManagingWithDelegate: method and `DTTableViewManager` will take over UITableView datasource and delegate. Any method, that is not implemented by `DTTableViewManager`, will be forwarded to delegate.
    /// - SeeAlso: `startManagingWithDelegate:`
    public var manager : DTTableViewManager {
        get {
            if let manager = objc_getAssociatedObject(self, &DTTableViewManagerAssociatedKey) as? DTTableViewManager {
                return manager
            }
            let manager = DTTableViewManager()
            objc_setAssociatedObject(self, &DTTableViewManagerAssociatedKey, manager, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return manager
        }
        set {
            objc_setAssociatedObject(self, &DTTableViewManagerAssociatedKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

/// `DTTableViewManager` manages many of `UITableView` datasource and delegate methods and provides API for managing your data models in the table. Any method, that is not implemented by `DTTableViewManager`, will be forwarded to delegate.
/// - SeeAlso: `startManagingWithDelegate:`
open class DTTableViewManager {
    
    /// Internal weak link to `UITableView`
    final var tableView : UITableView?
    {
        if let delegate = delegate as? DTTableViewManageable { return delegate.tableView }
        if let delegate = delegate as? DTTableViewOptionalManageable { return delegate.tableView }
        return nil
    }
    
    /// `DTTableViewManageable` delegate.
    final fileprivate weak var delegate : AnyObject?
    
    /// Bool property, that will be true, after `startManagingWithDelegate` method is called on `DTTableViewManager`.
    open var isManagingTableView : Bool {
        return tableView != nil
    }

    ///  Factory for creating cells and views for UITableView
    final lazy var viewFactory: TableViewFactory = {
        precondition(self.isManagingTableView, "Please call manager.startManagingWithDelegate(self) before calling any other DTTableViewManager methods")
        return TableViewFactory(tableView: self.tableView!)
    }()
    
    /// Stores all configuration options for `DTTableViewManager`.
    /// - SeeAlso: `TableViewConfiguration`.
    open var configuration = TableViewConfiguration()
    
    /// Error handler ot be executed when critical error happens with `TableViewFactory`.
    /// This can be useful to provide more debug information for crash logs, since preconditionFailure Swift method provides little to zero insight about what happened and when.
    /// This closure will be called prior to calling preconditionFailure in `handleTableViewFactoryError` method.
    @nonobjc open var viewFactoryErrorHandler : ((DTTableViewFactoryError) -> Void)?
    
    /// Implicitly unwrap storage property to `MemoryStorage`.
    /// - Warning: if storage is not MemoryStorage, will throw an exception.
    open var memoryStorage : MemoryStorage!
    {
        guard let storage = storage as? MemoryStorage else {
            assertionFailure("DTTableViewManager memoryStorage method should be called only if you are using MemoryStorage")
            return nil
        }
        return storage
    }
    
    /// Storage, that holds your UITableView models. By default, it's `MemoryStorage` instance.
    /// - Note: When setting custom storage for this property, it will be automatically configured for using with UITableView and it's delegate will be set to `DTTableViewManager` instance.
    /// - Note: Previous storage `delegate` property will be nilled out to avoid collisions.
    /// - SeeAlso: `MemoryStorage`, `CoreDataStorage`, `RealmStorage`.
    open var storage : Storage = {
        let storage = MemoryStorage()
        storage.configureForTableViewUsage()
        return storage
    }()
    {
        willSet {
            storage.delegate = nil
        }
        didSet {
            if let headerFooterCompatibleStorage = storage as? BaseStorage {
                headerFooterCompatibleStorage.configureForTableViewUsage()
            }
            storage.delegate = tableViewUpdater
        }
    }
    
    /// Object, that is responsible for updating `UITableView`, when received update from `Storage`
    open var tableViewUpdater : StorageUpdating? {
        didSet {
            storage.delegate = tableViewUpdater
            (tableViewUpdater as? TableViewUpdater)?.didUpdateContent?(nil)
        }
    }
    
    /// Object, that is responsible for implementing `UITableViewDelegate` protocol.
    open var tableDelegate: DTTableViewDelegate? {
        didSet {
            tableView?.delegate = tableDelegate
        }
    }
    
    /// Object, that is responsible for implementing `UITableViewDataSource` protocol.
    open var tableDataSource: DTTableViewDataSource? {
        didSet {
            tableView?.dataSource = tableDataSource
        }
    }
    
    /// Starts managing `UITableView`.
    ///
    /// Call this method before calling any of `DTTableViewManager` methods.
    /// - Precondition: UITableView instance on `delegate` should not be nil.
    /// - Note: If delegate is `DTViewModelMappingCustomizable`, it will also be used to determine which view-model mapping should be used by table view factory.
    open func startManaging(withDelegate delegate : DTTableViewManageable)
    {
        guard let tableView = delegate.tableView else {
            preconditionFailure("Call startManagingWithDelegate: method only when UITableView has been created")
        }
        self.delegate = delegate
        startManaging(with: tableView)
    }
    
    /// Starts managing `UITableView`.
    ///
    /// Call this method before calling any of `DTTableViewManager` methods.
    /// - Precondition: UITableView instance on `delegate` should not be nil.
    /// - Note: If delegate is `DTViewModelMappingCustomizable`, it will also be used to determine which view-model mapping should be used by table view factory.
    open func startManaging(withDelegate delegate : DTTableViewOptionalManageable)
    {
        guard let tableView = delegate.tableView else {
            preconditionFailure("Call startManagingWithDelegate: method only when UITableView has been created")
        }
        self.delegate = delegate
        startManaging(with: tableView)
    }
    
    fileprivate func startManaging(with tableView: UITableView) {
        if let mappingDelegate = delegate as? ViewModelMappingCustomizing {
            viewFactory.mappingCustomizableDelegate = mappingDelegate
        }
        tableViewUpdater = TableViewUpdater(tableView: tableView)
        tableDelegate = DTTableViewDelegate(delegate: delegate, tableViewManager: self)
        tableDataSource = DTTableViewDataSource(delegate: delegate, tableViewManager: self)
    }
    
    /// Returns closure, that updates cell at provided indexPath. 
    ///
    /// This is used by `coreDataUpdater` method and can be used to silently update a cell without reload row animation.
    open func updateCellClosure() -> (IndexPath,Any) -> Void {
        return { [weak self] indexPath, model in
            self?.viewFactory.updateCellAt(indexPath, with: model)
        }
    }
    
    /// Returns `TableViewUpdater`, configured to work with `CoreDataStorage` and `NSFetchedResultsController` updates.
    /// 
    /// - Precondition: UITableView instance on `delegate` should not be nil.
    open func coreDataUpdater() -> TableViewUpdater {
        guard let tableView = tableView else {
            preconditionFailure("Call startManagingWithDelegate: method only when UITableView has been created")
        }
        return TableViewUpdater(tableView: tableView,
                                reloadRow: updateCellClosure(),
                                animateMoveAsDeleteAndInsert: true)
    }
}

// MARK: - View registration
extension DTTableViewManager
{
    /// Registers mapping from model class to `cellClass`. 
    ///
    /// Method will automatically check for nib with the same name as `cellClass`. If it exists - nib will be registered instead of class.
    open func register<T:ModelTransfer>(_ cellClass:T.Type, mapping: ((ViewModelMapping) -> Void)? = nil) where T: UITableViewCell
    {
        self.viewFactory.registerCellClass(cellClass, mappingBlock: mapping)
    }

    /// Registers nib with `nibName` mapping from model class to `cellClass`.
    open func registerNibNamed<T:ModelTransfer>(_ nibName: String, for cellClass: T.Type, mapping: ((ViewModelMapping) -> Void)? = nil) where T: UITableViewCell
    {
        self.viewFactory.registerNibNamed(nibName, forCellClass: cellClass, mappingBlock: mapping)
    }
    
    /// Registers mapping from model class to header view of `headerClass` type.
    ///
    /// Method will automatically check for nib with the same name as `headerClass`. If it exists - nib will be registered instead of class.
    /// This method also sets TableViewConfiguration.sectionHeaderStyle property to .view.
    /// - Note: Views does not need to be `UITableViewHeaderFooterView`, if it's a `UIView` subclass, it also will be created from XIB.
    /// - SeeAlso: `UIView+XibLoading`.
    open func registerHeader<T:ModelTransfer>(_ headerClass : T.Type, mapping: ((ViewModelMapping) -> Void)? = nil) where T: UIView
    {
        configuration.sectionHeaderStyle = .view
        self.viewFactory.registerHeaderClass(headerClass, mappingBlock: mapping)
    }
    
    /// Registers mapping from model class to header view of `headerClass` type.
    ///
    /// This method is intended to be used for headers created from code - without UI made in XIB.
    /// This method also sets TableViewConfiguration.sectionHeaderStyle property to .view.
    open func registerNiblessHeader<T:ModelTransfer>(_ headerClass : T.Type, mapping: ((ViewModelMapping) -> Void)? = nil) where T: UITableViewHeaderFooterView
    {
        configuration.sectionHeaderStyle = .view
        self.viewFactory.registerNiblessHeaderClass(headerClass, mappingBlock: mapping)
    }
    
    /// Registers mapping from model class to footer view of `footerClass` type.
    ///
    /// This method is intended to be used for footers created from code - without UI made in XIB.
    /// This method also sets TableViewConfiguration.sectionFooterStyle property to .view.
    open func registerNiblessFooter<T:ModelTransfer>(_ footerClass : T.Type, mapping: ((ViewModelMapping) -> Void)? = nil) where T: UITableViewHeaderFooterView
    {
        configuration.sectionFooterStyle = .view
        self.viewFactory.registerNiblessFooterClass(footerClass, mappingBlock: mapping)
    }
    
    /// Registers mapping from model class to footerView view of `footerClass` type.
    ///
    /// Method will automatically check for nib with the same name as `footerClass`. If it exists - nib will be registered instead of class.
    /// This method also sets TableViewConfiguration.sectionFooterStyle property to .view.
    /// - Note: Views does not need to be `UITableViewHeaderFooterView`, if it's a `UIView` subclass, it also will be created from XIB.
    /// - SeeAlso: `UIView+XibLoading`.
    open func registerFooter<T:ModelTransfer>(_ footerClass: T.Type, mapping: ((ViewModelMapping) -> Void)? = nil) where T:UIView
    {
        configuration.sectionFooterStyle = .view
        viewFactory.registerFooterClass(footerClass, mappingBlock: mapping)
    }
    
    /// Registers mapping from model class to headerView view of `headerClass` type with `nibName`.
    ///
    /// This method also sets TableViewConfiguration.sectionHeaderStyle property to .view.
    /// - Note: Views does not need to be `UITableViewHeaderFooterView`, if it's a `UIView` subclass, it also will be created from XIB.
    /// - SeeAlso: `UIView+XibLoading`.
    open func registerNibNamed<T:ModelTransfer>(_ nibName: String, forHeader headerClass: T.Type, mapping: ((ViewModelMapping) -> Void)? = nil) where T:UIView
    {
        configuration.sectionHeaderStyle = .view
        viewFactory.registerNibNamed(nibName, forHeaderClass: headerClass, mappingBlock: mapping)
    }
    
    /// Registers mapping from model class to headerView view of `footerClass` type with `nibName`.
    ///
    /// This method also sets TableViewConfiguration.sectionFooterStyle property to .view.
    /// - Note: Views does not need to be `UITableViewHeaderFooterView`, if it's a `UIView` subclass, it also will be created from XIB.
    /// - SeeAlso: `UIView+XibLoading`.
    open func registerNibNamed<T:ModelTransfer>(_ nibName: String, forFooter footerClass: T.Type, mapping: ((ViewModelMapping) -> Void)? = nil) where T:UIView
    {
        configuration.sectionFooterStyle = .view
        viewFactory.registerNibNamed(nibName, forFooterClass: footerClass, mappingBlock: mapping)
    }
    
    /// Unregisters `cellClass` from `DTTableViewManager` and `UITableView`.
    open func unregister<T:ModelTransfer>(_ cellClass: T.Type) where T:UITableViewCell {
        viewFactory.unregisterCellClass(T.self)
    }
    
    /// Unregisters `headerClass` from `DTTableViewManager` and `UITableView`.
    open func unregisterHeader<T:ModelTransfer>(_ headerClass: T.Type) where T: UIView {
        viewFactory.unregisterHeaderClass(T.self)
    }
  
    /// Unregisters `footerClass` from `DTTableViewManager` and `UITableView`.
    open func unregisterFooter<T:ModelTransfer>(_ footerClass: T.Type) where T: UIView {
        viewFactory.unregisterFooterClass(T.self)
    }
}

/// All supported Objective-C method signatures.
///
/// Some of signatures are made up, so that we would be able to link them with event, however they don't stop "responds(to:)" method from returning true.
internal enum EventMethodSignature: String {
    /// UITableViewDataSource
    case configureCell = "tableViewConfigureCell_imaginarySelector"
    case configureHeader = "tableViewConfigureHeader_imaginarySelector"
    case configureFooter = "tableViewConfigureFooter_imaginarySelector"
    case commitEditingStyleForRowAtIndexPath = "tableView:commitEditingStyle:forRowAtIndexPath:"
    case canEditRowAtIndexPath = "tableView:canEditRowAtIndexPath:"
    case canMoveRowAtIndexPath = "tableView:canMoveRowAtIndexPath:"
    case sectionIndexTitlesForTableView = "sectionIndexTitlesForTableView:"
    case sectionForSectionIndexTitleAtIndex = "tableView:sectionForSectionIndexTitle:atIndex:"
    
    /// UITableViewDelegate
    case heightForRowAtIndexPath = "tableView:heightForRowAtIndexPath:"
    case estimatedHeightForRowAtIndexPath = "tableView:estimatedHeightForRowAtIndexPath:"
    case indentationLevelForRowAtIndexPath = "tableView:indentationLevelForRowAtIndexPath:"
    case willDisplayCellForRowAtIndexPath = "tableView:willDisplayCell:forRowAtIndexPath:"
    
    case editActionsForRowAtIndexPath = "tableView:editActionsForRowAtIndexPath:"
    case accessoryButtonTappedForRowAtIndexPath = "tableView:accessoryButtonTappedForRowWithIndexPath:"
    
    case willSelectRowAtIndexPath = "tableView:willSelectRowAtIndexPath:"
    case didSelectRowAtIndexPath = "tableView:didSelectRowAtIndexPath:"
    case willDeselectRowAtIndexPath = "tableView:willDeselectRowAtIndexPath:"
    case didDeselectRowAtIndexPath = "tableView:didDeselectRowAtIndexPath:"
    
    case heightForHeaderInSection = "tableView:heightForHeaderInSection:_imaginarySelector"
    case estimatedHeightForHeaderInSection = "tableView:estimatedHeightForHeaderInSection:"
    case heightForFooterInSection = "tableView:heightForFooterInSection:_imaginarySelector"
    case estimatedHeightForFooterInSection = "tableView:estimatedHeightForFooterInSection:"
    case willDisplayHeaderForSection = "tableView:willDisplayHeaderView:forSection:"
    case willDisplayFooterForSection = "tableView:willDisplayFooterView:forSection:"
    
    case willBeginEditingRowAtIndexPath = "tableView:willBeginEditingRowAtIndexPath:"
    case didEndEditingRowAtIndexPath = "tableView:didEndEditingRowAtIndexPath:"
    case editingStyleForRowAtIndexPath = "tableView:editingStyleForRowAtIndexPath:"
    case titleForDeleteButtonForRowAtIndexPath = "tableView:titleForDeleteConfirmationButtonForRowAtIndexPath:"
    case shouldIndentWhileEditingRowAtIndexPath = "tableView:shouldIndentWhileEditingRowAtIndexPath:"
    
    case didEndDisplayingCellForRowAtIndexPath = "tableView:didEndDisplayingCell:forRowAtIndexPath:"
    case didEndDisplayingHeaderViewForSection = "tableView:didEndDisplayingHeaderView:forSection:"
    case didEndDisplayingFooterViewForSection = "tableView:didEndDisplayingFooterView:forSection:"
    
    case shouldShowMenuForRowAtIndexPath = "tableView:shouldShowMenuForRowAtIndexPath:"
    case canPerformActionForRowAtIndexPath = "tableView:canPerformAction:forRowAtIndexPath:withSender:"
    case performActionForRowAtIndexPath = "tableView:performAction:forRowAtIndexPath:withSender:"
    
    case shouldHighlightRowAtIndexPath = "tableView:shouldHighlightRowAtIndexPath:"
    case didHighlightRowAtIndexPath = "tableView:didHighlightRowAtIndexPath:"
    case didUnhighlightRowAtIndexPath = "tableView:didUnhighlightRowAtIndexPath:"
    
    case canFocusRowAtIndexPath = "tableView:canFocusRowAtIndexPath:"
}

let TableViewMoveRowAtIndexPathToIndexPathSignature = "tableView:moveRowAtIndexPath:toIndexPath:"

// MARK: - Table view reactions
extension DTTableViewManager
{
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:didSelectRowAt:)` method is called for `cellClass`.
    open func didSelect<T:ModelTransfer>(_ cellClass:  T.Type, _ closure: @escaping (T,T.ModelType, IndexPath) -> Void) where T:UITableViewCell
    {
        tableDelegate?.appendReaction(for: T.self, signature: .didSelectRowAtIndexPath, closure: closure)
    }
    
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:willSelectRowAt:)` method is called for `cellClass`.
    open func willSelect<T:ModelTransfer>(_ cellClass:  T.Type, _ closure: @escaping (T,T.ModelType, IndexPath) -> IndexPath?) where T:UITableViewCell {
        tableDelegate?.appendReaction(for: T.self, signature: .willSelectRowAtIndexPath, closure: closure)
    }
    
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:willDeselectRowAt:)` method is called for `cellClass`.
    open func willDeselect<T:ModelTransfer>(_ cellClass:  T.Type, _ closure: @escaping (T,T.ModelType, IndexPath) -> IndexPath?) where T:UITableViewCell {
        tableDelegate?.appendReaction(for: T.self, signature: .willDeselectRowAtIndexPath, closure: closure)
    }
    
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:didDeselectRowAt:)` method is called for `cellClass`.
    open func didDeselect<T:ModelTransfer>(_ cellClass:  T.Type, _ closure: @escaping (T,T.ModelType, IndexPath) -> Void) where T:UITableViewCell {
        tableDelegate?.appendReaction(for: T.self, signature: .didDeselectRowAtIndexPath, closure: closure)
    }
    
    /// Registers `closure` to be executed, when `UITableView` requests `cellClass` in `UITableViewDataSource.tableView(_:cellForRowAt:)` method and cell is being configured.
    ///
    /// This closure will be performed *after* cell is created and `update(with:)` method is called.
    open func configure<T:ModelTransfer>(_ cellClass:T.Type, _ closure: @escaping (T, T.ModelType, IndexPath) -> Void) where T: UITableViewCell
    {
        tableDataSource?.appendReaction(for: T.self, signature: .configureCell, closure: closure)
    }
    
    /// Registers `closure` to be executed, when `UITableView` requests `headerClass` in `UITableViewDelegate.tableView(_:viewForHeaderInSection:)` method and header is being configured.
    ///
    /// This closure will be performed *after* header is created and `update(with:)` method is called.
    open func configureHeader<T:ModelTransfer>(_ headerClass: T.Type, _ closure: @escaping (T, T.ModelType, Int) -> Void) where T: UIView
    {
        tableDelegate?.appendReaction(forSupplementaryKind: DTTableViewElementSectionHeader, supplementaryClass: T.self, signature: EventMethodSignature.configureHeader, closure: closure)
    }
    
    /// Registers `closure` to be executed, when `UITableView` requests `footerClass` in `UITableViewDelegate.tableView(_:viewForFooterInSection:)` method and footer is being configured.
    ///
    /// This closure will be performed *after* footer is created and `update(with:)` method is called.
    open func configureFooter<T:ModelTransfer>(_ footerClass: T.Type, _ closure: @escaping (T, T.ModelType, Int) -> Void) where T: UIView
    {
        tableDelegate?.appendReaction(forSupplementaryKind: DTTableViewElementSectionFooter, supplementaryClass: T.self, signature: EventMethodSignature.configureFooter, closure: closure)
    }
    
    /// Registers `closure` to be executed to determine cell height in `UITableViewDelegate.tableView(_:heightForRowAt:)` method, when it's called for cell which model is of `itemType`.
    open func heightForCell<T>(withItem itemType: T.Type, _ closure: @escaping (T, IndexPath) -> CGFloat) {
        tableDelegate?.appendReaction(for: T.self, signature: EventMethodSignature.heightForRowAtIndexPath, closure: closure)
    }
    
    /// Registers `closure` to be executed to determine estimated cell height in `UITableViewDelegate.tableView(_:estimatedHeightForRowAt:)` method, when it's called for cell which model is of `itemType`.
    open func estimatedHeightForCell<T>(withItem itemType: T.Type, _ closure: @escaping (T, IndexPath) -> CGFloat) {
        tableDelegate?.appendReaction(for: T.self, signature: EventMethodSignature.estimatedHeightForRowAtIndexPath, closure: closure)
    }
    
    /// Registers `closure` to be executed to determine indentation level in `UITableViewDelegate.tableView(_:indentationLevelForRowAt:)` method, when it's called for cell which model is of `itemType`.
    open func indentationLevelForCell<T>(withItem itemType: T.Type, _ closure: @escaping (T, IndexPath) -> CGFloat) {
        tableDelegate?.appendReaction(for: T.self, signature: EventMethodSignature.indentationLevelForRowAtIndexPath, closure: closure)
    }
    
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:willDisplayCell:forRowAt:)` method is called for `cellClass`.
    open func willDisplay<T:ModelTransfer>(_ cellClass:T.Type, _ closure: @escaping (T, T.ModelType, IndexPath) -> Void) where T: UITableViewCell
    {
        tableDelegate?.appendReaction(for: T.self, signature: EventMethodSignature.willDisplayCellForRowAtIndexPath, closure: closure)
    }
    
    #if os(iOS)
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:editActionsForRowAt:)` method is called for `cellClass`.
    open func editActions<T:ModelTransfer>(for cellClass: T.Type, _ closure: @escaping (T, T.ModelType, IndexPath) -> [UITableViewRowAction]?) where T: UITableViewCell {
        tableDelegate?.appendReaction(for: T.self, signature: EventMethodSignature.editActionsForRowAtIndexPath, closure: closure)
    }
    #endif
    
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:accessoryButtonTappedForRowAt:)` method is called for `cellClass`.
    open func accessoryButtonTapped<T:ModelTransfer>(in cellClass: T.Type, _ closure: @escaping (T, T.ModelType, IndexPath) -> Void) where T: UITableViewCell {
        tableDelegate?.appendReaction(for: T.self, signature: EventMethodSignature.accessoryButtonTappedForRowAtIndexPath, closure: closure)
    }
    
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:commitEditingStyle:forRowAt:)` method is called for `cellClass`.
    open func commitEditingStyle<T:ModelTransfer>(for cellClass: T.Type, _ closure: @escaping (UITableViewCellEditingStyle, T, T.ModelType, IndexPath) -> Void) where T: UITableViewCell {
        let reaction = FourArgumentsEventReaction(signature: EventMethodSignature.commitEditingStyleForRowAtIndexPath.rawValue, viewType: .cell, viewClass: T.self)
        reaction.reaction4Arguments = { style, cell, model, indexPath in
            guard let style = style as? UITableViewCellEditingStyle,
                let cell = cell as? T,
                let model = model as? T.ModelType,
                let indexPath = indexPath as? IndexPath
            else { return 0 }
            return closure(style, cell, model, indexPath)
        }
        tableDataSource?.tableViewEventReactions.append(reaction)
    }
    
    /// Registers `closure` to be executed in `UITableViewDelegate.tableView(_:canEditCellForRowAt:)` method, when it's called for cell which model is of `itemType`.
    open func canEditCell<T>(withItem itemType: T.Type, _ closure: @escaping (T, IndexPath) -> Bool) {
        tableDataSource?.appendReaction(for: T.self, signature: EventMethodSignature.canEditRowAtIndexPath, closure: closure)
    }
    
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:canMoveRowAt:)` method is called for `cellClass`.
    open func canMove<T:ModelTransfer>(_ cellClass: T.Type, _ closure: @escaping (T, T.ModelType, IndexPath) -> Bool) where T: UITableViewCell {
        tableDataSource?.appendReaction(for: T.self, signature: EventMethodSignature.canMoveRowAtIndexPath, closure: closure)
    }
    
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:moveRowAt:to:)` method is called for `cellClass`.
    /// - note: 'MemoryStorage', you already have built-in behaviour, that moves items in the datasource. Use this method only if you want to customize how models are actually moved.
    /// - warning: Do not use `MemoryStorage` methods in closure for this method, because changes only need to be made to the data model, as UI change has already happened and was animated when this method is called.
    /// - SeeAlso: 'tableView:moveRowAt:to:' method
    open func move<T:ModelTransfer>(_ cellClass: T.Type, _ closure: @escaping (T, T.ModelType, _ sourceIndexPath: IndexPath, _ destinationIndexPath: IndexPath) -> Void) where T: UITableViewCell {
        let reaction = FourArgumentsEventReaction(signature: TableViewMoveRowAtIndexPathToIndexPathSignature, viewType: .cell, viewClass: T.self)
        reaction.reaction4Arguments = { cell, model, sourceIndexPath, destinationIndexPath in
            guard let cell = cell as? T, let model = model as? T.ModelType,
                let sourceIndexPath = sourceIndexPath as? IndexPath,
                let destinationIndexPath = destinationIndexPath as? IndexPath else { return 0 }
            return closure(cell, model, sourceIndexPath, destinationIndexPath)
        }
        tableDataSource?.tableViewEventReactions.append(reaction)
    }
    
    /// Registers `closure` to be executed to determine header height in `UITableViewDelegate.tableView(_:heightForHeaderInSection:)` method, when it's called for header which model is of `itemType`.
    open func heightForHeader<T>(withItem type: T.Type, _ closure: @escaping (T, Int) -> CGFloat) {
        tableDelegate?.appendReaction(forSupplementaryKind: DTTableViewElementSectionHeader, modelClass: T.self, signature: EventMethodSignature.heightForHeaderInSection, closure: closure)
    }
    
    /// Registers `closure` to be executed to determine estimated header height in `UITableViewDelegate.tableView(_:estimatedHeightForHeaderInSection:)` method, when it's called for header which model is of `itemType`.
    open func estimatedHeightForHeader<T>(withItem type: T.Type, _ closure: @escaping (T, Int) -> CGFloat) {
        tableDelegate?.appendReaction(forSupplementaryKind: DTTableViewElementSectionHeader, modelClass: T.self, signature: EventMethodSignature.estimatedHeightForHeaderInSection, closure: closure)
    }
    
    /// Registers `closure` to be executed to determine footer height in `UITableViewDelegate.tableView(_:heightForFooterInSection:)` method, when it's called for footer which model is of `itemType`.
    open func heightForFooter<T>(withItem type: T.Type, _ closure: @escaping (T, Int) -> CGFloat) {
        tableDelegate?.appendReaction(forSupplementaryKind: DTTableViewElementSectionFooter, modelClass: T.self, signature: EventMethodSignature.heightForFooterInSection, closure: closure)
    }
    
    /// Registers `closure` to be executed to determine estimated footer height in `UITableViewDelegate.tableView(_:estimatedHeightForFooterInSection:)` method, when it's called for footer which model is of `itemType`.
    open func estimatedHeightForFooter<T>(withItem type: T.Type, _ closure: @escaping (T, Int) -> CGFloat) {
        tableDelegate?.appendReaction(forSupplementaryKind: DTTableViewElementSectionFooter, modelClass: T.self, signature: EventMethodSignature.estimatedHeightForFooterInSection, closure: closure)
    }
    
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:willDisplayHeaderView:forSection:)` method is called for `headerClass`.
    open func willDisplayHeaderView<T:ModelTransfer>(_ headerClass: T.Type, _ closure: @escaping (T, T.ModelType, Int) -> Void) where T: UIView
    {
        tableDelegate?.appendReaction(forSupplementaryKind: DTTableViewElementSectionHeader, supplementaryClass: T.self, signature: EventMethodSignature.willDisplayHeaderForSection, closure: closure)
    }
    
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:willDisplayFooterView:forSection:)` method is called for `footerClass`.
    open func willDisplayFooterView<T:ModelTransfer>(_ footerClass: T.Type, _ closure: @escaping (T, T.ModelType, Int) -> Void) where T: UIView
    {
        tableDelegate?.appendReaction(forSupplementaryKind: DTTableViewElementSectionFooter, supplementaryClass: T.self, signature: EventMethodSignature.willDisplayFooterForSection, closure: closure)
    }
    
    #if os(iOS)
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:willBeginEditingRowAt:)` method is called for `cellClass`.
    open func willBeginEditing<T:ModelTransfer>(_ cellClass:T.Type, _ closure: @escaping (T, T.ModelType, IndexPath) -> Void) where T: UITableViewCell
    {
        tableDelegate?.appendReaction(for: T.self, signature: EventMethodSignature.willBeginEditingRowAtIndexPath, closure: closure)
    }
    #endif
    
    #if os(iOS)
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:didEndEditingRowAt:)` method is called for `cellClass`.
    open func didEndEditing<T:ModelTransfer>(_ cellClass:T.Type, _ closure: @escaping (T, T.ModelType, IndexPath) -> Void) where T: UITableViewCell
    {
        tableDelegate?.appendReaction(for: T.self, signature: EventMethodSignature.didEndEditingRowAtIndexPath, closure: closure)
    }
    #endif
    
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:editingStyleForRowAt:)` method is called for `cellClass`.
    open func editingStyle<T:ModelTransfer>(for cellClass:T.Type, _ closure: @escaping (T, T.ModelType, IndexPath) -> UITableViewCellEditingStyle) where T: UITableViewCell
    {
        tableDelegate?.appendReaction(for: T.self, signature: EventMethodSignature.editingStyleForRowAtIndexPath, closure: closure)
    }
    
    #if os(iOS)
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:titleForDeleteConfirmationButtonForRowAt:)` method is called for `cellClass`.
    open func titleForDeleteConfirmationButton<T:ModelTransfer>(in cellClass:T.Type, _ closure: @escaping (T, T.ModelType, IndexPath) -> String?) where T: UITableViewCell
    {
        tableDelegate?.appendReaction(for: T.self, signature: EventMethodSignature.titleForDeleteButtonForRowAtIndexPath, closure: closure)
    }
    #endif
    
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:shouldIndentWhileEditingRowAt:)` method is called for `cellClass`.
    open func shouldIndentWhileEditing<T:ModelTransfer>(_ cellClass:T.Type, _ closure: @escaping (T, T.ModelType, IndexPath) -> Bool) where T: UITableViewCell
    {
        tableDelegate?.appendReaction(for: T.self, signature: EventMethodSignature.shouldIndentWhileEditingRowAtIndexPath, closure: closure)
    }
    
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:didEndDisplayingCell:forRowAt:)` method is called for `cellClass`.
    open func didEndDisplaying<T:ModelTransfer>(_ cellClass:T.Type, _ closure: @escaping (T, T.ModelType, IndexPath) -> Void) where T: UITableViewCell {
        tableDelegate?.appendReaction(for: T.self, signature: EventMethodSignature.didEndDisplayingCellForRowAtIndexPath, closure: closure)
    }
    
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:didEndDisplayingHeaderView:forSection:)` method is called for `headerClass`.
    open func didEndDisplayingHeaderView<T:ModelTransfer>(_ headerClass: T.Type, _ closure: @escaping (T, T.ModelType, Int) -> Void) where T: UIView
    {
        tableDelegate?.appendReaction(forSupplementaryKind: DTTableViewElementSectionHeader, supplementaryClass: T.self, signature: EventMethodSignature.didEndDisplayingHeaderViewForSection, closure: closure)
    }
    
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:didEndDisplayingFooterView:forSection:)` method is called for `footerClass`.
    open func didEndDisplayingFooterView<T:ModelTransfer>(_ footerClass: T.Type, _ closure: @escaping (T, T.ModelType, Int) -> Void) where T: UIView
    {
        tableDelegate?.appendReaction(forSupplementaryKind: DTTableViewElementSectionFooter, supplementaryClass: T.self, signature: EventMethodSignature.didEndDisplayingFooterViewForSection, closure: closure)
    }
    
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:shouldShowMenuForRowAt:)` method is called for `cellClass`.
    open func shouldShowMenu<T:ModelTransfer>(for cellClass:T.Type, _ closure: @escaping (T, T.ModelType, IndexPath) -> Bool) where T: UITableViewCell
    {
        tableDelegate?.appendReaction(for: T.self, signature: EventMethodSignature.shouldShowMenuForRowAtIndexPath, closure: closure)
    }
    
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:canPerformAction:forRowAt:withSender:)` method is called for `cellClass`.
    open func canPerformAction<T:ModelTransfer>(for cellClass: T.Type, _ closure: @escaping (Selector, Any?, T, T.ModelType, IndexPath) -> Bool) where T: UITableViewCell {
        let reaction = FiveArgumentsEventReaction(signature: EventMethodSignature.canPerformActionForRowAtIndexPath.rawValue,
                                                  viewType: .cell,
                                                  viewClass: T.self)
        reaction.reaction5Arguments = { selector, sender, cell, model, indexPath -> Any in
            guard let selector = selector as? Selector,
                let cell = cell as? T,
                let model = model as? T.ModelType,
                let indexPath = indexPath as? IndexPath
                else { return false }
            return closure(selector, sender, cell, model, indexPath)
        }
        tableDelegate?.tableViewEventReactions.append(reaction)
    }
    
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:performAction:forRowAt:withSender:)` method is called for `cellClass`.
    open func performAction<T:ModelTransfer>(for cellClass: T.Type, _ closure: @escaping (Selector, Any?, T, T.ModelType, IndexPath) -> Void) where T: UITableViewCell {
        let reaction = FiveArgumentsEventReaction(signature: EventMethodSignature.performActionForRowAtIndexPath.rawValue,
                                                  viewType: .cell,
                                                  viewClass: T.self)
        reaction.reaction5Arguments = { selector, sender, cell, model, indexPath  in
            guard let selector = selector as? Selector,
                let cell = cell as? T,
                let model = model as? T.ModelType,
                let indexPath = indexPath as? IndexPath
                else { return false }
            return closure(selector, sender, cell, model, indexPath)
        }
        tableDelegate?.tableViewEventReactions.append(reaction)
    }
    
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:shouldHighlightRowAt:)` method is called for `cellClass`.
    open func shouldHighlight<T:ModelTransfer>(_ cellClass:T.Type, _ closure: @escaping (T, T.ModelType, IndexPath) -> Bool) where T: UITableViewCell
    {
        tableDelegate?.appendReaction(for: T.self, signature: EventMethodSignature.shouldHighlightRowAtIndexPath, closure: closure)
    }
    
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:didHighlightRowAt:)` method is called for `cellClass`.
    open func didHighlight<T:ModelTransfer>(_ cellClass:T.Type, _ closure: @escaping (T, T.ModelType, IndexPath) -> Void) where T: UITableViewCell
    {
        tableDelegate?.appendReaction(for: T.self, signature: EventMethodSignature.didHighlightRowAtIndexPath, closure: closure)
    }
    
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:didUnhighlightRowAt:)` method is called for `cellClass`.
    open func didUnhighlight<T:ModelTransfer>(_ cellClass:T.Type, _ closure: @escaping (T, T.ModelType, IndexPath) -> Void) where T: UITableViewCell
    {
        tableDelegate?.appendReaction(for: T.self, signature: EventMethodSignature.didUnhighlightRowAtIndexPath, closure: closure)
    }
    
    @available(iOS 9.0, tvOS 9.0, *)
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:canFocusRowAt:)` method is called for `cellClass`.
    open func canFocus<T:ModelTransfer>(_ cellClass:T.Type, _ closure: @escaping (T, T.ModelType, IndexPath) -> Bool) where T: UITableViewCell
    {
        tableDelegate?.appendReaction(for: T.self, signature: EventMethodSignature.canFocusRowAtIndexPath, closure: closure)
    }
    
    #if os(iOS)
    /// Registers `closure` to be executed, when `UITableViewDataSource.sectionIndexTitles(for:_) ` method is called.
    open func sectionIndexTitles(_ closure: @escaping () -> [String]?) {
        let reaction = EventReaction(signature: EventMethodSignature.sectionIndexTitlesForTableView.rawValue,
                                     viewType: .cell,
                                     modelType: Any.self)
        reaction.reaction = { _,_,_ in return closure() as Any }
        tableDataSource?.tableViewEventReactions.append(reaction)
    }
    
    /// Registers `closure` to be executed, when `UITableViewDataSource.tableView(_:sectionForSectionIndexTitle:at:)` method is called.
    open func sectionForSectionIndexTitle(_ closure: @escaping (String, Int) -> Int) {
        let reaction = EventReaction(signature: EventMethodSignature.sectionForSectionIndexTitleAtIndex.rawValue,
                                     viewType: .cell,
                                     modelType: Any.self)
        reaction.reaction = { title, index, _ in return closure(title as? String ?? "",index as? Int ?? 0) }
        tableDataSource?.tableViewEventReactions.append(reaction)
    }
    #endif
}
