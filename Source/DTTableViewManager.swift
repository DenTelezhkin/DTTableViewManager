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
    /// - SeeAlso: `TableViewReaction`.
    private var tableViewEventReactions = [EventReaction]()
    
    /// Error handler ot be executed when critical error happens with `TableViewFactory`.
    /// This can be useful to provide more debug information for crash logs, since preconditionFailure Swift method provides little to zero insight about what happened and when.
    /// This closure will be called prior to calling preconditionFailure in `handleTableViewFactoryError` method.
    public var viewFactoryErrorHandler : ((DTTableViewFactoryError) -> Void)?
    
    /// Implicitly unwrap storage property to `MemoryStorage`.
    /// - Warning: if storage is not MemoryStorage, will throw an exception.
    public var memoryStorage : MemoryStorage!
    {
        precondition(storage is MemoryStorage, "DTTableViewManager memoryStorage method should be called only if you are using MemoryStorage")
        
        return storage as! MemoryStorage
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
            if let eventSelector = EventMethodSignatures(rawValue: String(aSelector)) {
                return tableViewEventReactions.contains({ $0.methodSignature == eventSelector.rawValue })
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

private enum EventMethodSignatures: String {
    case tableViewDidSelectRowAtIndexPath = "tableView:didSelectRowAtIndexPath:"
    case tableViewConfigureCell = "tableViewConfigureCell_imaginarySelector"
    case tableViewConfigureHeader = "tableViewConfigureHeader_imaginarySelector"
    case tableViewConfigureFooter = "tableViewConfigureFooter_imaginarySelector"
    
    var eventSignatures: [EventMethodSignatures] {
        return [
            .tableViewDidSelectRowAtIndexPath,
            .tableViewConfigureCell,
            .tableViewConfigureHeader,
            .tableViewConfigureFooter
        ]
    }
}

// MARK: - Table view reactions
extension DTTableViewManager
{
    /// Define an action, that will be performed, when cell of specific type is selected.
    /// - Parameter cellClass: Type of UITableViewCell subclass
    /// - Parameter closure: closure to run when UITableViewCell is selected
    /// - Warning: Closure will be stored on `DTTableViewManager` instance, which can create a retain cycle, so make sure to declare weak self and any other `DTTableViewManager` property in capture lists.
    public func didSelect<T:ModelTransfer where T:UITableViewCell>(_ cellClass:  T.Type, _ closure: (T,T.ModelType, IndexPath) -> Void)
    {
        let reaction = EventReaction(signature: EventMethodSignatures.tableViewDidSelectRowAtIndexPath.rawValue, modelClass: T.ModelType.self)
        reaction.makeCellReaction(block: closure)
        tableViewEventReactions.append(reaction)
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
        let reaction = EventReaction(signature: EventMethodSignatures.tableViewConfigureCell.rawValue, modelClass: T.ModelType.self)
        reaction.makeCellReaction(block: closure)
        tableViewEventReactions.append(reaction)
    }
    
    /// Define additional configuration action, that will happen, when UIView header subclass is requested by UITableView. This action will be performed *after* header is created and updateWithModel: method is called.
    /// - Parameter headerClass: Type of UIView or UITableHeaderFooterView subclass
    /// - Parameter closure: closure to run when UITableHeaderFooterView is being configured
    /// - Warning: Closure will be stored on `DTTableViewManager` instance, which can create a retain cycle, so make sure to declare weak self and any other `DTTableViewManager` property in capture lists.
    public func configureHeader<T:ModelTransfer where T: UIView>(_ headerClass: T.Type, _ closure: (T, T.ModelType, Int) -> Void)
    {
        let reaction = EventReaction(signature: EventMethodSignatures.tableViewConfigureHeader.rawValue, modelClass: T.ModelType.self)
        reaction.makeSupplementaryReaction(forKind: DTTableViewElementSectionHeader, block: closure)
        tableViewEventReactions.append(reaction)
    }
    
    /// Define additional configuration action, that will happen, when UIView footer subclass is requested by UITableView. This action will be performed *after* footer is created and updateWithModel: method is called.
    /// - Parameter footerClass: Type of UIView or UITableReusableView subclass
    /// - Parameter closure: closure to run when UITableReusableView is being configured
    /// - Warning: Closure will be stored on `DTTableViewManager` instance, which can create a retain cycle, so make sure to declare weak self and any other `DTTableViewManager` property in capture lists.
    public func configureFooter<T:ModelTransfer where T: UIView>(_ footerClass: T.Type, _ closure: (T, T.ModelType, Int) -> Void)
    {
        let reaction = EventReaction(signature: EventMethodSignatures.tableViewConfigureFooter.rawValue, modelClass: T.ModelType.self)
        reaction.makeSupplementaryReaction(forKind: DTTableViewElementSectionFooter,block: closure)
        tableViewEventReactions.append(reaction)
    }
}

// MARK: - UITableViewDatasource
extension DTTableViewManager: UITableViewDataSource
{
    func handleTableViewFactoryError(_ error: DTTableViewFactoryError) {
        if let handler = viewFactoryErrorHandler {
            handler(error)
        } else {
            print(error.description)
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
        let model = self.storage.itemAtIndexPath(indexPath)!
        
        let cell : UITableViewCell
        do {
            cell = try self.viewFactory.cellForModel(model, atIndexPath: indexPath)
        } catch let error as DTTableViewFactoryError {
            handleTableViewFactoryError(error)
            cell = UITableViewCell()
        } catch {
            cell = UITableViewCell()
        }
        
        _ = tableViewEventReactions.performReaction(ofType: .cell, signature: EventMethodSignatures.tableViewConfigureCell.rawValue, view: cell, model: model, location: indexPath)
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
}

// MARK: - UITableViewDelegate
extension DTTableViewManager: UITableViewDelegate
{
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
    {
        (delegate as? UITableViewDelegate)?.tableView?(tableView, willDisplay: cell, forRowAt: indexPath)
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
                                                            signature: EventMethodSignatures.tableViewConfigureHeader.rawValue,
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
                                                         signature: EventMethodSignatures.tableViewConfigureFooter.rawValue,
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
        if let height = (self.delegate as? UITableViewDelegate)?.tableView?(tableView, heightForHeaderInSection: section)
        {
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
    
    /// You can implement this method on a `DTTableViewManageable` delegate, and then it will be called to determine footer height
    /// - Note: In most cases, it's enough to set sectionFooterHeight property on UITableView and overriding this method is not actually needed
    /// - Note: If you override this method on a delegate, displayFooterOnEmptySection property is ignored
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if let height = (self.delegate as? UITableViewDelegate)?.tableView?(tableView, heightForFooterInSection: section)
        {
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
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        defer { (self.delegate as? UITableViewDelegate)?.tableView?(tableView, didSelectRowAt: indexPath)}
        guard let cell = tableView.cellForRow(at: indexPath),
                let model = storage.itemAtIndexPath(indexPath)
        else { return }
        
        _ = tableViewEventReactions.performReaction(ofType: .cell,
                                                    signature: EventMethodSignatures.tableViewDidSelectRowAtIndexPath.rawValue,
                                                    view: cell, model: model, location: indexPath)
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
