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

/// Data binding behaviour for calling `ModelTransfer` `updateWithModel(_:)` method.
public enum DataBindingBehaviour
{
    /// `updateWithModel(_:)` will be called in `tableView(_:cellForRowAtIndexPath:)` method.
    case Immediately
    
    /// `updateWithModel(_:)` will be called in `tableView(_:willDisplayCell:forRowAtIndexPath:)` method.
    case BeforeCellIsDisplayed
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

    ///  Factory for creating cells and views for UITableView
    lazy var viewFactory: TableViewFactory = {
        precondition(self.tableView != nil, "Please call manager.startManagingWithDelegate(self) before calling any other DTTableViewManager methods")
        return TableViewFactory(tableView: self.tableView!)
    }()
    
    /// Bundle to search your xib's in. This can sometimes be useful for unit-testing. Defaults to NSBundle.mainBundle()
    public var viewBundle = NSBundle.mainBundle()
    {
        didSet {
            viewFactory.bundle = viewBundle
        }
    }
    
    /// Property representing when data binding is performed. Immediately - in `tableView(_:cellForRowAtIndexPath:)` method. BeforeCellIsDisplayed - in `tableView(_:willDisplayCell:forRowAtIndexPath:)` method.
    /// - Note: Changing value of this property may improve perfomance for complex table view cells.
    public var dataBindingBehaviour = DataBindingBehaviour.Immediately {
        didSet {
            viewFactory.shouldPerformDataBindingForCells = dataBindingBehaviour == .Immediately
        }
    }
    
    /// Stores all configuration options for `DTTableViewManager`.
    /// - SeeAlso: `TableViewConfiguration`.
    public var configuration = TableViewConfiguration()
    
    /// Array of reactions for `DTTableViewManager`
    /// - SeeAlso: `TableViewReaction`.
    private var tableViewReactions = [UIReaction]()
    
    /// Error handler ot be executed when critical error happens with `TableViewFactory`.
    /// This can be useful to provide more debug information for crash logs, since preconditionFailure Swift method provides little to zero insight about what happened and when.
    /// This closure will be called prior to calling preconditionFailure in `handleTableViewFactoryError` method.
    public var viewFactoryErrorHandler : (DTTableViewFactoryError -> Void)?
    
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
    public func startManagingWithDelegate(delegate : DTTableViewManageable)
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
    public func itemForVisibleCell<T:ModelTransfer where T:UITableViewCell>(cell:T?) -> T.ModelType?
    {
        guard cell != nil else {  return nil }
        
        if let indexPath = tableView?.indexPathForCell(cell!) {
            return storage.itemAtIndexPath(indexPath) as? T.ModelType
        }
        return nil
    }
    
    /// Retrieve model of specific type at index path.
    /// - Parameter cell: UITableViewCell type
    /// - Parameter indexPath: NSIndexPath of the data model
    /// - Returns: data model that belongs to this index path.
    /// - Note: Method does not require cell to be visible, however it requires that storage really contains object of `ModelType` at specified index path, otherwise it will return nil.
    public func itemForCellClass<T:ModelTransfer where T:UITableViewCell>(cellClass: T.Type, atIndexPath indexPath: NSIndexPath) -> T.ModelType?
    {
        return self.storage.itemForCellClass(T.self, atIndexPath: indexPath)
    }
    
    /// Retrieve model of specific type for section index.
    /// - Parameter headerView: UIView type
    /// - Parameter indexPath: NSIndexPath of the view
    /// - Returns: data model that belongs to this view
    /// - Note: Method does not require header to be visible, however it requires that storage really contains object of `ModelType` at specified section index, and storage to comply to `HeaderFooterStorageProtocol`, otherwise it will return nil.
    public func itemForHeaderClass<T:ModelTransfer where T:UIView>(headerClass: T.Type, atSectionIndex sectionIndex: Int) -> T.ModelType?
    {
        return self.storage.itemForHeaderClass(T.self, atSectionIndex: sectionIndex)
    }
    
    /// Retrieve model of specific type for section index.
    /// - Parameter footerView: UIView type
    /// - Parameter indexPath: NSIndexPath of the view
    /// - Returns: data model that belongs to this view
    /// - Note: Method does not require footer to be visible, however it requires that storage really contains object of `ModelType` at specified section index, and storage to comply to `HeaderFooterStorageProtocol`, otherwise it will return nil.
    public func itemForFooterClass<T:ModelTransfer where T:UIView>(footerClass: T.Type, atSectionIndex sectionIndex: Int) -> T.ModelType?
    {
        return self.storage.itemForFooterClass(T.self, atSectionIndex: sectionIndex)
    }
    
    /// Getter for header model at section index
    /// - Parameter index: index of section
    /// - Returns: header model
    private func headerModelForSectionIndex(index: Int) -> Any?
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
    private func footerModelForSectionIndex(index: Int) -> Any?
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
    public override func forwardingTargetForSelector(aSelector: Selector) -> AnyObject? {
        return delegate
    }
    
    /// Any `UITableViewDatasource` and `UITableViewDelegate` method, that is not implemented by `DTTableViewManager` will be redirected to delegate, if it implements it.
    /// - Parameter aSelector: selector to respond to
    /// - Returns: whether delegate will respond to selector
    public override func respondsToSelector(aSelector: Selector) -> Bool {
        if self.delegate?.respondsToSelector(aSelector) ?? false {
            return true
        }
        return super.respondsToSelector(aSelector)
    }
}

// MARK: - View registration
extension DTTableViewManager
{
    /// Register mapping from model class to custom cell class. Method will automatically check for nib with the same name as `cellClass`. If it exists - nib will be registered instead of class.
    /// - Note: Model type is automatically gathered from `ModelTransfer`.`ModelType` associated type.
    /// - Parameter cellClass: Type of UITableViewCell subclass, that is being registered for using by `DTTableViewManager`
    public func registerCellClass<T:ModelTransfer where T: UITableViewCell>(cellClass:T.Type)
    {
        self.viewFactory.registerCellClass(cellClass)
    }
    
    /// This method combines registerCellClass and whenSelected: methods together.
    /// - Note: Model type is automatically gathered from `ModelTransfer`.`ModelType` associated type.
    /// - Parameter cellClass: Type of UITableViewCell subclass, that is being registered for using by `DTTableViewManager`
    /// - Parameter selectionClosure: closure to run when UITableViewCell is selected
    /// - Note: selectionClosure will be stored on `DTTableViewManager` instance, which can create a retain cycle, so make sure to declare weak self and any other `DTTableViewManager` property in capture lists.
    /// - SeeAlso: `registerCellClass`, `whenSelected` methods
    public func registerCellClass<T:ModelTransfer where T:UITableViewCell>(cellClass: T.Type,
        whenSelected selectionClosure: (T,T.ModelType, NSIndexPath) -> Void)
    {
        self.viewFactory.registerCellClass(cellClass)
        self.whenSelected(cellClass, selectionClosure)
    }

    /// Register mapping from model class to custom cell class using specific nib file.
    /// - Note: Model type is automatically gathered from `ModelTransfer`.`ModelType` associated type.
    /// - Parameter nibName: Name of xib file to use
    /// - Parameter cellClass: Type of UITableViewCell subclass, that is being registered for using by `DTTableViewManager`
    public func registerNibNamed<T:ModelTransfer where T: UITableViewCell>(nibName: String, forCellClass cellClass: T.Type)
    {
        self.viewFactory.registerNibNamed(nibName, forCellClass: cellClass)
    }
    
    /// Register mapping from model class to custom header view class. Method will automatically check for nib with the same name as `headerClass`. If it exists - nib will be registered instead of class.
    /// - Note: Model type is automatically gathered from `ModelTransfer`.`ModelType` associated type.
    /// - Parameter headerClass: Type of UIView or UITableViewHeaderFooterView subclass, that is being registered for using by `DTTableViewManager`
    public func registerHeaderClass<T:ModelTransfer where T: UIView>(headerClass : T.Type)
    {
        configuration.sectionHeaderStyle = .View
        self.viewFactory.registerHeaderClass(headerClass)
    }
    
    /// Register mapping from model class to custom header view class. This method is intended to be used for headers created from code - without UI made in XIB.
    /// - Note: Model type is automatically gathered from `ModelTransfer`.`ModelType` associated type.
    /// - Parameter headerClass: UITableViewHeaderFooterView subclass, that is being registered for using by `DTTableViewManager`
    public func registerNiblessHeaderClass<T:ModelTransfer where T: UITableViewHeaderFooterView>(headerClass : T.Type)
    {
        configuration.sectionHeaderStyle = .View
        self.viewFactory.registerNiblessHeaderClass(headerClass)
    }
    
    /// Register mapping from model class to custom header view class. This method is intended to be used for footers created from code - without UI made in XIB.
    /// - Note: Model type is automatically gathered from `ModelTransfer`.`ModelType` associated type.
    /// - Parameter footerClass: UITableViewHeaderFooterView subclass, that is being registered for using by `DTTableViewManager`
    public func registerNiblessFooterClass<T:ModelTransfer where T: UITableViewHeaderFooterView>(footerClass : T.Type)
    {
        configuration.sectionFooterStyle = .View
        self.viewFactory.registerNiblessFooterClass(footerClass)
    }
    
    /// Register mapping from model class to custom footer view class. Method will automatically check for nib with the same name as `footerClass`. If it exists - nib will be registered instead of class.
    /// - Note: Model type is automatically gathered from `ModelTransfer`.`ModelType` associated type.
    /// - Parameter footerClass: Type of UIView or UITableViewHeaderFooterView subclass, that is being registered for using by `DTTableViewManager`
    public func registerFooterClass<T:ModelTransfer where T:UIView>(footerClass: T.Type)
    {
        configuration.sectionFooterStyle = .View
        viewFactory.registerFooterClass(footerClass)
    }
    
    /// Register mapping from model class to custom header class using specific nib file.
    /// - Note: Model type is automatically gathered from `ModelTransfer`.`ModelType` associated type.
    /// - Parameter nibName: Name of xib file to use
    /// - Parameter headerClass: Type of UIView or UITableReusableView subclass, that is being registered for using by `DTTableViewManager`
    public func registerNibNamed<T:ModelTransfer where T:UIView>(nibName: String, forHeaderClass headerClass: T.Type)
    {
        configuration.sectionHeaderStyle = .View
        viewFactory.registerNibNamed(nibName, forHeaderClass: headerClass)
    }
    
    /// Register mapping from model class to custom footer class using specific nib file.
    /// - Note: Model type is automatically gathered from `ModelTransfer`.`ModelType` associated type.
    /// - Parameter nibName: Name of xib file to use
    /// - Parameter footerClass: Type of UIView or UITableReusableView subclass, that is being registered for using by `DTTableViewManager`
    public func registerNibNamed<T:ModelTransfer where T:UIView>(nibName: String, forFooterClass footerClass: T.Type)
    {
        configuration.sectionFooterStyle = .View
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

// MARK: - Table view reactions
extension DTTableViewManager
{
    /// Define an action, that will be performed, when cell of specific type is selected.
    /// - Parameter methodPointer: pointer to `DTTableViewManageable` method with signature: (Cell, Model, NSIndexPath) closure to run when UITableViewCell is selected
    /// - Note: This method automatically breaks retain cycles, that can happen when passing method pointer somewhere.
    /// - Note: Model type is automatically gathered from `ModelTransfer`.`ModelType` associated type. `DTTableViewManageable` instance is used to call selection event.
    public func cellSelection<T,U where T:ModelTransfer, T: UITableViewCell, U: DTTableViewManageable>( methodPointer: U -> (T,T.ModelType, NSIndexPath) -> Void )
    {
        let reaction = UIReaction(.CellSelection, viewClass: T.self)
        reaction.reactionBlock = { [weak self, unowned reaction] in
            if  let indexPath = reaction.reactionData?.indexPath,
                let cell = self?.tableView?.cellForRowAtIndexPath(indexPath) as? T,
                let model = RuntimeHelper.recursivelyUnwrapAnyValue(self?.storage.itemAtIndexPath(indexPath)) as? T.ModelType,
                let delegate = self?.delegate as? U
            {
                methodPointer(delegate)(cell, model, indexPath)
            }
        }
        self.tableViewReactions.append(reaction)
    }
    
    /// Define an action, that will be performed, when cell of specific type is selected.
    /// - Parameter cellClass: Type of UITableViewCell subclass
    /// - Parameter closure: closure to run when UITableViewCell is selected
    /// - Warning: Closure will be stored on `DTTableViewManager` instance, which can create a retain cycle, so make sure to declare weak self and any other `DTTableViewManager` property in capture lists.
    /// - SeeAlso: 'cellSelection:'
    public func whenSelected<T:ModelTransfer where T:UITableViewCell>(cellClass:  T.Type, _ closure: (T,T.ModelType, NSIndexPath) -> Void)
    {
        let reaction = UIReaction(.CellSelection, viewClass: T.self)
        reaction.reactionBlock = { [weak self, unowned reaction] in
            if let indexPath = reaction.reactionData?.indexPath,
                let cell = self?.tableView?.cellForRowAtIndexPath(indexPath) as? T,
                let model = RuntimeHelper.recursivelyUnwrapAnyValue(self?.storage.itemAtIndexPath(indexPath)) as? T.ModelType
            {
                closure(cell, model, indexPath)
            }
        }
        self.tableViewReactions.append(reaction)
    }
    
    /// Define additional configuration action, that will happen, when UITableViewCell subclass is requested by UITableView. This action will be performed *after* cell is created and updateWithModel: method is called.
    /// - Parameter cellClass: Type of UITableViewCell subclass
    /// - Parameter closure: closure to run when UITableViewCell is being configured
    /// - Warning: Closure will be stored on `DTTableViewManager` instance, which can create a retain cycle, so make sure to declare weak self and any other `DTTableViewManager` property in capture lists.
    /// - SeeAlso: 'cellConfiguration:'
    public func configureCell<T:ModelTransfer where T: UITableViewCell>(cellClass:T.Type, _ closure: (T, T.ModelType, NSIndexPath) -> Void)
    {
        let reaction = UIReaction(.CellConfiguration, viewClass: T.self)
        reaction.reactionBlock = { [weak self, unowned reaction] in
            if let configuration = reaction.reactionData,
                let view = configuration.view as? T,
                let model = RuntimeHelper.recursivelyUnwrapAnyValue(self?.storage.itemAtIndexPath(configuration.indexPath)) as? T.ModelType
            {
                closure(view, model, configuration.indexPath)
            }
        }
        self.tableViewReactions.append(reaction)
    }
    
    /// Define additional configuration action, that will happen, when UITableViewCell subclass is requested by UITableView. This action will be performed *after* cell is created and updateWithModel: method is called.
    /// - Parameter methodPointer: pointer to `DTTableViewManageable` method with signature: (Cell, Model, NSIndexPath) closure to run when UITableViewCell is configured
    /// - Note: This method automatically breaks retain cycles, that can happen when passing method pointer somewhere. `DTTableViewManageable` instance is used to call configuration event.
    public func cellConfiguration<T,U where T:ModelTransfer, T: UITableViewCell, U: DTTableViewManageable>(methodPointer: U -> (T, T.ModelType, NSIndexPath) -> Void)
    {
        let reaction = UIReaction(.CellConfiguration, viewClass: T.self)
        reaction.reactionBlock = { [weak self, unowned reaction] in
            if let viewData = reaction.reactionData,
                let view = viewData.view as? T,
                let model = RuntimeHelper.recursivelyUnwrapAnyValue(self?.storage.itemAtIndexPath(viewData.indexPath)) as? T.ModelType,
                let delegate = self?.delegate as? U
            {
                methodPointer(delegate)(view, model, viewData.indexPath)
            }
        }
        self.tableViewReactions.append(reaction)
    }
    
    /// Define additional configuration action, that will happen, when UIView header subclass is requested by UITableView. This action will be performed *after* header is created and updateWithModel: method is called.
    /// - Parameter headerClass: Type of UIView or UITableHeaderFooterView subclass
    /// - Parameter closure: closure to run when UITableHeaderFooterView is being configured
    /// - Warning: Closure will be stored on `DTTableViewManager` instance, which can create a retain cycle, so make sure to declare weak self and any other `DTTableViewManager` property in capture lists.
    /// - SeeAlso: 'headerConfiguration:'
    public func configureHeader<T:ModelTransfer where T: UIView>(headerClass: T.Type, _ closure: (T, T.ModelType, Int) -> Void)
    {
        let reaction = UIReaction(.SupplementaryConfiguration(kind: DTTableViewElementSectionHeader), viewClass: T.self)
        reaction.reactionBlock = { [weak self, unowned reaction] in
            if let configuration = reaction.reactionData,
                let headerStorage = self?.storage as? HeaderFooterStorageProtocol,
                let model = RuntimeHelper.recursivelyUnwrapAnyValue(headerStorage.headerModelForSectionIndex(configuration.indexPath.section)) as? T.ModelType
            {
                closure(configuration.view as! T, model, configuration.indexPath.section)
            }
        }
        self.tableViewReactions.append(reaction)
    }
    
    /// Define additional configuration action, that will happen, when UIView header subclass is requested by UITableView. This action will be performed *after* header is created and updateWithModel: method is called.
    /// - Parameter methodPointer: pointer to `DTTableViewManageable` method with signature: (Header, Model, SectionIndex) closure to run when UIView or UITableViewHeaderFooterView header is configured
    /// - Note: This method automatically breaks retain cycles, that can happen when passing method pointer somewhere. `DTTableViewManageable` instance is used to call configuration event.
    public func headerConfiguration<T, U where T:ModelTransfer, T: UIView, U: DTTableViewManageable>(methodPointer: U -> (T, T.ModelType, Int) -> Void)
    {
        let reaction = UIReaction(.SupplementaryConfiguration(kind: DTTableViewElementSectionHeader), viewClass: T.self)
        reaction.reactionBlock = { [weak self, unowned reaction] in
            if let configuration = reaction.reactionData,
                let headerStorage = self?.storage as? HeaderFooterStorageProtocol,
                let model = RuntimeHelper.recursivelyUnwrapAnyValue(headerStorage.headerModelForSectionIndex(configuration.indexPath.section)) as? T.ModelType,
                let view = configuration.view as? T,
                let delegate = self?.delegate as? U
            {
                methodPointer(delegate)(view, model, configuration.indexPath.section)
            }
        }
        self.tableViewReactions.append(reaction)
    }
    
    /// Define additional configuration action, that will happen, when UIView footer subclass is requested by UITableView. This action will be performed *after* footer is created and updateWithModel: method is called.
    /// - Parameter footerClass: Type of UIView or UITableReusableView subclass
    /// - Parameter closure: closure to run when UITableReusableView is being configured
    /// - Warning: Closure will be stored on `DTTableViewManager` instance, which can create a retain cycle, so make sure to declare weak self and any other `DTTableViewManager` property in capture lists.
    /// - SeeAlso: 'footerConfiguration:'
    public func configureFooter<T:ModelTransfer where T: UIView>(footerClass: T.Type, _ closure: (T, T.ModelType, Int) -> Void)
    {
        let reaction = UIReaction(.SupplementaryConfiguration(kind: DTTableViewElementSectionFooter), viewClass: T.self)
        reaction.reactionBlock = { [weak self, unowned reaction] in
            if let configuration = reaction.reactionData,
                let footerStorage = self?.storage as? HeaderFooterStorageProtocol,
                let model = RuntimeHelper.recursivelyUnwrapAnyValue(footerStorage.footerModelForSectionIndex(configuration.indexPath.section)) as? T.ModelType
            {
                closure(configuration.view as! T, model, configuration.indexPath.section)
            }
        }
        self.tableViewReactions.append(reaction)
    }
    
    /// Define additional configuration action, that will happen, when UIView footer subclass is requested by UITableView. This action will be performed *after* footer is created and updateWithModel: method is called.
    /// - Parameter methodPointer: pointer to `DTTableViewManageable` method with signature: (Footer, Model, SectionIndex) closure to run when UIView or UITableViewHeaderFooterView footer is configured
    /// - Note: This method automatically breaks retain cycles, that can happen when passing method pointer somewhere. `DTTableViewManageable` instance is used to call configuration event.
    public func footerConfiguration<T, U where T:ModelTransfer, T: UIView, U: DTTableViewManageable>(methodPointer: U -> (T, T.ModelType, Int) -> Void)
    {
        let reaction = UIReaction(.SupplementaryConfiguration(kind: DTTableViewElementSectionFooter), viewClass: T.self)
        reaction.reactionBlock = { [weak self, unowned reaction] in
            if let configuration = reaction.reactionData,
                let headerStorage = self?.storage as? HeaderFooterStorageProtocol,
                let model = RuntimeHelper.recursivelyUnwrapAnyValue(headerStorage.footerModelForSectionIndex(configuration.indexPath.section)) as? T.ModelType,
                let view = configuration.view as? T,
                let delegate = self?.delegate as? U
            {
                methodPointer(delegate)(view, model, configuration.indexPath.section)
            }
        }
        self.tableViewReactions.append(reaction)
    }
}

// MARK: - UITableViewDatasource
extension DTTableViewManager: UITableViewDataSource
{
    func handleTableViewFactoryError(error: DTTableViewFactoryError) {
        if let handler = viewFactoryErrorHandler {
            handler(error)
        } else {
            print(error.description)
            fatalError(error.description)
        }
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.storage.sections[section].numberOfItems
    }
    
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.storage.sections.count
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
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
        
        if let reaction = tableViewReactions.reactionsOfType(.CellConfiguration, forView: cell).first {
            reaction.reactionData = ViewData(view: cell, indexPath:indexPath)
            reaction.perform()
        }
        return cell
    }
    
    public func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if configuration.sectionHeaderStyle == .View { return nil }
        
        return self.headerModelForSectionIndex(section) as? String
    }
    
    public func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if configuration.sectionFooterStyle == .View { return nil }
        
        return self.footerModelForSectionIndex(section) as? String
    }
    
    /// `DTTableViewManager` automatically moves data models from source indexPath to destination indexPath, there's no need to implement this method on UITableViewDataSource
    public func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        if let storage = self.storage as? MemoryStorage
        {
            if let from = storage.sections[sourceIndexPath.section] as? SectionModel,
               let to = storage.sections[destinationIndexPath.section] as? SectionModel
            {
                    let item = from.items[sourceIndexPath.row]
                    
                    from.items.removeAtIndex(sourceIndexPath.row)
                    to.items.insert(item, atIndex: destinationIndexPath.row)
            }
        }
    }
}

// MARK: - UITableViewDelegate
extension DTTableViewManager: UITableViewDelegate
{
    public func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath)
    {
        if dataBindingBehaviour == .BeforeCellIsDisplayed {
            guard let model = RuntimeHelper.recursivelyUnwrapAnyValue(storage.itemAtIndexPath(indexPath)),
            let mapping = viewFactory.viewModelMappingForViewType(.Cell, model: model) else {
                return
            }
            mapping.updateBlock(cell,model)
        }
        (delegate as? UITableViewDelegate)?.tableView?(tableView, willDisplayCell: cell, forRowAtIndexPath: indexPath)
    }
    
    public func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if configuration.sectionHeaderStyle == .Title { return nil }
        
        if let model = self.headerModelForSectionIndex(section) {
            let view : UIView?
            do {
                view = try self.viewFactory.headerViewForModel(model, atIndexPath: NSIndexPath(index: section))
            } catch let error as DTTableViewFactoryError {
                handleTableViewFactoryError(error)
                view = nil
            } catch {
                view = nil
            }
            
            if let createdView = view,
                let reaction = tableViewReactions.reactionsOfType(.SupplementaryConfiguration(kind: DTTableViewElementSectionHeader), forView: view).first
            {
                reaction.reactionData = ViewData(view: createdView, indexPath: NSIndexPath(index: section))
                reaction.perform()
            }
            return view
        }
        return nil
    }
    
    public func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if configuration.sectionFooterStyle == .Title { return nil }
        
        if let model = self.footerModelForSectionIndex(section) {
            let view : UIView?
            do {
                view = try self.viewFactory.footerViewForModel(model, atIndexPath: NSIndexPath(index: section))
            } catch let error as DTTableViewFactoryError {
                handleTableViewFactoryError(error)
                view = nil
            } catch {
                view = nil
            }
            
            if let createdView = view,
                let reaction = tableViewReactions.reactionsOfType(.SupplementaryConfiguration(kind: DTTableViewElementSectionFooter), forView: view).first
            {
                reaction.reactionData = ViewData(view: createdView, indexPath: NSIndexPath(index: section))
                reaction.perform()
            }
            return view
        }
        return nil
    }
    
    /// You can implement this method on a `DTTableViewManageable` delegate, and then it will be called to determine header height
    /// - Note: In most cases, it's enough to set sectionHeaderHeight property on UITableView and overriding this method is not actually needed
    /// - Note: If you override this method on a delegate, displayHeaderOnEmptySection property is ignored
    public func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if let height = (self.delegate as? UITableViewDelegate)?.tableView?(tableView, heightForHeaderInSection: section)
        {
            return height
        }
        if configuration.sectionHeaderStyle == .Title {
            if let _ = self.headerModelForSectionIndex(section)
            {
                return UITableViewAutomaticDimension
            }
            return CGFloat.min
        }
        
        if let _ = self.headerModelForSectionIndex(section)
        {
            return self.tableView?.sectionHeaderHeight ?? CGFloat.min
        }
        return CGFloat.min
    }
    
    /// You can implement this method on a `DTTableViewManageable` delegate, and then it will be called to determine footer height
    /// - Note: In most cases, it's enough to set sectionFooterHeight property on UITableView and overriding this method is not actually needed
    /// - Note: If you override this method on a delegate, displayFooterOnEmptySection property is ignored
    public func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if let height = (self.delegate as? UITableViewDelegate)?.tableView?(tableView, heightForFooterInSection: section)
        {
            return height
        }
        
        if configuration.sectionFooterStyle == .Title {
            if let _ = self.footerModelForSectionIndex(section) {
                return UITableViewAutomaticDimension
            }
            return CGFloat.min
        }
        
        if let _ = self.footerModelForSectionIndex(section) {
            return self.tableView?.sectionFooterHeight ?? CGFloat.min
        }
        return CGFloat.min
    }
    
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)!
        if let reaction = tableViewReactions.reactionsOfType(.CellSelection, forView: cell).first {
            reaction.reactionData = ViewData(view: cell, indexPath: indexPath)
            reaction.perform()
        }
    }
}

// MARK: - StorageUpdating
extension DTTableViewManager : StorageUpdating
{
    public func storageDidPerformUpdate(update : StorageUpdate)
    {
        self.controllerWillUpdateContent()

        tableView?.beginUpdates()
        
        if update.deletedRowIndexPaths.count > 0 { tableView?.deleteRowsAtIndexPaths(Array(update.deletedRowIndexPaths), withRowAnimation: configuration.deleteRowAnimation) }
        if update.insertedRowIndexPaths.count > 0 { tableView?.insertRowsAtIndexPaths(Array(update.insertedRowIndexPaths), withRowAnimation: configuration.insertRowAnimation) }
        if update.updatedRowIndexPaths.count > 0 { tableView?.reloadRowsAtIndexPaths(Array(update.updatedRowIndexPaths), withRowAnimation: configuration.reloadRowAnimation) }
        if update.movedRowIndexPaths.count > 0 {
            for moveUpdate in update.movedRowIndexPaths {
                if let from = moveUpdate.first, let to = moveUpdate.last {
                    tableView?.moveRowAtIndexPath(from, toIndexPath: to)
                }
            }
        }
        
        if update.deletedSectionIndexes.count > 0 { tableView?.deleteSections(update.deletedSectionIndexes.makeNSIndexSet(), withRowAnimation: configuration.deleteSectionAnimation) }
        if update.insertedSectionIndexes.count > 0 { tableView?.insertSections(update.insertedSectionIndexes.makeNSIndexSet(), withRowAnimation: configuration.insertSectionAnimation) }
        if update.updatedSectionIndexes.count > 0 { tableView?.reloadSections(update.updatedSectionIndexes.makeNSIndexSet(), withRowAnimation: configuration.reloadSectionAnimation)}
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