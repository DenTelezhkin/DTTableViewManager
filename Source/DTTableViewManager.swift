
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

/// Adopting this protocol will automatically inject manager property to your object, that lazily instantiates DTTableViewManager object.
/// Target is not required to be UITableViewController, and can be a regular UIViewController with UITableView, or even different object like UICollectionViewCell.
public protocol DTTableViewManageable : class, NSObjectProtocol
{
    /// Table view, that will be managed by DTTableViewManager
    var tableView : UITableView! { get }
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

/// `DTTableViewManager` manages some of `UITableView` datasource and delegate methods and provides API for managing your data models in the table. Any method, that is not implemented by `DTTableViewManager`, will be forwarded to delegate.
/// - SeeAlso: `startManagingWithDelegate:`
open class DTTableViewManager : NSObject {
    
    /// Internal weak link to `UITableView`
    final fileprivate var tableView : UITableView?
    {
        return self.delegate?.tableView
    }
    
    /// `DTTableViewManageable` delegate.
    final fileprivate weak var delegate : DTTableViewManageable?
    
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
    fileprivate var tableViewEventReactions = ContiguousArray<EventReaction>() {
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
            fatalError("DTTableViewManager memoryStorage method should be called only if you are using MemoryStorage")
        }
        return storage
    }
    
    /// Storage, that holds your UITableView models. By default, it's `MemoryStorage` instance.
    /// - Note: When setting custom storage for this property, it will be automatically configured for using with UITableView and it's delegate will be set to `DTTableViewManager` instance.
    /// - Note: Previous storage `delegate` property will be nilled out to avoid collisions.
    /// - SeeAlso: `MemoryStorage`, `CoreDataStorage`.
    open var storage : Storage = {
        let storage = MemoryStorage()
        storage.configureForTableViewUsage()
        return storage
    }()
    {
        willSet {
            // explicit self is required due to known bug in Swift compiler - https://devforums.apple.com/message/1065306#1065306
            self.storage.delegate = nil
        }
        didSet {
            if let headerFooterCompatibleStorage = storage as? BaseStorage {
                headerFooterCompatibleStorage.configureForTableViewUsage()
            }
            storage.delegate = tableViewUpdater
        }
    }
    
    open var tableViewUpdater : StorageUpdating? {
        didSet {
            storage.delegate = tableViewUpdater
        }
    }
    
    /// Call this method before calling any of `DTTableViewManager` methods.
    /// - Precondition: UITableView instance on `delegate` should not be nil.
    /// - Parameter delegate: Object, that has UITableView, that will be managed by `DTTableViewManager`.
    /// - Note: If delegate is `DTViewModelMappingCustomizable`, it will also be used to determine which view-model mapping should be used by table view factory.
    open func startManagingWithDelegate(_ delegate : DTTableViewManageable)
    {
        guard let tableView = delegate.tableView else {
            preconditionFailure("Call startManagingWithDelegate: method only when UITableView has been created")
        }
        
        self.delegate = delegate
        tableView.delegate = self
        tableView.dataSource = self
        if let mappingDelegate = delegate as? ViewModelMappingCustomizing {
            viewFactory.mappingCustomizableDelegate = mappingDelegate
        }
        tableViewUpdater = TableViewUpdater(tableView: tableView)
        storage.delegate = tableViewUpdater
    }
    
    open func updateCellClosure() -> (IndexPath) -> Void {
        return { [weak self] in
            guard let model = self?.storage.item(at: $0) else { return }
            self?.viewFactory.updateCellAt($0, with: model)
        }
    }
    
    open func coreDataUpdater() -> TableViewUpdater {
        guard let tableView = delegate?.tableView else {
            preconditionFailure("Call startManagingWithDelegate: method only when UITableView has been created")
        }
        return TableViewUpdater(tableView: tableView,
                                reloadRow: updateCellClosure(),
                                animateMoveAsDeleteAndInsert: true)
    }
    
    /// Getter for header model at section index
    /// - Parameter index: index of section
    /// - Returns: header model
    final fileprivate func headerModelForSectionIndex(_ index: Int) -> Any?
    {
        guard self.storage.sections.count > index else { return nil }
        
        if self.storage.sections[index].numberOfItems == 0 && !configuration.displayHeaderOnEmptySection
        {
            return nil
        }
        return (self.storage as? HeaderFooterStorage)?.headerModel(forSection: index)
    }
    
    /// Getter for footer model at section index
    /// - Parameter index: index of section
    /// - Returns: footer model
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
    /// Any `UITableViewDatasource` and `UITableViewDelegate` method, that is not implemented by `DTTableViewManager` will be redirected to delegate, if it implements it.
    /// - Parameter aSelector: selector to forward
    /// - Returns: `DTTableViewManageable` delegate
    open override func forwardingTarget(for aSelector: Selector) -> Any? {
        return delegate
    }
    
    /// Any `UITableViewDatasource` and `UITableViewDelegate` method, that is not implemented by `DTTableViewManager` will be redirected to delegate, if it implements it.
    /// - Parameter aSelector: selector to respond to
    /// - Returns: whether delegate will respond to selector
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
    /// Register mapping from model class to custom cell class. Method will automatically check for nib with the same name as `cellClass`. If it exists - nib will be registered instead of class.
    /// - Note: Model type is automatically gathered from `ModelTransfer`.`ModelType` associated type.
    /// - Parameter cellClass: Type of UITableViewCell subclass, that is being registered for using by `DTTableViewManager`
    open func registerCellClass<T:ModelTransfer>(_ cellClass:T.Type) where T: UITableViewCell
    {
        self.viewFactory.registerCellClass(cellClass)
    }

    /// Register mapping from model class to custom cell class using specific nib file.
    /// - Note: Model type is automatically gathered from `ModelTransfer`.`ModelType` associated type.
    /// - Parameter nibName: Name of xib file to use
    /// - Parameter cellClass: Type of UITableViewCell subclass, that is being registered for using by `DTTableViewManager`
    open func registerNibNamed<T:ModelTransfer>(_ nibName: String, forCellClass cellClass: T.Type) where T: UITableViewCell
    {
        self.viewFactory.registerNibNamed(nibName, forCellClass: cellClass)
    }
    
    /// Register mapping from model class to custom header view class. Method will automatically check for nib with the same name as `headerClass`. If it exists - nib will be registered instead of class.
    /// - Note: Model type is automatically gathered from `ModelTransfer`.`ModelType` associated type.
    /// - Parameter headerClass: Type of UIView or UITableViewHeaderFooterView subclass, that is being registered for using by `DTTableViewManager`
    open func registerHeaderClass<T:ModelTransfer>(_ headerClass : T.Type) where T: UIView
    {
        configuration.sectionHeaderStyle = .view
        self.viewFactory.registerHeaderClass(headerClass)
    }
    
    /// Register mapping from model class to custom header view class. This method is intended to be used for headers created from code - without UI made in XIB.
    /// - Note: Model type is automatically gathered from `ModelTransfer`.`ModelType` associated type.
    /// - Parameter headerClass: UITableViewHeaderFooterView subclass, that is being registered for using by `DTTableViewManager`
    open func registerNiblessHeaderClass<T:ModelTransfer>(_ headerClass : T.Type) where T: UITableViewHeaderFooterView
    {
        configuration.sectionHeaderStyle = .view
        self.viewFactory.registerNiblessHeaderClass(headerClass)
    }
    
    /// Register mapping from model class to custom header view class. This method is intended to be used for footers created from code - without UI made in XIB.
    /// - Note: Model type is automatically gathered from `ModelTransfer`.`ModelType` associated type.
    /// - Parameter footerClass: UITableViewHeaderFooterView subclass, that is being registered for using by `DTTableViewManager`
    open func registerNiblessFooterClass<T:ModelTransfer>(_ footerClass : T.Type) where T: UITableViewHeaderFooterView
    {
        configuration.sectionFooterStyle = .view
        self.viewFactory.registerNiblessFooterClass(footerClass)
    }
    
    /// Register mapping from model class to custom footer view class. Method will automatically check for nib with the same name as `footerClass`. If it exists - nib will be registered instead of class.
    /// - Note: Model type is automatically gathered from `ModelTransfer`.`ModelType` associated type.
    /// - Parameter footerClass: Type of UIView or UITableViewHeaderFooterView subclass, that is being registered for using by `DTTableViewManager`
    open func registerFooterClass<T:ModelTransfer>(_ footerClass: T.Type) where T:UIView
    {
        configuration.sectionFooterStyle = .view
        viewFactory.registerFooterClass(footerClass)
    }
    
    /// Register mapping from model class to custom header class using specific nib file.
    /// - Note: Model type is automatically gathered from `ModelTransfer`.`ModelType` associated type.
    /// - Parameter nibName: Name of xib file to use
    /// - Parameter headerClass: Type of UIView or UITableReusableView subclass, that is being registered for using by `DTTableViewManager`
    open func registerNibNamed<T:ModelTransfer>(_ nibName: String, forHeaderClass headerClass: T.Type) where T:UIView
    {
        configuration.sectionHeaderStyle = .view
        viewFactory.registerNibNamed(nibName, forHeaderClass: headerClass)
    }
    
    /// Register mapping from model class to custom footer class using specific nib file.
    /// - Note: Model type is automatically gathered from `ModelTransfer`.`ModelType` associated type.
    /// - Parameter nibName: Name of xib file to use
    /// - Parameter footerClass: Type of UIView or UITableReusableView subclass, that is being registered for using by `DTTableViewManager`
    open func registerNibNamed<T:ModelTransfer>(_ nibName: String, forFooterClass footerClass: T.Type) where T:UIView
    {
        configuration.sectionFooterStyle = .view
        viewFactory.registerNibNamed(nibName, forFooterClass: footerClass)
    }
    
    open func unregisterCellClass<T:ModelTransfer>(_ cellClass: T.Type) where T:UITableViewCell {
        viewFactory.unregisterCellClass(T.self)
    }
    
    open func unregisterHeaderClass<T:ModelTransfer>(_ headerClass: T.Type) where T: UIView {
        viewFactory.unregisterHeaderClass(T.self)
    }
  
    open func unregisterFooterClass<T:ModelTransfer>(_ footerClass: T.Type) where T: UIView {
        viewFactory.unregisterFooterClass(T.self)
    }
}

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
    
    /// Define an action, that will be performed, when cell of specific type is selected(didSelectRowAtIndexPath delegate method).
    /// - Parameter cellClass: Type of UITableViewCell subclass
    /// - Parameter closure: closure to run when UITableViewCell is selected
    /// - Warning: Closure will be stored on `DTTableViewManager` instance, which can create a retain cycle, so make sure to declare weak self and any other `DTTableViewManager` property in capture lists.
    open func didSelect<T:ModelTransfer>(_ cellClass:  T.Type, _ closure: @escaping (T,T.ModelType, IndexPath) -> Void) where T:UITableViewCell
    {
        appendReaction(for: T.self, signature: .didSelectRowAtIndexPath, closure: closure)
    }
    
    open func willSelect<T:ModelTransfer>(_ cellClass:  T.Type, _ closure: @escaping (T,T.ModelType, IndexPath) -> IndexPath?) where T:UITableViewCell {
        appendReaction(for: T.self, signature: .willSelectRowAtIndexPath, closure: closure)
    }
    
    open func willDeselect<T:ModelTransfer>(_ cellClass:  T.Type, _ closure: @escaping (T,T.ModelType, IndexPath) -> IndexPath?) where T:UITableViewCell {
        appendReaction(for: T.self, signature: .willDeselectRowAtIndexPath, closure: closure)
    }
    
    open func didDeselect<T:ModelTransfer>(_ cellClass:  T.Type, _ closure: @escaping (T,T.ModelType, IndexPath) -> IndexPath?) where T:UITableViewCell {
        appendReaction(for: T.self, signature: .didDeselectRowAtIndexPath, closure: closure)
    }
    
    @available(*, unavailable, renamed:"didSelect(_:_:)")
    open func whenSelected<T:ModelTransfer>(_ cellClass:  T.Type, _ closure: @escaping (T,T.ModelType, IndexPath) -> Void) where T:UITableViewCell
    {
        didSelect(cellClass,closure)
    }
    
    /// Define additional configuration action, that will happen, when UITableViewCell subclass is requested by UITableView. This action will be performed *after* cell is created and updateWithModel: method is called.
    /// - Parameter cellClass: Type of UITableViewCell subclass
    /// - Parameter closure: closure to run when UITableViewCell is being configured
    /// - Warning: Closure will be stored on `DTTableViewManager` instance, which can create a retain cycle, so make sure to declare weak self and any other `DTTableViewManager` property in capture lists.
    open func configureCell<T:ModelTransfer>(_ cellClass:T.Type, _ closure: @escaping (T, T.ModelType, IndexPath) -> Void) where T: UITableViewCell
    {
        appendReaction(for: T.self, signature: .configureCell, closure: closure)
    }
    
    /// Define additional configuration action, that will happen, when UIView header subclass is requested by UITableView. This action will be performed *after* header is created and updateWithModel: method is called.
    /// - Parameter headerClass: Type of UIView or UITableHeaderFooterView subclass
    /// - Parameter closure: closure to run when UITableHeaderFooterView is being configured
    /// - Warning: Closure will be stored on `DTTableViewManager` instance, which can create a retain cycle, so make sure to declare weak self and any other `DTTableViewManager` property in capture lists.
    open func configureHeader<T:ModelTransfer>(_ headerClass: T.Type, _ closure: @escaping (T, T.ModelType, Int) -> Void) where T: UIView
    {
        appendReaction(forSupplementaryKind: DTTableViewElementSectionHeader, supplementaryClass: T.self, signature: EventMethodSignature.configureHeader, closure: closure)
    }
    
    /// Define additional configuration action, that will happen, when UIView footer subclass is requested by UITableView. This action will be performed *after* footer is created and updateWithModel: method is called.
    /// - Parameter footerClass: Type of UIView or UITableReusableView subclass
    /// - Parameter closure: closure to run when UITableReusableView is being configured
    /// - Warning: Closure will be stored on `DTTableViewManager` instance, which can create a retain cycle, so make sure to declare weak self and any other `DTTableViewManager` property in capture lists.
    open func configureFooter<T:ModelTransfer>(_ footerClass: T.Type, _ closure: @escaping (T, T.ModelType, Int) -> Void) where T: UIView
    {
        appendReaction(forSupplementaryKind: DTTableViewElementSectionFooter, supplementaryClass: T.self, signature: EventMethodSignature.configureFooter, closure: closure)
    }
    
    open func heightForCell<T>(withItemType: T.Type, closure: @escaping (T, IndexPath) -> CGFloat) {
        appendReaction(for: T.self, signature: EventMethodSignature.heightForRowAtIndexPath, closure: closure)
    }
    
    open func estimatedHeightForCell<T>(withItemType: T.Type, closure: @escaping (T, IndexPath) -> CGFloat) {
        appendReaction(for: T.self, signature: EventMethodSignature.estimatedHeightForRowAtIndexPath, closure: closure)
    }
    
    open func indentationLevel<T>(forItemType: T.Type, closure: @escaping (T, IndexPath) -> CGFloat) {
        appendReaction(for: T.self, signature: EventMethodSignature.indentationLevelForRowAtIndexPath, closure: closure)
    }
    
    open func willDisplay<T:ModelTransfer>(_ cellClass:T.Type, _ closure: @escaping (T, T.ModelType, IndexPath) -> Void) where T: UITableViewCell
    {
        appendReaction(for: T.self, signature: EventMethodSignature.willDisplayCellForRowAtIndexPath, closure: closure)
    }
    
    #if os(iOS)
    open func editActions<T:ModelTransfer>(for cellClass: T.Type, _ closure: @escaping (T, T.ModelType, IndexPath) -> [UITableViewRowAction]?) where T: UITableViewCell {
        appendReaction(for: T.self, signature: EventMethodSignature.editActionsForRowAtIndexPath, closure: closure)
    }
    #endif
    
    open func accessoryButtonTapped<T:ModelTransfer>(in cellClass: T.Type, _ closure: @escaping (T, T.ModelType, IndexPath) -> Void) where T: UITableViewCell {
        appendReaction(for: T.self, signature: EventMethodSignature.accessoryButtonTappedForRowAtIndexPath, closure: closure)
    }
    
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
    
    open func canEditCell<T>(withItemType type: T.Type, _ closure: @escaping (T, IndexPath) -> Bool) {
        appendReaction(for: T.self, signature: EventMethodSignature.canEditRowAtIndexPath, closure: closure)
    }
    
    open func canMove<T:ModelTransfer>(_ cellClass: T.Type, _ closure: @escaping (T, T.ModelType, IndexPath) -> Bool) where T: UITableViewCell {
        appendReaction(for: T.self, signature: EventMethodSignature.canMoveRowAtIndexPath, closure: closure)
    }
    
    open func heightForHeader<T>(withItemType type: T.Type, _ closure: @escaping (T, Int) -> CGFloat) {
        appendReaction(forSupplementaryKind: DTTableViewElementSectionHeader, modelClass: T.self, signature: EventMethodSignature.heightForHeaderInSection, closure: closure)
    }
    
    open func estimatedHeightForHeader<T>(withItemType type: T.Type, _ closure: @escaping (T, Int) -> CGFloat) {
        appendReaction(forSupplementaryKind: DTTableViewElementSectionHeader, modelClass: T.self, signature: EventMethodSignature.estimatedHeightForHeaderInSection, closure: closure)
    }
    
    open func heightForFooter<T>(withItemType type: T.Type, _ closure: @escaping (T, Int) -> CGFloat) {
        appendReaction(forSupplementaryKind: DTTableViewElementSectionFooter, modelClass: T.self, signature: EventMethodSignature.heightForFooterInSection, closure: closure)
    }
    
    open func estimatedHeightForFooter<T>(withItemType type: T.Type, _ closure: @escaping (T, Int) -> CGFloat) {
        appendReaction(forSupplementaryKind: DTTableViewElementSectionFooter, modelClass: T.self, signature: EventMethodSignature.estimatedHeightForFooterInSection, closure: closure)
    }
    
    open func willDisplayHeaderView<T:ModelTransfer>(_ headerClass: T.Type, _ closure: @escaping (T, T.ModelType, Int) -> Void) where T: UIView
    {
        appendReaction(forSupplementaryKind: DTTableViewElementSectionHeader, supplementaryClass: T.self, signature: EventMethodSignature.willDisplayHeaderForSection, closure: closure)
    }
    
    open func willDisplayFooterView<T:ModelTransfer>(_ footerClass: T.Type, _ closure: @escaping (T, T.ModelType, Int) -> Void) where T: UIView
    {
        appendReaction(forSupplementaryKind: DTTableViewElementSectionFooter, supplementaryClass: T.self, signature: EventMethodSignature.willDisplayFooterForSection, closure: closure)
    }
    
    #if os(iOS)
    open func willBeginEditing<T:ModelTransfer>(_ cellClass:T.Type, _ closure: @escaping (T, T.ModelType, IndexPath) -> Void) where T: UITableViewCell
    {
        appendReaction(for: T.self, signature: EventMethodSignature.willBeginEditingRowAtIndexPath, closure: closure)
    }
    #endif
    
    #if os(iOS)
    open func didEndEditing<T:ModelTransfer>(_ cellClass:T.Type, _ closure: @escaping (T, T.ModelType, IndexPath) -> Void) where T: UITableViewCell
    {
        appendReaction(for: T.self, signature: EventMethodSignature.didEndEditingRowAtIndexPath, closure: closure)
    }
    #endif
    
    open func editingStyle<T:ModelTransfer>(for cellClass:T.Type, _ closure: @escaping (T, T.ModelType, IndexPath) -> UITableViewCellEditingStyle) where T: UITableViewCell
    {
        appendReaction(for: T.self, signature: EventMethodSignature.editingStyleForRowAtIndexPath, closure: closure)
    }
    
    #if os(iOS)
    open func titleForDeleteConfirmationButton<T:ModelTransfer>(in cellClass:T.Type, _ closure: @escaping (T, T.ModelType, IndexPath) -> String?) where T: UITableViewCell
    {
        appendReaction(for: T.self, signature: EventMethodSignature.titleForDeleteButtonForRowAtIndexPath, closure: closure)
    }
    #endif
    
    open func shouldIndentWhileEditing<T:ModelTransfer>(_ cellClass:T.Type, _ closure: @escaping (T, T.ModelType, IndexPath) -> Bool) where T: UITableViewCell
    {
        appendReaction(for: T.self, signature: EventMethodSignature.shouldIndentWhileEditingRowAtIndexPath, closure: closure)
    }
    
    open func didEndDisplaying<T:ModelTransfer>(_ cellClass:T.Type, _ closure: @escaping (T, T.ModelType, IndexPath) -> Void) where T: UITableViewCell {
        appendReaction(for: T.self, signature: EventMethodSignature.didEndDisplayingCellForRowAtIndexPath, closure: closure)
    }
    
    open func didEndDisplayingHeaderView<T:ModelTransfer>(_ headerClass: T.Type, _ closure: @escaping (T, T.ModelType, Int) -> Void) where T: UIView
    {
        appendReaction(forSupplementaryKind: DTTableViewElementSectionHeader, supplementaryClass: T.self, signature: EventMethodSignature.didEndDisplayingHeaderViewForSection, closure: closure)
    }
    
    open func didEndDisplayingFooterView<T:ModelTransfer>(_ footerClass: T.Type, _ closure: @escaping (T, T.ModelType, Int) -> Void) where T: UIView
    {
        appendReaction(forSupplementaryKind: DTTableViewElementSectionFooter, supplementaryClass: T.self, signature: EventMethodSignature.didEndDisplayingFooterViewForSection, closure: closure)
    }
    
    open func shouldShowMenu<T:ModelTransfer>(for cellClass:T.Type, _ closure: @escaping (T, T.ModelType, IndexPath) -> Bool) where T: UITableViewCell
    {
        appendReaction(for: T.self, signature: EventMethodSignature.shouldShowMenuForRowAtIndexPath, closure: closure)
    }
    
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
    
    open func shouldHighlight<T:ModelTransfer>(_ cellClass:T.Type, _ closure: @escaping (T, T.ModelType, IndexPath) -> Bool) where T: UITableViewCell
    {
        appendReaction(for: T.self, signature: EventMethodSignature.shouldHighlightRowAtIndexPath, closure: closure)
    }
    
    open func didHighlight<T:ModelTransfer>(_ cellClass:T.Type, _ closure: @escaping (T, T.ModelType, IndexPath) -> Void) where T: UITableViewCell
    {
        appendReaction(for: T.self, signature: EventMethodSignature.didHighlightRowAtIndexPath, closure: closure)
    }
    
    open func didUnhighlight<T:ModelTransfer>(_ cellClass:T.Type, _ closure: @escaping (T, T.ModelType, IndexPath) -> Void) where T: UITableViewCell
    {
        appendReaction(for: T.self, signature: EventMethodSignature.didUnhighlightRowAtIndexPath, closure: closure)
    }
    
    @available(iOS 9.0, tvOS 9.0, *)
    open func canFocus<T:ModelTransfer>(_ cellClass:T.Type, _ closure: @escaping (T, T.ModelType, IndexPath) -> Bool) where T: UITableViewCell
    {
        appendReaction(for: T.self, signature: EventMethodSignature.canFocusRowAtIndexPath, closure: closure)
    }
}

// MARK: - UITableViewDatasource
extension DTTableViewManager: UITableViewDataSource
{
    @nonobjc func handleTableViewFactoryError(_ error: DTTableViewFactoryError) {
        if let handler = viewFactoryErrorHandler {
            handler(error)
        } else {
            print((error as NSError).description)
            fatalError(error.description)
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
        
        _ = tableViewEventReactions.performReaction(ofType: .cell, signature: EventMethodSignature.configureCell.rawValue, view: cell, model: model, location: indexPath)
        return cell
    }
    
    open func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if configuration.sectionHeaderStyle == .view { return nil }
        
        return self.headerModelForSectionIndex(section) as? String
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
        guard let model = RuntimeHelper.recursivelyUnwrapAnyValue(storage.item(at: indexPath)),
            let cell = tableView.cellForRow(at: indexPath)
            else { return }
        if let reaction = tableViewEventReactions.reactionOfType(.cell, signature: EventMethodSignature.commitEditingStyleForRowAtIndexPath.rawValue, forModel: model) as? FourArgumentsEventReaction {
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
        _ = tableViewEventReactions.performReaction(ofType: .cell, signature: EventMethodSignature.willDisplayCellForRowAtIndexPath.rawValue, view: cell, model: model, location: indexPath)
    }
    
    open func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        defer { (delegate as? UITableViewDelegate)?.tableView?(tableView, willDisplayHeaderView: view, forSection: section) }
        guard let model = (storage as? HeaderFooterStorage)?.headerModel(forSection: section) else { return }
        _ = tableViewEventReactions.performReaction(ofType: .supplementary(kind: DTTableViewElementSectionHeader), signature: EventMethodSignature.willDisplayHeaderForSection.rawValue, view: view, model: model, location: IndexPath(item: 0, section: section))
    }
    
    open func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        defer { (delegate as? UITableViewDelegate)?.tableView?(tableView, willDisplayFooterView: view, forSection: section) }
        guard let model = (storage as? HeaderFooterStorage)?.footerModel(forSection: section) else { return }
        _ = tableViewEventReactions.performReaction(ofType: .supplementary(kind: DTTableViewElementSectionFooter), signature: EventMethodSignature.willDisplayFooterForSection.rawValue, view: view, model: model, location: IndexPath(item: 0, section: section))
    }
    
    open func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if configuration.sectionHeaderStyle == .title { return nil }
        
        if let model = self.headerModelForSectionIndex(section) {
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
                _ = tableViewEventReactions.performReaction(ofType: .supplementary(kind: DTTableViewElementSectionHeader),
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
                _ = tableViewEventReactions.performReaction(ofType: .supplementary(kind: DTTableViewElementSectionFooter),
                                                         signature: EventMethodSignature.configureFooter.rawValue,
                                                         view: createdView, model: model, location: IndexPath(item: 0, section: section))
            }
            return view
        }
        return nil
    }
    
    /// You can implement this method on a `DTTableViewManageable` delegate, and then it will be called to determine header height
    /// - Note: In most cases, it's enough to set sectionHeaderHeight property on UITableView and overriding this method is not actually needed
    /// - Note: If you override this method on a delegate, displayHeaderOnEmptySection property is ignored
    open func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if let height = performHeaderReaction(.heightForHeaderInSection, location: section, provideView: false) as? CGFloat {
            return height
        }
        if configuration.sectionHeaderStyle == .title {
            if let _ = self.headerModelForSectionIndex(section)
            {
                return UITableViewAutomaticDimension
            }
            return CGFloat.leastNormalMagnitude
        }
        
        if let _ = self.headerModelForSectionIndex(section)
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
    
    /// You can implement this method on a `DTTableViewManageable` delegate, and then it will be called to determine footer height
    /// - Note: In most cases, it's enough to set sectionFooterHeight property on UITableView and overriding this method is not actually needed
    /// - Note: If you override this method on a delegate, displayFooterOnEmptySection property is ignored
    open func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if let height = performFooterReaction(.heightForFooterInSection, location: section, provideView: false) as? CGFloat {
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
        _ = tableViewEventReactions.performReaction(ofType: .cell, signature: EventMethodSignature.didEndDisplayingCellForRowAtIndexPath.rawValue, view: cell, model: model, location: indexPath)
    }
    
    open func tableView(_ tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {
        defer { (delegate as? UITableViewDelegate)?.tableView?(tableView, didEndDisplayingHeaderView: view, forSection: section) }
        guard let model = (storage as? HeaderFooterStorage)?.headerModel(forSection: section) else { return }
        _ = tableViewEventReactions.performReaction(ofType: .supplementary(kind: DTTableViewElementSectionHeader), signature: EventMethodSignature.didEndDisplayingHeaderViewForSection.rawValue, view: view, model: model, location: IndexPath(item: 0, section: section))
    }
    
    open func tableView(_ tableView: UITableView, didEndDisplayingFooterView view: UIView, forSection section: Int) {
        defer { (delegate as? UITableViewDelegate)?.tableView?(tableView, didEndDisplayingFooterView: view, forSection: section) }
        guard let model = (storage as? HeaderFooterStorage)?.footerModel(forSection: section) else { return }
        _ = tableViewEventReactions.performReaction(ofType: .supplementary(kind: DTTableViewElementSectionFooter), signature: EventMethodSignature.didEndDisplayingFooterViewForSection.rawValue, view: view, model: model, location: IndexPath(item: 0, section: section))
    }
    
    open func tableView(_ tableView: UITableView, shouldShowMenuForRowAt indexPath: IndexPath) -> Bool {
        if let should = performCellReaction(.shouldShowMenuForRowAtIndexPath, location: indexPath, provideCell: true) as? Bool {
            return should
        }
        return (delegate as? UITableViewDelegate)?.tableView?(tableView, shouldShowMenuForRowAt: indexPath) ?? false
    }
    
    open func tableView(_ tableView: UITableView, canPerformAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        guard let model = RuntimeHelper.recursivelyUnwrapAnyValue(storage.item(at: indexPath)),
            let cell = tableView.cellForRow(at: indexPath)
            else { return false }
        if let reaction = tableViewEventReactions.reactionOfType(.cell, signature: EventMethodSignature.canPerformActionForRowAtIndexPath.rawValue, forModel: model) as? FiveArgumentsEventReaction {
            return reaction.performWithArguments((action,sender,cell,model,indexPath)) as? Bool ?? false
        }
        return (delegate as? UITableViewDelegate)?.tableView?(tableView, canPerformAction: action, forRowAt: indexPath, withSender: sender) ?? false
    }
    
    open func tableView(_ tableView: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) {
        defer { (delegate as? UITableViewDelegate)?.tableView?(tableView, performAction: action, forRowAt: indexPath, withSender: sender) }
        guard let model = RuntimeHelper.recursivelyUnwrapAnyValue(storage.item(at: indexPath)),
            let cell = tableView.cellForRow(at: indexPath)
            else { return }
        if let reaction = tableViewEventReactions.reactionOfType(.cell, signature: EventMethodSignature.performActionForRowAtIndexPath.rawValue, forModel: model) as? FiveArgumentsEventReaction {
            _ = reaction.performWithArguments((action,sender,cell,model,indexPath))
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
        return tableViewEventReactions.performReaction(ofType: .cell, signature: signature.rawValue, view: cell, model: model, location: location)
    }
    
    final fileprivate func performHeaderReaction(_ signature: EventMethodSignature, location: Int, provideView: Bool) -> Any? {
        var view : UIView?
        if provideView {
            view = tableView?.headerView(forSection: location)
        }
        guard let model = (storage as? HeaderFooterStorage)?.headerModel(forSection: location) else { return nil}
        return tableViewEventReactions.performReaction(ofType: .supplementary(kind: DTTableViewElementSectionHeader), signature: signature.rawValue, view: view, model: model, location: IndexPath(item: 0, section: location))
    }
    
    final fileprivate func performFooterReaction(_ signature: EventMethodSignature, location: Int, provideView: Bool) -> Any? {
        var view : UIView?
        if provideView {
            view = tableView?.footerView(forSection: location)
        }
        guard let model = (storage as? HeaderFooterStorage)?.footerModel(forSection: location) else { return nil}
        return tableViewEventReactions.performReaction(ofType: .supplementary(kind: DTTableViewElementSectionFooter), signature: signature.rawValue, view: view, model: model, location: IndexPath(item: 0, section: location))
    }
}
