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
public protocol DTTableViewManageable : NSObjectProtocol
{
    /// Table view, that will be managed by DTTableViewManager
    var tableView : UITableView! { get }
}

/// This key is used to store `DTTableViewManager` instance on `DTTableViewManageable` class using object association.
private var DTTableViewManagerAssociatedKey = "Manager Associated Key"

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
public class DTTableViewManager : NSObject {
    
    /// Internal weak link to `UITableView`
    private var tableView : UITableView?
    {
        return self.delegate?.tableView
    }
    
    /// `DTTableViewManageable` delegate.
    private weak var delegate : DTTableViewManageable?
    
    /// Bool property, that will be true, after `startManagingWithDelegate` method is called on `DTTableViewManager`.
    public var isManagingTableView : Bool {
        return tableView != nil
    }

    ///  Factory for creating cells and views for UITableView
    lazy var viewFactory: TableViewFactory = {
        precondition(self.isManagingTableView, "Please call manager.startManagingWithDelegate(self) before calling any other DTTableViewManager methods")
        return TableViewFactory(tableView: self.tableView!)
    }()
    
    /// Stores all configuration options for `DTTableViewManager`.
    /// - SeeAlso: `TableViewConfiguration`.
    public var configuration = TableViewConfiguration()
    
    /// Array of reactions for `DTTableViewManager`
    /// - SeeAlso: `EventReaction`.
    private var tableViewEventReactions = ContiguousArray<EventReaction>() {
        didSet {
            // Resetting delegate is needed, because UITableView caches results of `respondsToSelector` call, and never calls it again until `setDelegate` method is called.
            // We force UITableView to flush that cache and query us again, because with new event we might have new delegate or datasource method to respond to.
            tableView?.delegate = self
            tableView?.dataSource = self
        }
    }
    
    /// Error handler ot be executed when critical error happens with `TableViewFactory`.
    /// This can be useful to provide more debug information for crash logs, since preconditionFailure Swift method provides little to zero insight about what happened and when.
    /// This closure will be called prior to calling preconditionFailure in `handleTableViewFactoryError` method.
    @nonobjc public var viewFactoryErrorHandler : ((DTTableViewFactoryError) -> Void)?
    
    /// Implicitly unwrap storage property to `MemoryStorage`.
    /// - Warning: if storage is not MemoryStorage, will throw an exception.
    public var memoryStorage : MemoryStorage!
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
    public var storage : StorageProtocol = {
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
            storage.delegate = self
        }
    }
    
    /// Call this method before calling any of `DTTableViewManager` methods.
    /// - Precondition: UITableView instance on `delegate` should not be nil.
    /// - Parameter delegate: Object, that has UITableView, that will be managed by `DTTableViewManager`.
    /// - Note: If delegate is `DTViewModelMappingCustomizable`, it will also be used to determine which view-model mapping should be used by table view factory.
    public func startManagingWithDelegate(_ delegate : DTTableViewManageable)
    {
        precondition(delegate.tableView != nil,"Call startManagingWithDelegate: method only when UITableView has been created")
        
        self.delegate = delegate
        delegate.tableView.delegate = self
        delegate.tableView.dataSource = self
        if let mappingDelegate = delegate as? DTViewModelMappingCustomizable {
            viewFactory.mappingCustomizableDelegate = mappingDelegate
        }
        storage.delegate = self
    }
    
    /// Call this method to retrieve model from specific UITableViewCell subclass.
    /// - Note: This method uses UITableView `indexPathForCell` method, that returns nil if cell is not visible. Therefore, if cell is not visible, this method will return nil as well.
    /// - SeeAlso: `StorageProtocol` method `objectForCell:atIndexPath:` - will return model even if cell is not visible
    public func itemForVisibleCell<T:ModelTransfer where T:UITableViewCell>(_ cell:T?) -> T.ModelType?
    {
        guard let cell = cell else {  return nil }
        
        if let indexPath = tableView?.indexPath(for: cell) {
            return storage.itemAtIndexPath(indexPath) as? T.ModelType
        }
        return nil
    }
    
    /// Retrieve model of specific type at index path.
    /// - Parameter cell: UITableViewCell type
    /// - Parameter indexPath: NSIndexPath of the data model
    /// - Returns: data model that belongs to this index path.
    /// - Note: Method does not require cell to be visible, however it requires that storage really contains object of `ModelType` at specified index path, otherwise it will return nil.
    public func itemForCellClass<T:ModelTransfer where T:UITableViewCell>(_ cellClass: T.Type, atIndexPath indexPath: IndexPath) -> T.ModelType?
    {
        return self.storage.itemForCellClass(T.self, atIndexPath: indexPath)
    }
    
    /// Retrieve model of specific type for section index.
    /// - Parameter headerView: UIView type
    /// - Parameter indexPath: NSIndexPath of the view
    /// - Returns: data model that belongs to this view
    /// - Note: Method does not require header to be visible, however it requires that storage really contains object of `ModelType` at specified section index, and storage to comply to `HeaderFooterStorageProtocol`, otherwise it will return nil.
    public func itemForHeaderClass<T:ModelTransfer where T:UIView>(_ headerClass: T.Type, atSectionIndex sectionIndex: Int) -> T.ModelType?
    {
        return self.storage.itemForHeaderClass(T.self, atSectionIndex: sectionIndex)
    }
    
    /// Retrieve model of specific type for section index.
    /// - Parameter footerView: UIView type
    /// - Parameter indexPath: NSIndexPath of the view
    /// - Returns: data model that belongs to this view
    /// - Note: Method does not require footer to be visible, however it requires that storage really contains object of `ModelType` at specified section index, and storage to comply to `HeaderFooterStorageProtocol`, otherwise it will return nil.
    public func itemForFooterClass<T:ModelTransfer where T:UIView>(_ footerClass: T.Type, atSectionIndex sectionIndex: Int) -> T.ModelType?
    {
        return self.storage.itemForFooterClass(T.self, atSectionIndex: sectionIndex)
    }
    
    /// Getter for header model at section index
    /// - Parameter index: index of section
    /// - Returns: header model
    private func headerModelForSectionIndex(_ index: Int) -> Any?
    {
        guard self.storage.sections.count > index else { return nil }
        
        if self.storage.sections[index].numberOfItems == 0 && !configuration.displayHeaderOnEmptySection
        {
            return nil
        }
        return (self.storage as? HeaderFooterStorageProtocol)?.headerModelForSectionIndex(index)
    }
    
    /// Getter for footer model at section index
    /// - Parameter index: index of section
    /// - Returns: footer model
    private func footerModelForSectionIndex(_ index: Int) -> Any?
    {
        guard self.storage.sections.count > index else { return nil }
        
        if self.storage.sections[index].numberOfItems == 0 && !configuration.displayFooterOnEmptySection
        {
            return nil
        }
        return (self.storage as? HeaderFooterStorageProtocol)?.footerModelForSectionIndex(index)
    }
}

// MARK: - Runtime forwarding
extension DTTableViewManager
{
    /// Any `UITableViewDatasource` and `UITableViewDelegate` method, that is not implemented by `DTTableViewManager` will be redirected to delegate, if it implements it.
    /// - Parameter aSelector: selector to forward
    /// - Returns: `DTTableViewManageable` delegate
    public override func forwardingTarget(for aSelector: Selector) -> AnyObject? {
        return delegate
    }
    
    /// Any `UITableViewDatasource` and `UITableViewDelegate` method, that is not implemented by `DTTableViewManager` will be redirected to delegate, if it implements it.
    /// - Parameter aSelector: selector to respond to
    /// - Returns: whether delegate will respond to selector
    public override func responds(to aSelector: Selector) -> Bool {
        if self.delegate?.responds(to: aSelector) ?? false {
            return true
        }
        if super.responds(to: aSelector) {
            if let eventSelector = EventMethodSignature(rawValue: String(aSelector)) {
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
    public func registerCellClass<T:ModelTransfer where T: UITableViewCell>(_ cellClass:T.Type)
    {
        self.viewFactory.registerCellClass(cellClass)
    }

    /// Register mapping from model class to custom cell class using specific nib file.
    /// - Note: Model type is automatically gathered from `ModelTransfer`.`ModelType` associated type.
    /// - Parameter nibName: Name of xib file to use
    /// - Parameter cellClass: Type of UITableViewCell subclass, that is being registered for using by `DTTableViewManager`
    public func registerNibNamed<T:ModelTransfer where T: UITableViewCell>(_ nibName: String, forCellClass cellClass: T.Type)
    {
        self.viewFactory.registerNibNamed(nibName, forCellClass: cellClass)
    }
    
    /// Register mapping from model class to custom header view class. Method will automatically check for nib with the same name as `headerClass`. If it exists - nib will be registered instead of class.
    /// - Note: Model type is automatically gathered from `ModelTransfer`.`ModelType` associated type.
    /// - Parameter headerClass: Type of UIView or UITableViewHeaderFooterView subclass, that is being registered for using by `DTTableViewManager`
    public func registerHeaderClass<T:ModelTransfer where T: UIView>(_ headerClass : T.Type)
    {
        configuration.sectionHeaderStyle = .view
        self.viewFactory.registerHeaderClass(headerClass)
    }
    
    /// Register mapping from model class to custom header view class. This method is intended to be used for headers created from code - without UI made in XIB.
    /// - Note: Model type is automatically gathered from `ModelTransfer`.`ModelType` associated type.
    /// - Parameter headerClass: UITableViewHeaderFooterView subclass, that is being registered for using by `DTTableViewManager`
    public func registerNiblessHeaderClass<T:ModelTransfer where T: UITableViewHeaderFooterView>(_ headerClass : T.Type)
    {
        configuration.sectionHeaderStyle = .view
        self.viewFactory.registerNiblessHeaderClass(headerClass)
    }
    
    /// Register mapping from model class to custom header view class. This method is intended to be used for footers created from code - without UI made in XIB.
    /// - Note: Model type is automatically gathered from `ModelTransfer`.`ModelType` associated type.
    /// - Parameter footerClass: UITableViewHeaderFooterView subclass, that is being registered for using by `DTTableViewManager`
    public func registerNiblessFooterClass<T:ModelTransfer where T: UITableViewHeaderFooterView>(_ footerClass : T.Type)
    {
        configuration.sectionFooterStyle = .view
        self.viewFactory.registerNiblessFooterClass(footerClass)
    }
    
    /// Register mapping from model class to custom footer view class. Method will automatically check for nib with the same name as `footerClass`. If it exists - nib will be registered instead of class.
    /// - Note: Model type is automatically gathered from `ModelTransfer`.`ModelType` associated type.
    /// - Parameter footerClass: Type of UIView or UITableViewHeaderFooterView subclass, that is being registered for using by `DTTableViewManager`
    public func registerFooterClass<T:ModelTransfer where T:UIView>(_ footerClass: T.Type)
    {
        configuration.sectionFooterStyle = .view
        viewFactory.registerFooterClass(footerClass)
    }
    
    /// Register mapping from model class to custom header class using specific nib file.
    /// - Note: Model type is automatically gathered from `ModelTransfer`.`ModelType` associated type.
    /// - Parameter nibName: Name of xib file to use
    /// - Parameter headerClass: Type of UIView or UITableReusableView subclass, that is being registered for using by `DTTableViewManager`
    public func registerNibNamed<T:ModelTransfer where T:UIView>(_ nibName: String, forHeaderClass headerClass: T.Type)
    {
        configuration.sectionHeaderStyle = .view
        viewFactory.registerNibNamed(nibName, forHeaderClass: headerClass)
    }
    
    /// Register mapping from model class to custom footer class using specific nib file.
    /// - Note: Model type is automatically gathered from `ModelTransfer`.`ModelType` associated type.
    /// - Parameter nibName: Name of xib file to use
    /// - Parameter footerClass: Type of UIView or UITableReusableView subclass, that is being registered for using by `DTTableViewManager`
    public func registerNibNamed<T:ModelTransfer where T:UIView>(_ nibName: String, forFooterClass footerClass: T.Type)
    {
        configuration.sectionFooterStyle = .view
        viewFactory.registerNibNamed(nibName, forFooterClass: footerClass)
    }
    
}

/// Protocol you can conform to react to content updates
public protocol DTTableViewContentUpdatable {
    
    /// This event is triggered before content update occurs. If you need to update UITableView and trigger these delegate callbacks, call `storageNeedsReloading` method on storage class.
    /// - SeeAlso: `storageNeedsReloading`
    func beforeContentUpdate()
    
    /// This event is triggered after content update occurs. If you need to update UITableView and trigger these delegate callbacks, call `storageNeedsReloading` method on storage class.
    /// - SeeAlso: `storageNeedsReloading`
    func afterContentUpdate()
}

public extension DTTableViewContentUpdatable where Self : DTTableViewManageable {
    func beforeContentUpdate() {}
    func afterContentUpdate() {}
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
    
    case heightForHeaderInSection = "tableView:heightForHeaderInSection:"
    case estimatedHeightForHeaderInSection = "tableView:estimatedHeightForHeaderInSection:"
    case heightForFooterInSection = "tableView:heightForFooterInSection:"
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
    private func appendReaction<T,U where T: ModelTransfer, T:UITableViewCell>(for cellClass: T.Type, signature: EventMethodSignature, closure: (T,T.ModelType, IndexPath) -> U)
    {
        let reaction = EventReaction(signature: signature.rawValue)
        reaction.makeCellReaction(block: closure)
        tableViewEventReactions.append(reaction)
    }
    
    private func appendReaction<T,U>(for modelClass: T.Type, signature: EventMethodSignature, closure: (T, IndexPath) -> U)
    {
        let reaction = EventReaction(signature: signature.rawValue)
        reaction.makeCellReaction(block: closure)
        tableViewEventReactions.append(reaction)
    }
    
    private func appendReaction<T,U where T: ModelTransfer, T: UIView>(forSupplementaryKind kind: String, supplementaryClass: T.Type, signature: EventMethodSignature, closure: (T, T.ModelType, Int) -> U) {
        let reaction = EventReaction(signature: signature.rawValue)
        reaction.makeSupplementaryReaction(forKind: kind, block: closure)
        tableViewEventReactions.append(reaction)
    }
    
    private func appendReaction<T,U>(forSupplementaryKind kind: String, modelClass: T.Type, signature: EventMethodSignature, closure: (T, Int) -> U) {
        let reaction = EventReaction(signature: signature.rawValue)
        reaction.makeSupplementaryReaction(for: kind, block: closure)
        tableViewEventReactions.append(reaction)
    }
    
    /// Define an action, that will be performed, when cell of specific type is selected(didSelectRowAtIndexPath delegate method).
    /// - Parameter cellClass: Type of UITableViewCell subclass
    /// - Parameter closure: closure to run when UITableViewCell is selected
    /// - Warning: Closure will be stored on `DTTableViewManager` instance, which can create a retain cycle, so make sure to declare weak self and any other `DTTableViewManager` property in capture lists.
    public func didSelect<T:ModelTransfer where T:UITableViewCell>(_ cellClass:  T.Type, _ closure: (T,T.ModelType, IndexPath) -> Void)
    {
        appendReaction(for: T.self, signature: .didSelectRowAtIndexPath, closure: closure)
    }
    
    public func willSelect<T:ModelTransfer where T:UITableViewCell>(_ cellClass:  T.Type, _ closure: (T,T.ModelType, IndexPath) -> IndexPath?) {
        appendReaction(for: T.self, signature: .willSelectRowAtIndexPath, closure: closure)
    }
    
    public func willDeselect<T:ModelTransfer where T:UITableViewCell>(_ cellClass:  T.Type, _ closure: (T,T.ModelType, IndexPath) -> IndexPath?) {
        appendReaction(for: T.self, signature: .willDeselectRowAtIndexPath, closure: closure)
    }
    
    public func didDeselect<T:ModelTransfer where T:UITableViewCell>(_ cellClass:  T.Type, _ closure: (T,T.ModelType, IndexPath) -> IndexPath?) {
        appendReaction(for: T.self, signature: .didDeselectRowAtIndexPath, closure: closure)
    }
    
    @available(*, unavailable, renamed:"didSelect(_:_:)")
    public func whenSelected<T:ModelTransfer where T:UITableViewCell>(_ cellClass:  T.Type, _ closure: (T,T.ModelType, IndexPath) -> Void)
    {
        didSelect(cellClass,closure)
    }
    
    /// Define additional configuration action, that will happen, when UITableViewCell subclass is requested by UITableView. This action will be performed *after* cell is created and updateWithModel: method is called.
    /// - Parameter cellClass: Type of UITableViewCell subclass
    /// - Parameter closure: closure to run when UITableViewCell is being configured
    /// - Warning: Closure will be stored on `DTTableViewManager` instance, which can create a retain cycle, so make sure to declare weak self and any other `DTTableViewManager` property in capture lists.
    public func configureCell<T:ModelTransfer where T: UITableViewCell>(_ cellClass:T.Type, _ closure: (T, T.ModelType, IndexPath) -> Void)
    {
        appendReaction(for: T.self, signature: .configureCell, closure: closure)
    }
    
    /// Define additional configuration action, that will happen, when UIView header subclass is requested by UITableView. This action will be performed *after* header is created and updateWithModel: method is called.
    /// - Parameter headerClass: Type of UIView or UITableHeaderFooterView subclass
    /// - Parameter closure: closure to run when UITableHeaderFooterView is being configured
    /// - Warning: Closure will be stored on `DTTableViewManager` instance, which can create a retain cycle, so make sure to declare weak self and any other `DTTableViewManager` property in capture lists.
    public func configureHeader<T:ModelTransfer where T: UIView>(_ headerClass: T.Type, _ closure: (T, T.ModelType, Int) -> Void)
    {
        appendReaction(forSupplementaryKind: DTTableViewElementSectionHeader, supplementaryClass: T.self, signature: EventMethodSignature.configureHeader, closure: closure)
    }
    
    /// Define additional configuration action, that will happen, when UIView footer subclass is requested by UITableView. This action will be performed *after* footer is created and updateWithModel: method is called.
    /// - Parameter footerClass: Type of UIView or UITableReusableView subclass
    /// - Parameter closure: closure to run when UITableReusableView is being configured
    /// - Warning: Closure will be stored on `DTTableViewManager` instance, which can create a retain cycle, so make sure to declare weak self and any other `DTTableViewManager` property in capture lists.
    public func configureFooter<T:ModelTransfer where T: UIView>(_ footerClass: T.Type, _ closure: (T, T.ModelType, Int) -> Void)
    {
        appendReaction(forSupplementaryKind: DTTableViewElementSectionFooter, supplementaryClass: T.self, signature: EventMethodSignature.configureFooter, closure: closure)
    }
    
    public func heightForCell<T>(withItemType: T.Type, closure: (T, IndexPath) -> CGFloat) {
        appendReaction(for: T.self, signature: EventMethodSignature.heightForRowAtIndexPath, closure: closure)
    }
    
    public func estimatedHeightForCell<T>(withItemType: T.Type, closure: (T, IndexPath) -> CGFloat) {
        appendReaction(for: T.self, signature: EventMethodSignature.estimatedHeightForRowAtIndexPath, closure: closure)
    }
    
    public func indentationLevel<T>(forItemType: T.Type, closure: (T, IndexPath) -> CGFloat) {
        appendReaction(for: T.self, signature: EventMethodSignature.indentationLevelForRowAtIndexPath, closure: closure)
    }
    
    public func willDisplay<T:ModelTransfer where T: UITableViewCell>(_ cellClass:T.Type, _ closure: (T, T.ModelType, IndexPath) -> Void)
    {
        appendReaction(for: T.self, signature: EventMethodSignature.willDisplayCellForRowAtIndexPath, closure: closure)
    }
    
    public func editActions<T:ModelTransfer where T: UITableViewCell>(for cellClass: T.Type, _ closure: (T, T.ModelType, IndexPath) -> [UITableViewRowAction]?) {
        appendReaction(for: T.self, signature: EventMethodSignature.editActionsForRowAtIndexPath, closure: closure)
    }
    
    public func accessoryButtonTapped<T:ModelTransfer where T: UITableViewCell>(in cellClass: T.Type, _ closure: (T, T.ModelType, IndexPath) -> Void) {
        appendReaction(for: T.self, signature: EventMethodSignature.accessoryButtonTappedForRowAtIndexPath, closure: closure)
    }
    
    public func commitEditingStyle<T:ModelTransfer where T: UITableViewCell>(for cellClass: T.Type, _ closure: (UITableViewCellEditingStyle, T, T.ModelType, IndexPath) -> Void) {
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
    
    public func canEdit<T:ModelTransfer where T: UITableViewCell>(_ cellClass: T.Type, _ closure: (T, T.ModelType, IndexPath) -> Bool) {
        appendReaction(for: T.self, signature: EventMethodSignature.canEditRowAtIndexPath, closure: closure)
    }
    
    public func canMove<T:ModelTransfer where T: UITableViewCell>(_ cellClass: T.Type, _ closure: (T, T.ModelType, IndexPath) -> Bool) {
        appendReaction(for: T.self, signature: EventMethodSignature.canMoveRowAtIndexPath, closure: closure)
    }
    
    public func heightForHeader<T>(withItemType type: T.Type, _ closure: (T, Int) -> CGFloat) {
        appendReaction(forSupplementaryKind: DTTableViewElementSectionHeader, modelClass: T.self, signature: EventMethodSignature.heightForHeaderInSection, closure: closure)
    }
    
    public func estimatedHeightForHeader<T>(withItemType type: T.Type, _ closure: (T, Int) -> CGFloat) {
        appendReaction(forSupplementaryKind: DTTableViewElementSectionHeader, modelClass: T.self, signature: EventMethodSignature.estimatedHeightForHeaderInSection, closure: closure)
    }
    
    public func heightForFooter<T>(withItemType type: T.Type, _ closure: (T, Int) -> CGFloat) {
        appendReaction(forSupplementaryKind: DTTableViewElementSectionFooter, modelClass: T.self, signature: EventMethodSignature.heightForFooterInSection, closure: closure)
    }
    
    public func estimatedHeightForFooter<T>(withItemType type: T.Type, _ closure: (T, Int) -> CGFloat) {
        appendReaction(forSupplementaryKind: DTTableViewElementSectionFooter, modelClass: T.self, signature: EventMethodSignature.estimatedHeightForFooterInSection, closure: closure)
    }
    
    public func willDisplayHeaderView<T:ModelTransfer where T: UIView>(_ headerClass: T.Type, _ closure: (T, T.ModelType, Int) -> Void)
    {
        appendReaction(forSupplementaryKind: DTTableViewElementSectionHeader, supplementaryClass: T.self, signature: EventMethodSignature.willDisplayHeaderForSection, closure: closure)
    }
    
    public func willDisplayFooterView<T:ModelTransfer where T: UIView>(_ footerClass: T.Type, _ closure: (T, T.ModelType, Int) -> Void)
    {
        appendReaction(forSupplementaryKind: DTTableViewElementSectionFooter, supplementaryClass: T.self, signature: EventMethodSignature.willDisplayFooterForSection, closure: closure)
    }
    
    public func willBeginEditing<T:ModelTransfer where T: UITableViewCell>(_ cellClass:T.Type, _ closure: (T, T.ModelType, IndexPath) -> Void)
    {
        appendReaction(for: T.self, signature: EventMethodSignature.willBeginEditingRowAtIndexPath, closure: closure)
    }
    
    public func didEndEditing<T:ModelTransfer where T: UITableViewCell>(_ cellClass:T.Type, _ closure: (T, T.ModelType, IndexPath) -> Void)
    {
        appendReaction(for: T.self, signature: EventMethodSignature.didEndEditingRowAtIndexPath, closure: closure)
    }
    
    public func editingStyle<T:ModelTransfer where T: UITableViewCell>(for cellClass:T.Type, _ closure: (T, T.ModelType, IndexPath) -> UITableViewCellEditingStyle)
    {
        appendReaction(for: T.self, signature: EventMethodSignature.editingStyleForRowAtIndexPath, closure: closure)
    }
    
    public func titleForDeleteConfirmationButton<T:ModelTransfer where T: UITableViewCell>(in cellClass:T.Type, _ closure: (T, T.ModelType, IndexPath) -> String?)
    {
        appendReaction(for: T.self, signature: EventMethodSignature.titleForDeleteButtonForRowAtIndexPath, closure: closure)
    }
    
    public func shouldIndentWhileEditing<T:ModelTransfer where T: UITableViewCell>(_ cellClass:T.Type, _ closure: (T, T.ModelType, IndexPath) -> Bool)
    {
        appendReaction(for: T.self, signature: EventMethodSignature.shouldIndentWhileEditingRowAtIndexPath, closure: closure)
    }
    
    public func didEndDisplaying<T:ModelTransfer where T: UITableViewCell>(_ cellClass:T.Type, _ closure: (T, T.ModelType, IndexPath) -> Void) {
        appendReaction(for: T.self, signature: EventMethodSignature.didEndDisplayingCellForRowAtIndexPath, closure: closure)
    }
    
    public func didEndDisplayingHeaderView<T:ModelTransfer where T: UIView>(_ headerClass: T.Type, _ closure: (T, T.ModelType, Int) -> Void)
    {
        appendReaction(forSupplementaryKind: DTTableViewElementSectionHeader, supplementaryClass: T.self, signature: EventMethodSignature.didEndDisplayingHeaderViewForSection, closure: closure)
    }
    
    public func didEndDisplayingFooterView<T:ModelTransfer where T: UIView>(_ footerClass: T.Type, _ closure: (T, T.ModelType, Int) -> Void)
    {
        appendReaction(forSupplementaryKind: DTTableViewElementSectionFooter, supplementaryClass: T.self, signature: EventMethodSignature.didEndDisplayingFooterViewForSection, closure: closure)
    }
    
    public func shouldShowMenu<T:ModelTransfer where T: UITableViewCell>(for cellClass:T.Type, _ closure: (T, T.ModelType, IndexPath) -> Bool)
    {
        appendReaction(for: T.self, signature: EventMethodSignature.shouldShowMenuForRowAtIndexPath, closure: closure)
    }
    
    public func canPerformAction<T:ModelTransfer where T: UITableViewCell>(for cellClass: T.Type, _ closure: (Selector, AnyObject?, T, T.ModelType, IndexPath) -> Bool) {
        let reaction = FiveArgumentsEventReaction(signature: EventMethodSignature.canPerformActionForRowAtIndexPath.rawValue)
        reaction.modelTypeCheckingBlock = { $0 is T.ModelType }
        reaction.reaction5Arguments = { selector, sender, cell, model, indexPath -> Any in
            guard let selector = selector as? Selector,
                let cell = cell as? T,
                let model = model as? T.ModelType,
                let indexPath = indexPath as? IndexPath
                else { return false }
            return closure(selector, sender as? AnyObject, cell, model, indexPath)
        }
        tableViewEventReactions.append(reaction)
    }
    
    public func performAction<T:ModelTransfer where T: UITableViewCell>(for cellClass: T.Type, _ closure: (Selector, AnyObject?, T, T.ModelType, IndexPath) -> Void) {
        let reaction = FiveArgumentsEventReaction(signature: EventMethodSignature.performActionForRowAtIndexPath.rawValue)
        reaction.modelTypeCheckingBlock = { $0 is T.ModelType }
        reaction.reaction5Arguments = { selector, sender, cell, model, indexPath  in
            guard let selector = selector as? Selector,
                let cell = cell as? T,
                let model = model as? T.ModelType,
                let indexPath = indexPath as? IndexPath
                else { return false }
            return closure(selector, sender as? AnyObject, cell, model, indexPath)
        }
        tableViewEventReactions.append(reaction)
    }
    
    public func shouldHighlight<T:ModelTransfer where T: UITableViewCell>(_ cellClass:T.Type, _ closure: (T, T.ModelType, IndexPath) -> Bool)
    {
        appendReaction(for: T.self, signature: EventMethodSignature.shouldHighlightRowAtIndexPath, closure: closure)
    }
    
    public func didHighlight<T:ModelTransfer where T: UITableViewCell>(_ cellClass:T.Type, _ closure: (T, T.ModelType, IndexPath) -> Void)
    {
        appendReaction(for: T.self, signature: EventMethodSignature.didHighlightRowAtIndexPath, closure: closure)
    }
    
    public func didUnhighlight<T:ModelTransfer where T: UITableViewCell>(_ cellClass:T.Type, _ closure: (T, T.ModelType, IndexPath) -> Void)
    {
        appendReaction(for: T.self, signature: EventMethodSignature.didUnhighlightRowAtIndexPath, closure: closure)
    }
    
    @available(iOS 9.0, tvOS 9.0, *)
    public func canFocus<T:ModelTransfer where T: UITableViewCell>(_ cellClass:T.Type, _ closure: (T, T.ModelType, IndexPath) -> Bool)
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
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.storage.sections[section].numberOfItems
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return self.storage.sections.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let model = self.storage.itemAtIndexPath(indexPath) else {
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
    
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if configuration.sectionHeaderStyle == .view { return nil }
        
        return self.headerModelForSectionIndex(section) as? String
    }
    
    public func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if configuration.sectionFooterStyle == .view { return nil }
        
        return self.footerModelForSectionIndex(section) as? String
    }
    
    /// `DTTableViewManager` automatically moves data models from source indexPath to destination indexPath, there's no need to implement this method on UITableViewDataSource
    public func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
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
    
    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        defer { (delegate as? UITableViewDataSource)?.tableView?(tableView, commit: editingStyle, forRowAt: indexPath) }
        guard let model = RuntimeHelper.recursivelyUnwrapAnyValue(storage.itemAtIndexPath(indexPath)),
            let cell = tableView.cellForRow(at: indexPath)
            else { return }
        if let reaction = tableViewEventReactions.reactionOfType(.cell, signature: EventMethodSignature.commitEditingStyleForRowAtIndexPath.rawValue, forModel: model) as? FourArgumentsEventReaction {
            _ = reaction.performWithArguments(arguments: (editingStyle,cell,model,indexPath))
        }
    }
    
    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if let canEdit = performCellReaction(signature: .canEditRowAtIndexPath, location: indexPath, provideCell: true) as? Bool {
            return canEdit
        }
        return (delegate as? UITableViewDataSource)?.tableView?(tableView, canEditRowAt: indexPath) ?? false
    }
    
    public func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        if let canMove = performCellReaction(signature: .canMoveRowAtIndexPath, location: indexPath, provideCell: true) as? Bool {
            return canMove
        }
        return (delegate as? UITableViewDataSource)?.tableView?(tableView, canMoveRowAt: indexPath) ?? false
    }
}

// MARK: - UITableViewDelegate
extension DTTableViewManager: UITableViewDelegate
{
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
    {
        defer { (delegate as? UITableViewDelegate)?.tableView?(tableView, willDisplay: cell, forRowAt: indexPath) }
        guard let model = storage.itemAtIndexPath(indexPath) else { return }
        _ = tableViewEventReactions.performReaction(ofType: .cell, signature: EventMethodSignature.willDisplayCellForRowAtIndexPath.rawValue, view: cell, model: model, location: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        defer { (delegate as? UITableViewDelegate)?.tableView?(tableView, willDisplayHeaderView: view, forSection: section) }
        guard let model = (storage as? HeaderFooterStorageProtocol)?.headerModelForSectionIndex(section) else { return }
        _ = tableViewEventReactions.performReaction(ofType: .supplementary(kind: DTTableViewElementSectionHeader), signature: EventMethodSignature.willDisplayHeaderForSection.rawValue, view: view, model: model, location: section)
    }
    
    public func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        defer { (delegate as? UITableViewDelegate)?.tableView?(tableView, willDisplayFooterView: view, forSection: section) }
        guard let model = (storage as? HeaderFooterStorageProtocol)?.footerModelForSectionIndex(section) else { return }
        _ = tableViewEventReactions.performReaction(ofType: .supplementary(kind: DTTableViewElementSectionFooter), signature: EventMethodSignature.willDisplayFooterForSection.rawValue, view: view, model: model, location: section)
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
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
                                                            view: createdView, model: model, location: section)
            }
            return view
        }
        return nil
    }
    
    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
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
                                                         view: createdView, model: model, location: section)
            }
            return view
        }
        return nil
    }
    
    /// You can implement this method on a `DTTableViewManageable` delegate, and then it will be called to determine header height
    /// - Note: In most cases, it's enough to set sectionHeaderHeight property on UITableView and overriding this method is not actually needed
    /// - Note: If you override this method on a delegate, displayHeaderOnEmptySection property is ignored
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if let height = performHeaderReaction(signature: .heightForHeaderInSection, location: section, provideView: false) as? CGFloat {
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
    
    public func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        if let height = performHeaderReaction(signature: .estimatedHeightForHeaderInSection, location: section, provideView: false) as? CGFloat {
            return height
        }
        return (delegate as? UITableViewDelegate)?.tableView?(tableView, estimatedHeightForHeaderInSection: section) ?? tableView.estimatedSectionHeaderHeight
    }
    
    /// You can implement this method on a `DTTableViewManageable` delegate, and then it will be called to determine footer height
    /// - Note: In most cases, it's enough to set sectionFooterHeight property on UITableView and overriding this method is not actually needed
    /// - Note: If you override this method on a delegate, displayFooterOnEmptySection property is ignored
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if let height = performFooterReaction(signature: .heightForFooterInSection, location: section, provideView: false) as? CGFloat {
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
    
    public func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        if let height = performFooterReaction(signature: .estimatedHeightForFooterInSection, location: section, provideView: false) as? CGFloat {
            return height
        }
        return (delegate as? UITableViewDelegate)?.tableView?(tableView, estimatedHeightForFooterInSection: section) ?? tableView.estimatedSectionFooterHeight
    }
    
    public func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if let result = performCellReaction(signature: .willSelectRowAtIndexPath, location: indexPath, provideCell: true) as? IndexPath {
            return result
        }
        return (delegate as? UITableViewDelegate)?.tableView?(tableView, willSelectRowAt: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath? {
        if let result = performCellReaction(signature: .willDeselectRowAtIndexPath, location: indexPath, provideCell: true) as? IndexPath {
            return result
        }
        return (delegate as? UITableViewDelegate)?.tableView?(tableView, willDeselectRowAt: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        _ = performCellReaction(signature: .didSelectRowAtIndexPath, location: indexPath, provideCell: true)
        (self.delegate as? UITableViewDelegate)?.tableView?(tableView, didSelectRowAt: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        _ = performCellReaction(signature: .didDeselectRowAtIndexPath, location: indexPath, provideCell: true)
        (self.delegate as? UITableViewDelegate)?.tableView?(tableView, didDeselectRowAt: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let height = performCellReaction(signature: .heightForRowAtIndexPath, location: indexPath, provideCell: false) as? CGFloat {
            return height
        }
        return (delegate as? UITableViewDelegate)?.tableView?(tableView, heightForRowAt: indexPath) ?? tableView.rowHeight
    }
    
    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if let height = performCellReaction(signature: .estimatedHeightForRowAtIndexPath, location: indexPath, provideCell: false) as? CGFloat {
            return height
        }
        return (delegate as? UITableViewDelegate)?.tableView?(tableView, estimatedHeightForRowAt: indexPath) ?? tableView.estimatedRowHeight
    }
    
    public func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
        if let level = performCellReaction(signature: .indentationLevelForRowAtIndexPath, location: indexPath, provideCell: false) as? Int {
            return level
        }
        return (delegate as? UITableViewDelegate)?.tableView?(tableView, indentationLevelForRowAt: indexPath) ?? 0
    }
    
    public func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        _ = performCellReaction(signature: .accessoryButtonTappedForRowAtIndexPath, location: indexPath, provideCell: true)
        (delegate as? UITableViewDelegate)?.tableView?(tableView, accessoryButtonTappedForRowWith: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if let actions = performCellReaction(signature: .editActionsForRowAtIndexPath, location: indexPath, provideCell: true) as? [UITableViewRowAction] {
            return actions
        }
        return (delegate as? UITableViewDelegate)?.tableView?(tableView, editActionsForRowAt: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        _ = performCellReaction(signature: .willBeginEditingRowAtIndexPath, location: indexPath, provideCell: true)
        (delegate as? UITableViewDelegate)?.tableView?(tableView, willBeginEditingRowAt: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        defer { (delegate as? UITableViewDelegate)?.tableView?(tableView, didEndEditingRowAt: indexPath) }
        guard let indexPath = indexPath else { return }
        _ = performCellReaction(signature: .didEndEditingRowAtIndexPath, location: indexPath, provideCell: true)
    }
    
    public func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        if let editingStyle = performCellReaction(signature: .editingStyleForRowAtIndexPath, location: indexPath, provideCell: true) as? UITableViewCellEditingStyle {
            return editingStyle
        }
        return (delegate as? UITableViewDelegate)?.tableView?(tableView, editingStyleForRowAt: indexPath) ?? .none
    }
    
    public func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        if let title = performCellReaction(signature: .titleForDeleteButtonForRowAtIndexPath, location: indexPath, provideCell: true) as? String {
            return title
        }
        return (delegate as? UITableViewDelegate)?.tableView?(tableView, titleForDeleteConfirmationButtonForRowAt: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        if let should = performCellReaction(signature: .shouldIndentWhileEditingRowAtIndexPath, location: indexPath, provideCell: true) as? Bool {
            return should
        }
        return (delegate as? UITableViewDelegate)?.tableView?(tableView, shouldIndentWhileEditingRowAt: indexPath) ?? tableView.cellForRow(at: indexPath)?.shouldIndentWhileEditing ?? true
    }
    
    public func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        defer { (delegate as? UITableViewDelegate)?.tableView?(tableView, didEndDisplaying: cell, forRowAt: indexPath) }
        guard let model = storage.itemAtIndexPath(indexPath) else { return }
        _ = tableViewEventReactions.performReaction(ofType: .cell, signature: EventMethodSignature.didEndDisplayingCellForRowAtIndexPath.rawValue, view: cell, model: model, location: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {
        defer { (delegate as? UITableViewDelegate)?.tableView?(tableView, didEndDisplayingHeaderView: view, forSection: section) }
        guard let model = (storage as? HeaderFooterStorageProtocol)?.headerModelForSectionIndex(section) else { return }
        _ = tableViewEventReactions.performReaction(ofType: .supplementary(kind: DTTableViewElementSectionHeader), signature: EventMethodSignature.didEndDisplayingHeaderViewForSection.rawValue, view: view, model: model, location: section)
    }
    
    public func tableView(_ tableView: UITableView, didEndDisplayingFooterView view: UIView, forSection section: Int) {
        defer { (delegate as? UITableViewDelegate)?.tableView?(tableView, didEndDisplayingFooterView: view, forSection: section) }
        guard let model = (storage as? HeaderFooterStorageProtocol)?.footerModelForSectionIndex(section) else { return }
        _ = tableViewEventReactions.performReaction(ofType: .supplementary(kind: DTTableViewElementSectionFooter), signature: EventMethodSignature.didEndDisplayingFooterViewForSection.rawValue, view: view, model: model, location: section)
    }
    
    public func tableView(_ tableView: UITableView, shouldShowMenuForRowAt indexPath: IndexPath) -> Bool {
        if let should = performCellReaction(signature: .shouldShowMenuForRowAtIndexPath, location: indexPath, provideCell: true) as? Bool {
            return should
        }
        return (delegate as? UITableViewDelegate)?.tableView?(tableView, shouldShowMenuForRowAt: indexPath) ?? false
    }
    
    public func tableView(_ tableView: UITableView, canPerformAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: AnyObject?) -> Bool {
        guard let model = RuntimeHelper.recursivelyUnwrapAnyValue(storage.itemAtIndexPath(indexPath)),
            let cell = tableView.cellForRow(at: indexPath)
            else { return false }
        if let reaction = tableViewEventReactions.reactionOfType(.cell, signature: EventMethodSignature.canPerformActionForRowAtIndexPath.rawValue, forModel: model) as? FiveArgumentsEventReaction {
            return reaction.performWithArguments(arguments: (action,sender,cell,model,indexPath)) as? Bool ?? false
        }
        return (delegate as? UITableViewDelegate)?.tableView?(tableView, canPerformAction: action, forRowAt: indexPath, withSender: sender) ?? false
    }
    
    public func tableView(_ tableView: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: AnyObject?) {
        defer { (delegate as? UITableViewDelegate)?.tableView?(tableView, performAction: action, forRowAt: indexPath, withSender: sender) }
        guard let model = RuntimeHelper.recursivelyUnwrapAnyValue(storage.itemAtIndexPath(indexPath)),
            let cell = tableView.cellForRow(at: indexPath)
            else { return }
        if let reaction = tableViewEventReactions.reactionOfType(.cell, signature: EventMethodSignature.performActionForRowAtIndexPath.rawValue, forModel: model) as? FiveArgumentsEventReaction {
            _ = reaction.performWithArguments(arguments: (action,sender,cell,model,indexPath))
        }
    }
    
    public func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        if let should = performCellReaction(signature: .shouldHighlightRowAtIndexPath, location: indexPath, provideCell: true) as? Bool {
            return should
        }
        return (delegate as? UITableViewDelegate)?.tableView?(tableView, shouldHighlightRowAt: indexPath) ?? true
    }
    
    public func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        defer { (delegate as? UITableViewDelegate)?.tableView?(tableView, didHighlightRowAt: indexPath) }
        _ = performCellReaction(signature: .didHighlightRowAtIndexPath, location: indexPath, provideCell: true)
    }
    
    public func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        defer { (delegate as? UITableViewDelegate)?.tableView?(tableView, didUnhighlightRowAt: indexPath) }
        _ = performCellReaction(signature: .didUnhighlightRowAtIndexPath, location: indexPath, provideCell: true)
    }
    
    @available(iOS 9.0, tvOS 9.0, *)
    public func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool {
        if let should = performCellReaction(signature: .canFocusRowAtIndexPath, location: indexPath, provideCell: true) as? Bool {
            return should
        }
        return (delegate as? UITableViewDelegate)?.tableView?(tableView, canFocusRowAt: indexPath) ?? tableView.cellForRow(at: indexPath)?.canBecomeFocused ?? true
    }
    
    private func performCellReaction(signature: EventMethodSignature, location: IndexPath, provideCell: Bool) -> Any? {
        var cell : UITableViewCell?
        if provideCell { cell = tableView?.cellForRow(at: location) }
        guard let model = storage.itemAtIndexPath(location) else { return nil }
        return tableViewEventReactions.performReaction(ofType: .cell, signature: signature.rawValue, view: cell, model: model, location: location)
    }
    
    private func performHeaderReaction(signature: EventMethodSignature, location: Int, provideView: Bool) -> Any? {
        var view : UIView?
        if provideView {
            view = tableView?.headerView(forSection: location)
        }
        guard let model = (storage as? HeaderFooterStorageProtocol)?.headerModelForSectionIndex(location) else { return nil}
        return tableViewEventReactions.performReaction(ofType: .supplementary(kind: DTTableViewElementSectionHeader), signature: signature.rawValue, view: view, model: model, location: location)
    }
    
    private func performFooterReaction(signature: EventMethodSignature, location: Int, provideView: Bool) -> Any? {
        var view : UIView?
        if provideView {
            view = tableView?.footerView(forSection: location)
        }
        guard let model = (storage as? HeaderFooterStorageProtocol)?.footerModelForSectionIndex(location) else { return nil}
        return tableViewEventReactions.performReaction(ofType: .supplementary(kind: DTTableViewElementSectionFooter), signature: signature.rawValue, view: view, model: model, location: location)
    }
}

// MARK: - StorageUpdating
extension DTTableViewManager : StorageUpdating
{
    public func storageDidPerformUpdate(_ update : StorageUpdate)
    {
        self.controllerWillUpdateContent()

        tableView?.beginUpdates()
        
        if update.deletedRowIndexPaths.count > 0 { tableView?.deleteRows(at: Array(update.deletedRowIndexPaths), with: configuration.deleteRowAnimation) }
        if update.insertedRowIndexPaths.count > 0 { tableView?.insertRows(at: Array(update.insertedRowIndexPaths), with: configuration.insertRowAnimation) }
        if update.updatedRowIndexPaths.count > 0 { tableView?.reloadRows(at: Array(update.updatedRowIndexPaths), with: configuration.reloadRowAnimation) }
        if update.movedRowIndexPaths.count > 0 {
            for moveUpdate in update.movedRowIndexPaths {
                if let from = moveUpdate.first, let to = moveUpdate.last {
                    tableView?.moveRow(at: from, to: to)
                }
            }
        }
        
        if update.deletedSectionIndexes.count > 0 { tableView?.deleteSections(update.deletedSectionIndexes.makeNSIndexSet(), with: configuration.deleteSectionAnimation) }
        if update.insertedSectionIndexes.count > 0 { tableView?.insertSections(update.insertedSectionIndexes.makeNSIndexSet(), with: configuration.insertSectionAnimation) }
        if update.updatedSectionIndexes.count > 0 { tableView?.reloadSections(update.updatedSectionIndexes.makeNSIndexSet(), with: configuration.reloadSectionAnimation)}
        if update.movedSectionIndexes.count > 0 {
            for moveUpdate in update.movedSectionIndexes {
                if let from = moveUpdate.first, let to = moveUpdate.last {
                    tableView?.moveSection(from, toSection: to)
                }
            }
        }
        
        tableView?.endUpdates()
        
        self.controllerDidUpdateContent()
    }
    
    /// Call this method, if you want UITableView to be reloaded, and beforeContentUpdate: and afterContentUpdate: closures to be called.
    public func storageNeedsReloading()
    {
        self.controllerWillUpdateContent()
        tableView?.reloadData()
        self.controllerDidUpdateContent()
    }
    
    private func controllerWillUpdateContent()
    {
        (self.delegate as? DTTableViewContentUpdatable)?.beforeContentUpdate()
    }
    
    private func controllerDidUpdateContent()
    {
        (self.delegate as? DTTableViewContentUpdatable)?.afterContentUpdate()
    }
}
