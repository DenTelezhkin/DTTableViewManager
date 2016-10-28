
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
public protocol DTTableViewManageable : class, NSObjectProtocol
{
    /// Table view, that will be managed by DTTableViewManager
    var tableView : UITableView! { get }
}

/// This protocol is similar to `DTTableViewManageable`, but allows using optional `UITableView` property.
public protocol DTTableViewOptionalManageable : class, NSObjectProtocol {
    var tableView : UITableView? { get }
}

/// This key is used to store `DTTableViewManager` instance on `DTTableViewManageable` class using object association.
private var DTTableViewManagerAssociatedKey = "DTTableViewManager Associated Key"

/// Default implementation for `DTTableViewManageable` protocol, that will inject `manager` property to any object, that declares itself `DTTableViewManageable`.
extension DTTableViewManageable
{
    /// Lazily instantiated `DTTableViewManager` instance. When your table view is loaded, call startManagingWithDelegate: method and `DTTableViewManager` will take over UITableView datasource and delegate. Any method, that is not implemented by `DTTableViewManager`, will be forwarded to delegate.
    /// - SeeAlso: `startManagingWithDelegate:`
    public var manager : DTTableViewManager
    {
        get {
            var object = objc_getAssociatedObject(self, &DTTableViewManagerAssociatedKey)
            if object == nil {
                object = DTTableViewManager()
                objc_setAssociatedObject(self, &DTTableViewManagerAssociatedKey, object, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
            return object as! DTTableViewManager
        }
        set {
            objc_setAssociatedObject(self, &DTTableViewManagerAssociatedKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

extension DTTableViewOptionalManageable {
    /// Lazily instantiated `DTTableViewManager` instance. When your table view is loaded, call startManagingWithDelegate: method and `DTTableViewManager` will take over UITableView datasource and delegate. Any method, that is not implemented by `DTTableViewManager`, will be forwarded to delegate.
    /// - SeeAlso: `startManagingWithDelegate:`
    public var manager : DTTableViewManager
        {
        get {
            var object = objc_getAssociatedObject(self, &DTTableViewManagerAssociatedKey)
            if object == nil {
                object = DTTableViewManager()
                objc_setAssociatedObject(self, &DTTableViewManagerAssociatedKey, object, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
            return object as! DTTableViewManager
        }
        set {
            objc_setAssociatedObject(self, &DTTableViewManagerAssociatedKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

/// `DTTableViewManager` manages many of `UITableView` datasource and delegate methods and provides API for managing your data models in the table. Any method, that is not implemented by `DTTableViewManager`, will be forwarded to delegate.
/// - SeeAlso: `startManagingWithDelegate:`
open class DTTableViewManager : NSObject {
    
    /// Internal weak link to `UITableView`
    final fileprivate var tableView : UITableView?
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
    
    /// Array of reactions for `DTTableViewManager`
    /// - SeeAlso: `EventReaction`.
    fileprivate final var tableViewEventReactions = ContiguousArray<EventReaction>()  {
        didSet {
            // Resetting delegate is needed, because UITableView caches results of `respondsToSelector` call, and never calls it again until `setDelegate` method is called.
            // We force UITableView to flush that cache and query us again, because with new event we might have new delegate or datasource method to respond to.
            tableView?.delegate = nil
            tableView?.delegate = self
            tableView?.dataSource = nil
            tableView?.dataSource = self
        }
    }
    
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
        tableView.delegate = self
        tableView.dataSource = self
        if let mappingDelegate = delegate as? ViewModelMappingCustomizing {
            viewFactory.mappingCustomizableDelegate = mappingDelegate
        }
        tableViewUpdater = TableViewUpdater(tableView: tableView)
        storage.delegate = tableViewUpdater
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
    
    /// Returns header model for section at `index`, or nil if it is not found.
    ///
    /// If `TableViewConfiguration` `displayHeaderOnEmptySection` is false, this method also returns nil.
    final fileprivate func headerModel(forSection index: Int) -> Any?
    {
        guard self.storage.sections.count > index else { return nil }
        
        if self.storage.sections[index].numberOfItems == 0 && !configuration.displayHeaderOnEmptySection
        {
            return nil
        }
        return (self.storage as? HeaderFooterStorage)?.headerModel(forSection: index)
    }
    
    /// Returns footer model for section at `index`, or nil if it is not found.
    ///
    /// If `TableViewConfiguration` `displayFooterOnEmptySection` is false, this method also returns nil.
    final fileprivate func footerModelForSectionIndex(_ index: Int) -> Any?
    {
        guard self.storage.sections.count > index else { return nil }
        
        if self.storage.sections[index].numberOfItems == 0 && !configuration.displayFooterOnEmptySection
        {
            return nil
        }
        return (self.storage as? HeaderFooterStorage)?.footerModel(forSection: index)
    }
}

// MARK: - Runtime forwarding
extension DTTableViewManager
{
    /// Forwards `aSelector`, that is not implemented by `DTTableViewManager` to delegate, if it implements it.
    ///
    /// - Returns: `DTTableViewManager` delegate
    open override func forwardingTarget(for aSelector: Selector) -> Any? {
        return delegate
    }
    
    /// Returns true, if `DTTableViewManageable` implements `aSelector`, or `DTTableViewManager` has an event, associated with this selector.
    /// 
    /// - SeeAlso: `EventMethodSignature`
    open override func responds(to aSelector: Selector) -> Bool {
        if self.delegate?.responds(to: aSelector) ?? false {
            return true
        }
        if super.responds(to: aSelector) {
            if let eventSelector = EventMethodSignature(rawValue: String(describing: aSelector)) {
                return tableViewEventReactions.contains(where: { $0.methodSignature == eventSelector.rawValue })
            }
            return true
        }
        return false
    }
}

// MARK: - View registration
extension DTTableViewManager
{
    /// Registers mapping from model class to `cellClass`. 
    ///
    /// Method will automatically check for nib with the same name as `cellClass`. If it exists - nib will be registered instead of class.
    open func register<T:ModelTransfer>(_ cellClass:T.Type) where T: UITableViewCell
    {
        self.viewFactory.registerCellClass(cellClass)
    }

    /// Registers nib with `nibName` mapping from model class to `cellClass`.
    open func registerNibNamed<T:ModelTransfer>(_ nibName: String, for cellClass: T.Type) where T: UITableViewCell
    {
        self.viewFactory.registerNibNamed(nibName, forCellClass: cellClass)
    }
    
    /// Registers mapping from model class to header view of `headerClass` type.
    ///
    /// Method will automatically check for nib with the same name as `headerClass`. If it exists - nib will be registered instead of class.
    /// This method also sets TableViewConfiguration.sectionHeaderStyle property to .view.
    /// - Note: Views does not need to be `UITableViewHeaderFooterView`, if it's a `UIView` subclass, it also will be created from XIB.
    /// - SeeAlso: `UIView+XibLoading`.
    open func registerHeader<T:ModelTransfer>(_ headerClass : T.Type) where T: UIView
    {
        configuration.sectionHeaderStyle = .view
        self.viewFactory.registerHeaderClass(headerClass)
    }
    
    /// Registers mapping from model class to header view of `headerClass` type.
    ///
    /// This method is intended to be used for headers created from code - without UI made in XIB.
    /// This method also sets TableViewConfiguration.sectionHeaderStyle property to .view.
    open func registerNiblessHeader<T:ModelTransfer>(_ headerClass : T.Type) where T: UITableViewHeaderFooterView
    {
        configuration.sectionHeaderStyle = .view
        self.viewFactory.registerNiblessHeaderClass(headerClass)
    }
    
    /// Registers mapping from model class to footer view of `footerClass` type.
    ///
    /// This method is intended to be used for footers created from code - without UI made in XIB.
    /// This method also sets TableViewConfiguration.sectionFooterStyle property to .view.
    open func registerNiblessFooter<T:ModelTransfer>(_ footerClass : T.Type) where T: UITableViewHeaderFooterView
    {
        configuration.sectionFooterStyle = .view
        self.viewFactory.registerNiblessFooterClass(footerClass)
    }
    
    /// Registers mapping from model class to footerView view of `footerClass` type.
    ///
    /// Method will automatically check for nib with the same name as `footerClass`. If it exists - nib will be registered instead of class.
    /// This method also sets TableViewConfiguration.sectionFooterStyle property to .view.
    /// - Note: Views does not need to be `UITableViewHeaderFooterView`, if it's a `UIView` subclass, it also will be created from XIB.
    /// - SeeAlso: `UIView+XibLoading`.
    open func registerFooter<T:ModelTransfer>(_ footerClass: T.Type) where T:UIView
    {
        configuration.sectionFooterStyle = .view
        viewFactory.registerFooterClass(footerClass)
    }
    
    /// Registers mapping from model class to headerView view of `headerClass` type with `nibName`.
    ///
    /// This method also sets TableViewConfiguration.sectionHeaderStyle property to .view.
    /// - Note: Views does not need to be `UITableViewHeaderFooterView`, if it's a `UIView` subclass, it also will be created from XIB.
    /// - SeeAlso: `UIView+XibLoading`.
    open func registerNibNamed<T:ModelTransfer>(_ nibName: String, forHeader headerClass: T.Type) where T:UIView
    {
        configuration.sectionHeaderStyle = .view
        viewFactory.registerNibNamed(nibName, forHeaderClass: headerClass)
    }
    
    /// Registers mapping from model class to headerView view of `footerClass` type with `nibName`.
    ///
    /// This method also sets TableViewConfiguration.sectionFooterStyle property to .view.
    /// - Note: Views does not need to be `UITableViewHeaderFooterView`, if it's a `UIView` subclass, it also will be created from XIB.
    /// - SeeAlso: `UIView+XibLoading`.
    open func registerNibNamed<T:ModelTransfer>(_ nibName: String, forFooter footerClass: T.Type) where T:UIView
    {
        configuration.sectionFooterStyle = .view
        viewFactory.registerNibNamed(nibName, forFooterClass: footerClass)
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

// MARK: - Table view reactions
extension DTTableViewManager
{
    final fileprivate func appendReaction<T,U>(for cellClass: T.Type, signature: EventMethodSignature, closure: @escaping (T,T.ModelType, IndexPath) -> U) where T: ModelTransfer, T:UITableViewCell
    {
        let reaction = EventReaction(signature: signature.rawValue)
        reaction.makeCellReaction(closure)
        tableViewEventReactions.append(reaction)
    }
    
    final fileprivate func appendReaction<T,U>(for modelClass: T.Type, signature: EventMethodSignature, closure: @escaping (T, IndexPath) -> U)
    {
        let reaction = EventReaction(signature: signature.rawValue)
        reaction.makeCellReaction(closure)
        tableViewEventReactions.append(reaction)
    }
    
    final fileprivate func appendReaction<T,U>(forSupplementaryKind kind: String, supplementaryClass: T.Type, signature: EventMethodSignature, closure: @escaping (T, T.ModelType, Int) -> U) where T: ModelTransfer, T: UIView {
        let reaction = EventReaction(signature: signature.rawValue)
        let indexPathBlock : (T, T.ModelType, IndexPath) -> U = { cell, model, indexPath in
            return closure(cell, model, indexPath.section)
        }
        reaction.makeSupplementaryReaction(forKind: kind, block: indexPathBlock)
        tableViewEventReactions.append(reaction)
    }
    
    final fileprivate func appendReaction<T,U>(forSupplementaryKind kind: String, modelClass: T.Type, signature: EventMethodSignature, closure: @escaping (T, Int) -> U) {
        let reaction = EventReaction(signature: signature.rawValue)
        let indexPathBlock : (T, IndexPath) -> U = { model, indexPath in
            return closure(model, indexPath.section)
        }
        reaction.makeSupplementaryReaction(for: kind, block: indexPathBlock)
        tableViewEventReactions.append(reaction)
    }
    
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:didSelectRowAt:)` method is called for `cellClass`.
    open func didSelect<T:ModelTransfer>(_ cellClass:  T.Type, _ closure: @escaping (T,T.ModelType, IndexPath) -> Void) where T:UITableViewCell
    {
        appendReaction(for: T.self, signature: .didSelectRowAtIndexPath, closure: closure)
    }
    
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:willSelectRowAt:)` method is called for `cellClass`.
    open func willSelect<T:ModelTransfer>(_ cellClass:  T.Type, _ closure: @escaping (T,T.ModelType, IndexPath) -> IndexPath?) where T:UITableViewCell {
        appendReaction(for: T.self, signature: .willSelectRowAtIndexPath, closure: closure)
    }
    
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:willDeselectRowAt:)` method is called for `cellClass`.
    open func willDeselect<T:ModelTransfer>(_ cellClass:  T.Type, _ closure: @escaping (T,T.ModelType, IndexPath) -> IndexPath?) where T:UITableViewCell {
        appendReaction(for: T.self, signature: .willDeselectRowAtIndexPath, closure: closure)
    }
    
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:didDeselectRowAt:)` method is called for `cellClass`.
    open func didDeselect<T:ModelTransfer>(_ cellClass:  T.Type, _ closure: @escaping (T,T.ModelType, IndexPath) -> IndexPath?) where T:UITableViewCell {
        appendReaction(for: T.self, signature: .didDeselectRowAtIndexPath, closure: closure)
    }
    
    /// Registers `closure` to be executed, when `UITableView` requests `cellClass` in `UITableViewDataSource.tableView(_:cellForRowAt:)` method and cell is being configured.
    ///
    /// This closure will be performed *after* cell is created and `update(with:)` method is called.
    open func configure<T:ModelTransfer>(_ cellClass:T.Type, _ closure: @escaping (T, T.ModelType, IndexPath) -> Void) where T: UITableViewCell
    {
        appendReaction(for: T.self, signature: .configureCell, closure: closure)
    }
    
    /// Registers `closure` to be executed, when `UITableView` requests `headerClass` in `UITableViewDelegate.tableView(_:viewForHeaderInSection:)` method and header is being configured.
    ///
    /// This closure will be performed *after* header is created and `update(with:)` method is called.
    open func configureHeader<T:ModelTransfer>(_ headerClass: T.Type, _ closure: @escaping (T, T.ModelType, Int) -> Void) where T: UIView
    {
        appendReaction(forSupplementaryKind: DTTableViewElementSectionHeader, supplementaryClass: T.self, signature: EventMethodSignature.configureHeader, closure: closure)
    }
    
    /// Registers `closure` to be executed, when `UITableView` requests `footerClass` in `UITableViewDelegate.tableView(_:viewForFooterInSection:)` method and footer is being configured.
    ///
    /// This closure will be performed *after* footer is created and `update(with:)` method is called.
    open func configureFooter<T:ModelTransfer>(_ footerClass: T.Type, _ closure: @escaping (T, T.ModelType, Int) -> Void) where T: UIView
    {
        appendReaction(forSupplementaryKind: DTTableViewElementSectionFooter, supplementaryClass: T.self, signature: EventMethodSignature.configureFooter, closure: closure)
    }
    
    /// Registers `closure` to be executed to determine cell height in `UITableViewDelegate.tableView(_:heightForRowAt:)` method, when it's called for cell which model is of `itemType`.
    open func heightForCell<T>(withItem itemType: T.Type, _ closure: @escaping (T, IndexPath) -> CGFloat) {
        appendReaction(for: T.self, signature: EventMethodSignature.heightForRowAtIndexPath, closure: closure)
    }
    
    /// Registers `closure` to be executed to determine estimated cell height in `UITableViewDelegate.tableView(_:estimatedHeightForRowAt:)` method, when it's called for cell which model is of `itemType`.
    open func estimatedHeightForCell<T>(withItem itemType: T.Type, _ closure: @escaping (T, IndexPath) -> CGFloat) {
        appendReaction(for: T.self, signature: EventMethodSignature.estimatedHeightForRowAtIndexPath, closure: closure)
    }
    
    /// Registers `closure` to be executed to determine indentation level in `UITableViewDelegate.tableView(_:indentationLevelForRowAt:)` method, when it's called for cell which model is of `itemType`.
    open func indentationLevelForCell<T>(withItem itemType: T.Type, _ closure: @escaping (T, IndexPath) -> CGFloat) {
        appendReaction(for: T.self, signature: EventMethodSignature.indentationLevelForRowAtIndexPath, closure: closure)
    }
    
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:willDisplayCell:forRowAt:)` method is called for `cellClass`.
    open func willDisplay<T:ModelTransfer>(_ cellClass:T.Type, _ closure: @escaping (T, T.ModelType, IndexPath) -> Void) where T: UITableViewCell
    {
        appendReaction(for: T.self, signature: EventMethodSignature.willDisplayCellForRowAtIndexPath, closure: closure)
    }
    
    #if os(iOS)
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:editActionsForRowAt:)` method is called for `cellClass`.
    open func editActions<T:ModelTransfer>(for cellClass: T.Type, _ closure: @escaping (T, T.ModelType, IndexPath) -> [UITableViewRowAction]?) where T: UITableViewCell {
        appendReaction(for: T.self, signature: EventMethodSignature.editActionsForRowAtIndexPath, closure: closure)
    }
    #endif
    
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:accessoryButtonTappedForRowAt:)` method is called for `cellClass`.
    open func accessoryButtonTapped<T:ModelTransfer>(in cellClass: T.Type, _ closure: @escaping (T, T.ModelType, IndexPath) -> Void) where T: UITableViewCell {
        appendReaction(for: T.self, signature: EventMethodSignature.accessoryButtonTappedForRowAtIndexPath, closure: closure)
    }
    
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:commitEditingStyle:forRowAt:)` method is called for `cellClass`.
    open func commitEditingStyle<T:ModelTransfer>(for cellClass: T.Type, _ closure: @escaping (UITableViewCellEditingStyle, T, T.ModelType, IndexPath) -> Void) where T: UITableViewCell {
        let reaction = FourArgumentsEventReaction(signature: EventMethodSignature.commitEditingStyleForRowAtIndexPath.rawValue)
        reaction.modelTypeCheckingBlock = { $0 is T.ModelType }
        reaction.reaction4Arguments = { style, cell, model, indexPath in
            guard let style = style as? UITableViewCellEditingStyle,
                let cell = cell as? T,
                let model = model as? T.ModelType,
                let indexPath = indexPath as? IndexPath
            else { return 0 }
            closure(style, cell, model, indexPath)
            return 0
        }
        tableViewEventReactions.append(reaction)
    }
    
    /// Registers `closure` to be executed in `UITableViewDelegate.tableView(_:canEditCellForRowAt:)` method, when it's called for cell which model is of `itemType`.
    open func canEditCell<T>(withItem itemType: T.Type, _ closure: @escaping (T, IndexPath) -> Bool) {
        appendReaction(for: T.self, signature: EventMethodSignature.canEditRowAtIndexPath, closure: closure)
    }
    
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:canMoveCellForRowAt:)` method is called for `cellClass`.
    open func canMove<T:ModelTransfer>(_ cellClass: T.Type, _ closure: @escaping (T, T.ModelType, IndexPath) -> Bool) where T: UITableViewCell {
        appendReaction(for: T.self, signature: EventMethodSignature.canMoveRowAtIndexPath, closure: closure)
    }
    
    /// Registers `closure` to be executed to determine header height in `UITableViewDelegate.tableView(_:heightForHeaderInSection:)` method, when it's called for header which model is of `itemType`.
    open func heightForHeader<T>(withItem type: T.Type, _ closure: @escaping (T, Int) -> CGFloat) {
        appendReaction(forSupplementaryKind: DTTableViewElementSectionHeader, modelClass: T.self, signature: EventMethodSignature.heightForHeaderInSection, closure: closure)
    }
    
    /// Registers `closure` to be executed to determine estimated header height in `UITableViewDelegate.tableView(_:estimatedHeightForHeaderInSection:)` method, when it's called for header which model is of `itemType`.
    open func estimatedHeightForHeader<T>(withItem type: T.Type, _ closure: @escaping (T, Int) -> CGFloat) {
        appendReaction(forSupplementaryKind: DTTableViewElementSectionHeader, modelClass: T.self, signature: EventMethodSignature.estimatedHeightForHeaderInSection, closure: closure)
    }
    
    /// Registers `closure` to be executed to determine footer height in `UITableViewDelegate.tableView(_:heightForFooterInSection:)` method, when it's called for footer which model is of `itemType`.
    open func heightForFooter<T>(withItem type: T.Type, _ closure: @escaping (T, Int) -> CGFloat) {
        appendReaction(forSupplementaryKind: DTTableViewElementSectionFooter, modelClass: T.self, signature: EventMethodSignature.heightForFooterInSection, closure: closure)
    }
    
    /// Registers `closure` to be executed to determine estimated footer height in `UITableViewDelegate.tableView(_:estimatedHeightForFooterInSection:)` method, when it's called for footer which model is of `itemType`.
    open func estimatedHeightForFooter<T>(withItem type: T.Type, _ closure: @escaping (T, Int) -> CGFloat) {
        appendReaction(forSupplementaryKind: DTTableViewElementSectionFooter, modelClass: T.self, signature: EventMethodSignature.estimatedHeightForFooterInSection, closure: closure)
    }
    
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:willDisplayHeaderView:forSection:)` method is called for `headerClass`.
    open func willDisplayHeaderView<T:ModelTransfer>(_ headerClass: T.Type, _ closure: @escaping (T, T.ModelType, Int) -> Void) where T: UIView
    {
        appendReaction(forSupplementaryKind: DTTableViewElementSectionHeader, supplementaryClass: T.self, signature: EventMethodSignature.willDisplayHeaderForSection, closure: closure)
    }
    
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:willDisplayFooterView:forSection:)` method is called for `footerClass`.
    open func willDisplayFooterView<T:ModelTransfer>(_ footerClass: T.Type, _ closure: @escaping (T, T.ModelType, Int) -> Void) where T: UIView
    {
        appendReaction(forSupplementaryKind: DTTableViewElementSectionFooter, supplementaryClass: T.self, signature: EventMethodSignature.willDisplayFooterForSection, closure: closure)
    }
    
    #if os(iOS)
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:willBeginEditingRowAt:)` method is called for `cellClass`.
    open func willBeginEditing<T:ModelTransfer>(_ cellClass:T.Type, _ closure: @escaping (T, T.ModelType, IndexPath) -> Void) where T: UITableViewCell
    {
        appendReaction(for: T.self, signature: EventMethodSignature.willBeginEditingRowAtIndexPath, closure: closure)
    }
    #endif
    
    #if os(iOS)
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:didEndEditingRowAt:)` method is called for `cellClass`.
    open func didEndEditing<T:ModelTransfer>(_ cellClass:T.Type, _ closure: @escaping (T, T.ModelType, IndexPath) -> Void) where T: UITableViewCell
    {
        appendReaction(for: T.self, signature: EventMethodSignature.didEndEditingRowAtIndexPath, closure: closure)
    }
    #endif
    
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:editingStyleForRowAt:)` method is called for `cellClass`.
    open func editingStyle<T:ModelTransfer>(for cellClass:T.Type, _ closure: @escaping (T, T.ModelType, IndexPath) -> UITableViewCellEditingStyle) where T: UITableViewCell
    {
        appendReaction(for: T.self, signature: EventMethodSignature.editingStyleForRowAtIndexPath, closure: closure)
    }
    
    #if os(iOS)
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:titleForDeleteConfirmationButtonForRowAt:)` method is called for `cellClass`.
    open func titleForDeleteConfirmationButton<T:ModelTransfer>(in cellClass:T.Type, _ closure: @escaping (T, T.ModelType, IndexPath) -> String?) where T: UITableViewCell
    {
        appendReaction(for: T.self, signature: EventMethodSignature.titleForDeleteButtonForRowAtIndexPath, closure: closure)
    }
    #endif
    
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:shouldIndentWhileEditingRowAt:)` method is called for `cellClass`.
    open func shouldIndentWhileEditing<T:ModelTransfer>(_ cellClass:T.Type, _ closure: @escaping (T, T.ModelType, IndexPath) -> Bool) where T: UITableViewCell
    {
        appendReaction(for: T.self, signature: EventMethodSignature.shouldIndentWhileEditingRowAtIndexPath, closure: closure)
    }
    
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:didEndDisplayingCell:forRowAt:)` method is called for `cellClass`.
    open func didEndDisplaying<T:ModelTransfer>(_ cellClass:T.Type, _ closure: @escaping (T, T.ModelType, IndexPath) -> Void) where T: UITableViewCell {
        appendReaction(for: T.self, signature: EventMethodSignature.didEndDisplayingCellForRowAtIndexPath, closure: closure)
    }
    
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:didEndDisplayingHeaderView:forSection:)` method is called for `headerClass`.
    open func didEndDisplayingHeaderView<T:ModelTransfer>(_ headerClass: T.Type, _ closure: @escaping (T, T.ModelType, Int) -> Void) where T: UIView
    {
        appendReaction(forSupplementaryKind: DTTableViewElementSectionHeader, supplementaryClass: T.self, signature: EventMethodSignature.didEndDisplayingHeaderViewForSection, closure: closure)
    }
    
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:didEndDisplayingFooterView:forSection:)` method is called for `footerClass`.
    open func didEndDisplayingFooterView<T:ModelTransfer>(_ footerClass: T.Type, _ closure: @escaping (T, T.ModelType, Int) -> Void) where T: UIView
    {
        appendReaction(forSupplementaryKind: DTTableViewElementSectionFooter, supplementaryClass: T.self, signature: EventMethodSignature.didEndDisplayingFooterViewForSection, closure: closure)
    }
    
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:shouldShowMenuForRowAt:)` method is called for `cellClass`.
    open func shouldShowMenu<T:ModelTransfer>(for cellClass:T.Type, _ closure: @escaping (T, T.ModelType, IndexPath) -> Bool) where T: UITableViewCell
    {
        appendReaction(for: T.self, signature: EventMethodSignature.shouldShowMenuForRowAtIndexPath, closure: closure)
    }
    
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:canPerformAction:forRowAt:withSender:)` method is called for `cellClass`.
    open func canPerformAction<T:ModelTransfer>(for cellClass: T.Type, _ closure: @escaping (Selector, Any?, T, T.ModelType, IndexPath) -> Bool) where T: UITableViewCell {
        let reaction = FiveArgumentsEventReaction(signature: EventMethodSignature.canPerformActionForRowAtIndexPath.rawValue)
        reaction.modelTypeCheckingBlock = { $0 is T.ModelType }
        reaction.reaction5Arguments = { selector, sender, cell, model, indexPath -> Any in
            guard let selector = selector as? Selector,
                let cell = cell as? T,
                let model = model as? T.ModelType,
                let indexPath = indexPath as? IndexPath
                else { return false }
            return closure(selector, sender, cell, model, indexPath)
        }
        tableViewEventReactions.append(reaction)
    }
    
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:performAction:forRowAt:withSender:)` method is called for `cellClass`.
    open func performAction<T:ModelTransfer>(for cellClass: T.Type, _ closure: @escaping (Selector, Any?, T, T.ModelType, IndexPath) -> Void) where T: UITableViewCell {
        let reaction = FiveArgumentsEventReaction(signature: EventMethodSignature.performActionForRowAtIndexPath.rawValue)
        reaction.modelTypeCheckingBlock = { $0 is T.ModelType }
        reaction.reaction5Arguments = { selector, sender, cell, model, indexPath  in
            guard let selector = selector as? Selector,
                let cell = cell as? T,
                let model = model as? T.ModelType,
                let indexPath = indexPath as? IndexPath
                else { return false }
            return closure(selector, sender, cell, model, indexPath)
        }
        tableViewEventReactions.append(reaction)
    }
    
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:shouldHighlightRowAt:)` method is called for `cellClass`.
    open func shouldHighlight<T:ModelTransfer>(_ cellClass:T.Type, _ closure: @escaping (T, T.ModelType, IndexPath) -> Bool) where T: UITableViewCell
    {
        appendReaction(for: T.self, signature: EventMethodSignature.shouldHighlightRowAtIndexPath, closure: closure)
    }
    
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:didHighlightRowAt:)` method is called for `cellClass`.
    open func didHighlight<T:ModelTransfer>(_ cellClass:T.Type, _ closure: @escaping (T, T.ModelType, IndexPath) -> Void) where T: UITableViewCell
    {
        appendReaction(for: T.self, signature: EventMethodSignature.didHighlightRowAtIndexPath, closure: closure)
    }
    
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:didUnhighlightRowAt:)` method is called for `cellClass`.
    open func didUnhighlight<T:ModelTransfer>(_ cellClass:T.Type, _ closure: @escaping (T, T.ModelType, IndexPath) -> Void) where T: UITableViewCell
    {
        appendReaction(for: T.self, signature: EventMethodSignature.didUnhighlightRowAtIndexPath, closure: closure)
    }
    
    @available(iOS 9.0, tvOS 9.0, *)
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:canFocusRowAt:)` method is called for `cellClass`.
    open func canFocus<T:ModelTransfer>(_ cellClass:T.Type, _ closure: @escaping (T, T.ModelType, IndexPath) -> Bool) where T: UITableViewCell
    {
        appendReaction(for: T.self, signature: EventMethodSignature.canFocusRowAtIndexPath, closure: closure)
    }
}

// MARK: - UITableViewDatasource
extension DTTableViewManager: UITableViewDataSource
{
    /// Calls `viewFactoryErrorHandler` with `error`. If it's nil, prints error into console and asserts.
    @nonobjc func handleTableViewFactoryError(_ error: DTTableViewFactoryError) {
        if let handler = viewFactoryErrorHandler {
            handler(error)
        } else {
            print((error as NSError).description)
            assertionFailure(error.description)
        }
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.storage.sections[section].numberOfItems
    }
    
    open func numberOfSections(in tableView: UITableView) -> Int {
        return self.storage.sections.count
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let model = self.storage.item(at: indexPath) else {
            return UITableViewCell()
        }
        
        let cell : UITableViewCell
        do {
            cell = try self.viewFactory.cellForModel(model, atIndexPath: indexPath)
        } catch let error as DTTableViewFactoryError {
            handleTableViewFactoryError(error)
            cell = UITableViewCell()
        } catch {
            cell = UITableViewCell()
        }
        
        _ = tableViewEventReactions.performReaction(of: .cell, signature: EventMethodSignature.configureCell.rawValue, view: cell, model: model, location: indexPath)
        return cell
    }
    
    open func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if configuration.sectionHeaderStyle == .view { return nil }
        
        return self.headerModel(forSection: section) as? String
    }
    
    open func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if configuration.sectionFooterStyle == .view { return nil }
        
        return self.footerModelForSectionIndex(section) as? String
    }
    
    /// `DTTableViewManager` automatically moves data models from source indexPath to destination indexPath, there's no need to implement this method on UITableViewDataSource
    open func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        if (delegate as? UITableViewDataSource)?.tableView?(tableView, moveRowAt: sourceIndexPath, to: destinationIndexPath) != nil {
            return
        }
        if let storage = self.storage as? MemoryStorage
        {
            if let from = storage.sections[sourceIndexPath.section] as? SectionModel,
               let to = storage.sections[destinationIndexPath.section] as? SectionModel
            {
                let item = from.items[sourceIndexPath.row]
                from.items.remove(at: sourceIndexPath.row)
                to.items.insert(item, at: destinationIndexPath.row)
            }
        }
    }
    
    open func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        defer { (delegate as? UITableViewDataSource)?.tableView?(tableView, commit: editingStyle, forRowAt: indexPath) }
        guard let item = storage.item(at: indexPath), let model = RuntimeHelper.recursivelyUnwrapAnyValue(item),
            let cell = tableView.cellForRow(at: indexPath)
            else { return }
        if let reaction = tableViewEventReactions.reaction(of: .cell, signature: EventMethodSignature.commitEditingStyleForRowAtIndexPath.rawValue, forModel: model) as? FourArgumentsEventReaction {
            _ = reaction.performWithArguments((editingStyle,cell,model,indexPath))
        }
    }
    
    open func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if let canEdit = performCellReaction(.canEditRowAtIndexPath, location: indexPath, provideCell: false) as? Bool {
            return canEdit
        }
        return (delegate as? UITableViewDataSource)?.tableView?(tableView, canEditRowAt: indexPath) ?? false
    }
    
    open func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        if let canMove = performCellReaction(.canMoveRowAtIndexPath, location: indexPath, provideCell: true) as? Bool {
            return canMove
        }
        return (delegate as? UITableViewDataSource)?.tableView?(tableView, canMoveRowAt: indexPath) ?? false
    }
}

// MARK: - UITableViewDelegate
extension DTTableViewManager: UITableViewDelegate
{
    open func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
    {
        defer { (delegate as? UITableViewDelegate)?.tableView?(tableView, willDisplay: cell, forRowAt: indexPath) }
        guard let model = storage.item(at: indexPath) else { return }
        _ = tableViewEventReactions.performReaction(of: .cell, signature: EventMethodSignature.willDisplayCellForRowAtIndexPath.rawValue, view: cell, model: model, location: indexPath)
    }
    
    open func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        defer { (delegate as? UITableViewDelegate)?.tableView?(tableView, willDisplayHeaderView: view, forSection: section) }
        guard let model = (storage as? HeaderFooterStorage)?.headerModel(forSection: section) else { return }
        _ = tableViewEventReactions.performReaction(of: .supplementaryView(kind: DTTableViewElementSectionHeader), signature: EventMethodSignature.willDisplayHeaderForSection.rawValue, view: view, model: model, location: IndexPath(item: 0, section: section))
    }
    
    open func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        defer { (delegate as? UITableViewDelegate)?.tableView?(tableView, willDisplayFooterView: view, forSection: section) }
        guard let model = (storage as? HeaderFooterStorage)?.footerModel(forSection: section) else { return }
        _ = tableViewEventReactions.performReaction(of: .supplementaryView(kind: DTTableViewElementSectionFooter), signature: EventMethodSignature.willDisplayFooterForSection.rawValue, view: view, model: model, location: IndexPath(item: 0, section: section))
    }
    
    open func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if configuration.sectionHeaderStyle == .title { return nil }
        
        if let model = self.headerModel(forSection:section) {
            let view : UIView?
            do {
                view = try self.viewFactory.headerViewForModel(model, atIndexPath: IndexPath(index: section))
            } catch let error as DTTableViewFactoryError {
                handleTableViewFactoryError(error)
                view = nil
            } catch {
                view = nil
            }
            
            if let createdView = view
            {
                _ = tableViewEventReactions.performReaction(of: .supplementaryView(kind: DTTableViewElementSectionHeader),
                                                            signature: EventMethodSignature.configureHeader.rawValue,
                                                            view: createdView, model: model, location: IndexPath(item: 0, section: section))
            }
            return view
        }
        return nil
    }
    
    open func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if configuration.sectionFooterStyle == .title { return nil }
        
        if let model = self.footerModelForSectionIndex(section) {
            let view : UIView?
            do {
                view = try self.viewFactory.footerViewForModel(model, atIndexPath: IndexPath(index: section))
            } catch let error as DTTableViewFactoryError {
                handleTableViewFactoryError(error)
                view = nil
            } catch {
                view = nil
            }
            
            if let createdView = view
            {
                _ = tableViewEventReactions.performReaction(of: .supplementaryView(kind: DTTableViewElementSectionFooter),
                                                         signature: EventMethodSignature.configureFooter.rawValue,
                                                         view: createdView, model: model, location: IndexPath(item: 0, section: section))
            }
            return view
        }
        return nil
    }
    
    open func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if let height = performHeaderReaction(.heightForHeaderInSection, location: section, provideView: false) as? CGFloat {
            return height
        }
        if let height = (delegate as? UITableViewDelegate)?.tableView?(tableView, heightForHeaderInSection: section) {
            return height
        }
        if configuration.sectionHeaderStyle == .title {
            if let _ = self.headerModel(forSection:section)
            {
                return UITableViewAutomaticDimension
            }
            return CGFloat.leastNormalMagnitude
        }
        
        if let _ = self.headerModel(forSection:section)
        {
            return self.tableView?.sectionHeaderHeight ?? CGFloat.leastNormalMagnitude
        }
        return CGFloat.leastNormalMagnitude
    }
    
    open func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        if let height = performHeaderReaction(.estimatedHeightForHeaderInSection, location: section, provideView: false) as? CGFloat {
            return height
        }
        return (delegate as? UITableViewDelegate)?.tableView?(tableView, estimatedHeightForHeaderInSection: section) ?? tableView.estimatedSectionHeaderHeight
    }
    
    open func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if let height = performFooterReaction(.heightForFooterInSection, location: section, provideView: false) as? CGFloat {
            return height
        }
        if let height = (delegate as? UITableViewDelegate)?.tableView?(tableView, heightForFooterInSection: section) {
            return height
        }
        if configuration.sectionFooterStyle == .title {
            if let _ = self.footerModelForSectionIndex(section) {
                return UITableViewAutomaticDimension
            }
            return CGFloat.leastNormalMagnitude
        }
        
        if let _ = self.footerModelForSectionIndex(section) {
            return self.tableView?.sectionFooterHeight ?? CGFloat.leastNormalMagnitude
        }
        return CGFloat.leastNormalMagnitude
    }
    
    open func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        if let height = performFooterReaction(.estimatedHeightForFooterInSection, location: section, provideView: false) as? CGFloat {
            return height
        }
        return (delegate as? UITableViewDelegate)?.tableView?(tableView, estimatedHeightForFooterInSection: section) ?? tableView.estimatedSectionFooterHeight
    }
    
    open func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if let result = performCellReaction(.willSelectRowAtIndexPath, location: indexPath, provideCell: true) as? IndexPath {
            return result
        }
        return (delegate as? UITableViewDelegate)?.tableView?(tableView, willSelectRowAt: indexPath)
    }
    
    open func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath? {
        if let result = performCellReaction(.willDeselectRowAtIndexPath, location: indexPath, provideCell: true) as? IndexPath {
            return result
        }
        return (delegate as? UITableViewDelegate)?.tableView?(tableView, willDeselectRowAt: indexPath)
    }
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        _ = performCellReaction(.didSelectRowAtIndexPath, location: indexPath, provideCell: true)
        (self.delegate as? UITableViewDelegate)?.tableView?(tableView, didSelectRowAt: indexPath)
    }
    
    open func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        _ = performCellReaction(.didDeselectRowAtIndexPath, location: indexPath, provideCell: true)
        (self.delegate as? UITableViewDelegate)?.tableView?(tableView, didDeselectRowAt: indexPath)
    }
    
    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let height = performCellReaction(.heightForRowAtIndexPath, location: indexPath, provideCell: false) as? CGFloat {
            return height
        }
        return (delegate as? UITableViewDelegate)?.tableView?(tableView, heightForRowAt: indexPath) ?? tableView.rowHeight
    }
    
    open func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if let height = performCellReaction(.estimatedHeightForRowAtIndexPath, location: indexPath, provideCell: false) as? CGFloat {
            return height
        }
        return (delegate as? UITableViewDelegate)?.tableView?(tableView, estimatedHeightForRowAt: indexPath) ?? tableView.estimatedRowHeight
    }
    
    open func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
        if let level = performCellReaction(.indentationLevelForRowAtIndexPath, location: indexPath, provideCell: false) as? Int {
            return level
        }
        return (delegate as? UITableViewDelegate)?.tableView?(tableView, indentationLevelForRowAt: indexPath) ?? 0
    }
    
    open func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        _ = performCellReaction(.accessoryButtonTappedForRowAtIndexPath, location: indexPath, provideCell: true)
        (delegate as? UITableViewDelegate)?.tableView?(tableView, accessoryButtonTappedForRowWith: indexPath)
    }
    
    #if os(iOS)
    open func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if let actions = performCellReaction(.editActionsForRowAtIndexPath, location: indexPath, provideCell: true) as? [UITableViewRowAction] {
            return actions
        }
        return (delegate as? UITableViewDelegate)?.tableView?(tableView, editActionsForRowAt: indexPath)
    }
    #endif
    
    #if os(iOS)
    open func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        _ = performCellReaction(.willBeginEditingRowAtIndexPath, location: indexPath, provideCell: true)
        (delegate as? UITableViewDelegate)?.tableView?(tableView, willBeginEditingRowAt: indexPath)
    }
    #endif
    
    #if os(iOS)
    open func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        defer { (delegate as? UITableViewDelegate)?.tableView?(tableView, didEndEditingRowAt: indexPath) }
        guard let indexPath = indexPath else { return }
        _ = performCellReaction(.didEndEditingRowAtIndexPath, location: indexPath, provideCell: true)
    }
    #endif
    
    open func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        if let editingStyle = performCellReaction(.editingStyleForRowAtIndexPath, location: indexPath, provideCell: true) as? UITableViewCellEditingStyle {
            return editingStyle
        }
        return (delegate as? UITableViewDelegate)?.tableView?(tableView, editingStyleForRowAt: indexPath) ?? .none
    }
    
    #if os(iOS)
    open func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        if let title = performCellReaction(.titleForDeleteButtonForRowAtIndexPath, location: indexPath, provideCell: true) as? String {
            return title
        }
        return (delegate as? UITableViewDelegate)?.tableView?(tableView, titleForDeleteConfirmationButtonForRowAt: indexPath)
    }
    #endif
    
    open func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        if let should = performCellReaction(.shouldIndentWhileEditingRowAtIndexPath, location: indexPath, provideCell: true) as? Bool {
            return should
        }
        return (delegate as? UITableViewDelegate)?.tableView?(tableView, shouldIndentWhileEditingRowAt: indexPath) ?? tableView.cellForRow(at: indexPath)?.shouldIndentWhileEditing ?? true
    }
    
    open func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        defer { (delegate as? UITableViewDelegate)?.tableView?(tableView, didEndDisplaying: cell, forRowAt: indexPath) }
        guard let model = storage.item(at: indexPath) else { return }
        _ = tableViewEventReactions.performReaction(of: .cell, signature: EventMethodSignature.didEndDisplayingCellForRowAtIndexPath.rawValue, view: cell, model: model, location: indexPath)
    }
    
    open func tableView(_ tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {
        defer { (delegate as? UITableViewDelegate)?.tableView?(tableView, didEndDisplayingHeaderView: view, forSection: section) }
        guard let model = (storage as? HeaderFooterStorage)?.headerModel(forSection: section) else { return }
        _ = tableViewEventReactions.performReaction(of: .supplementaryView(kind: DTTableViewElementSectionHeader), signature: EventMethodSignature.didEndDisplayingHeaderViewForSection.rawValue, view: view, model: model, location: IndexPath(item: 0, section: section))
    }
    
    open func tableView(_ tableView: UITableView, didEndDisplayingFooterView view: UIView, forSection section: Int) {
        defer { (delegate as? UITableViewDelegate)?.tableView?(tableView, didEndDisplayingFooterView: view, forSection: section) }
        guard let model = (storage as? HeaderFooterStorage)?.footerModel(forSection: section) else { return }
        _ = tableViewEventReactions.performReaction(of: .supplementaryView(kind: DTTableViewElementSectionFooter), signature: EventMethodSignature.didEndDisplayingFooterViewForSection.rawValue, view: view, model: model, location: IndexPath(item: 0, section: section))
    }
    
    open func tableView(_ tableView: UITableView, shouldShowMenuForRowAt indexPath: IndexPath) -> Bool {
        if let should = performCellReaction(.shouldShowMenuForRowAtIndexPath, location: indexPath, provideCell: true) as? Bool {
            return should
        }
        return (delegate as? UITableViewDelegate)?.tableView?(tableView, shouldShowMenuForRowAt: indexPath) ?? false
    }
    
    open func tableView(_ tableView: UITableView, canPerformAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        guard let item = storage.item(at: indexPath), let model = RuntimeHelper.recursivelyUnwrapAnyValue(item),
            let cell = tableView.cellForRow(at: indexPath)
            else { return false }
        if let reaction = tableViewEventReactions.reaction(of: .cell, signature: EventMethodSignature.canPerformActionForRowAtIndexPath.rawValue, forModel: model) as? FiveArgumentsEventReaction {
            return reaction.performWithArguments((action,sender as Any,cell,model,indexPath)) as? Bool ?? false
        }
        return (delegate as? UITableViewDelegate)?.tableView?(tableView, canPerformAction: action, forRowAt: indexPath, withSender: sender) ?? false
    }
    
    open func tableView(_ tableView: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) {
        defer { (delegate as? UITableViewDelegate)?.tableView?(tableView, performAction: action, forRowAt: indexPath, withSender: sender) }
        guard let item = storage.item(at: indexPath), let model = RuntimeHelper.recursivelyUnwrapAnyValue(item),
            let cell = tableView.cellForRow(at: indexPath)
            else { return }
        if let reaction = tableViewEventReactions.reaction(of: .cell, signature: EventMethodSignature.performActionForRowAtIndexPath.rawValue, forModel: model) as? FiveArgumentsEventReaction {
            _ = reaction.performWithArguments((action,sender as Any,cell,model,indexPath))
        }
    }
    
    open func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        if let should = performCellReaction(.shouldHighlightRowAtIndexPath, location: indexPath, provideCell: true) as? Bool {
            return should
        }
        return (delegate as? UITableViewDelegate)?.tableView?(tableView, shouldHighlightRowAt: indexPath) ?? true
    }
    
    open func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        defer { (delegate as? UITableViewDelegate)?.tableView?(tableView, didHighlightRowAt: indexPath) }
        _ = performCellReaction(.didHighlightRowAtIndexPath, location: indexPath, provideCell: true)
    }
    
    open func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        defer { (delegate as? UITableViewDelegate)?.tableView?(tableView, didUnhighlightRowAt: indexPath) }
        _ = performCellReaction(.didUnhighlightRowAtIndexPath, location: indexPath, provideCell: true)
    }
    
    @available(iOS 9.0, tvOS 9.0, *)
    open func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool {
        if let should = performCellReaction(.canFocusRowAtIndexPath, location: indexPath, provideCell: true) as? Bool {
            return should
        }
        return (delegate as? UITableViewDelegate)?.tableView?(tableView, canFocusRowAt: indexPath) ?? tableView.cellForRow(at: indexPath)?.canBecomeFocused ?? true
    }
    
    final fileprivate func performCellReaction(_ signature: EventMethodSignature, location: IndexPath, provideCell: Bool) -> Any? {
        var cell : UITableViewCell?
        if provideCell { cell = tableView?.cellForRow(at: location) }
        guard let model = storage.item(at: location) else { return nil }
        return tableViewEventReactions.performReaction(of: .cell, signature: signature.rawValue, view: cell, model: model, location: location)
    }
    
    final fileprivate func performHeaderReaction(_ signature: EventMethodSignature, location: Int, provideView: Bool) -> Any? {
        var view : UIView?
        if provideView {
            view = tableView?.headerView(forSection: location)
        }
        guard let model = (storage as? HeaderFooterStorage)?.headerModel(forSection: location) else { return nil}
        return tableViewEventReactions.performReaction(of: .supplementaryView(kind: DTTableViewElementSectionHeader), signature: signature.rawValue, view: view, model: model, location: IndexPath(item: 0, section: location))
    }
    
    final fileprivate func performFooterReaction(_ signature: EventMethodSignature, location: Int, provideView: Bool) -> Any? {
        var view : UIView?
        if provideView {
            view = tableView?.footerView(forSection: location)
        }
        guard let model = (storage as? HeaderFooterStorage)?.footerModel(forSection: location) else { return nil}
        return tableViewEventReactions.performReaction(of: .supplementaryView(kind: DTTableViewElementSectionFooter), signature: signature.rawValue, view: view, model: model, location: IndexPath(item: 0, section: location))
    }
}

// DEPRECATED

extension DTTableViewManager {
    @available(*, unavailable, renamed: "startManaging(withDelegate:)")
    open func startManagingWithDelegate(_ delegate : DTTableViewManageable)
    {
        fatalError("UNAVAILABLE")
    }
    
    @available(*,unavailable,renamed:"register(_:)")
    open func registerCellClass<T:ModelTransfer>(_ cellClass:T.Type) where T: UITableViewCell
    {
        fatalError("UNAVAILABLE")
    }
    
    @available(*,unavailable,renamed:"registerNibNamed(_:for:)")
    open func registerNibNamed<T:ModelTransfer>(_ nibName: String, forCellClass cellClass: T.Type) where T: UITableViewCell
    {
        fatalError("UNAVAILABLE")
    }
    
    @available(*,unavailable,renamed:"registerHeader(_:)")
    open func registerHeaderClass<T:ModelTransfer>(_ headerClass : T.Type) where T: UIView
    {
        fatalError("UNAVAILABLE")
    }
    
    @available(*,unavailable,renamed:"registerNiblessHeader(_:)")
    open func registerNiblessHeaderClass<T:ModelTransfer>(_ headerClass : T.Type) where T: UITableViewHeaderFooterView
    {
        fatalError("UNAVAILABLE")
    }
    
    @available(*,unavailable,renamed:"registerNiblessFooter(_:)")
    open func registerNiblessFooterClass<T:ModelTransfer>(_ footerClass : T.Type) where T: UITableViewHeaderFooterView
    {
        fatalError("UNAVAILABLE")
    }
    
    @available(*,unavailable,renamed:"registerFooter(_:)")
    open func registerFooterClass<T:ModelTransfer>(_ footerClass: T.Type) where T:UIView
    {
        fatalError("UNAVAILABLE")
    }
    
    @available(*,unavailable,renamed:"registerNibNamed(_:forHeader:)")
    open func registerNibNamed<T:ModelTransfer>(_ nibName: String, forHeaderClass headerClass: T.Type) where T:UIView
    {
        fatalError("UNAVAILABLE")
    }
    
    @available(*,unavailable,renamed:"registerNibNamed(_:forFooter:)")
    open func registerNibNamed<T:ModelTransfer>(_ nibName: String, forFooterClass footerClass: T.Type) where T:UIView
    {
        fatalError("UNAVAILABLE")
    }
    
    @available(*, unavailable, renamed:"didSelect(_:_:)")
    open func whenSelected<T:ModelTransfer>(_ cellClass:  T.Type, _ closure: @escaping (T,T.ModelType, IndexPath) -> Void) where T:UITableViewCell
    {
        fatalError("UNAVAILABLE")
    }
}
