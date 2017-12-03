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
    
    /// Creates `DTTableViewManager`. Usually you don't need to call this method directly, as `manager` property on `DTTableViewManageable` instance is filled automatically.
    public init() {}
    
    /// `DTTableViewManageable` delegate.
    final fileprivate weak var delegate : AnyObject?
    
    /// Bool property, that will be true, after `startManagingWithDelegate` method is called on `DTTableViewManager`.
    open var isManagingTableView : Bool {
        return tableView != nil
    }

    ///  Factory for creating cells and views for UITableView
    final lazy var viewFactory: TableViewFactory = {
        precondition(self.isManagingTableView, "Please call manager.startManagingWithDelegate(self) before calling any other DTTableViewManager methods")
        //swiftlint:disable:next force_unwrapping
        return TableViewFactory(tableView: self.tableView!)
    }()
    
    /// Stores all configuration options for `DTTableViewManager`.
    /// - SeeAlso: `TableViewConfiguration`.
    open var configuration = TableViewConfiguration()
    
    @available(*, deprecated, message: "This property and error handling behavior is deprecated and will be removed in future versions of the framework. If you have a use case for it, please open issue on GitHub.")
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
    open var tableViewUpdater : TableViewUpdater? {
        didSet {
            storage.delegate = tableViewUpdater
            tableViewUpdater?.didUpdateContent?(nil)
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
    
    #if os(iOS) && swift(>=3.2)
    // Yeah, @availability macros does not work on stored properties ¯\_(ツ)_/¯
    private var _tableDragDelegatePrivate : AnyObject?
    @available(iOS 11, *)
    /// Object, that is responsible for implementing `UITableViewDragDelegate` protocol
    open var tableDragDelegate : DTTableViewDragDelegate? {
        get {
            return _tableDragDelegatePrivate as? DTTableViewDragDelegate
        }
        set {
            _tableDragDelegatePrivate = newValue
            tableView?.dragDelegate = newValue
        }
    }
    
    // Yeah, @availability macros does not work on stored properties ¯\_(ツ)_/¯
    private var _tableDropDelegatePrivate : AnyObject?
    @available(iOS 11, *)
    /// Object, that is responsible for implementing `UITableViewDropDelegate` protocol
    open var tableDropDelegate : DTTableViewDropDelegate? {
        get {
            return _tableDropDelegatePrivate as? DTTableViewDropDelegate
        }
        set {
            _tableDropDelegatePrivate = newValue
            tableView?.dropDelegate = newValue
        }
    }
    #endif
    
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
    
    private func startManaging(with tableView: UITableView) {
        if let mappingDelegate = delegate as? ViewModelMappingCustomizing {
            viewFactory.mappingCustomizableDelegate = mappingDelegate
        }
        tableViewUpdater = TableViewUpdater(tableView: tableView)
        tableDelegate = DTTableViewDelegate(delegate: delegate, tableViewManager: self)
        tableDataSource = DTTableViewDataSource(delegate: delegate, tableViewManager: self)
        #if os(iOS) && swift(>=3.2)
        if #available(iOS 11.0, *) {
            tableDragDelegate = DTTableViewDragDelegate(delegate: delegate, tableViewManager: self)
            tableDropDelegate = DTTableViewDropDelegate(delegate: delegate, tableViewManager: self)
        }
        #endif
    }
    
    /// Returns closure, that updates cell at provided indexPath. 
    ///
    /// This is used by `coreDataUpdater` method and can be used to silently update a cell without reload row animation.
    open func updateCellClosure() -> (IndexPath, Any) -> Void {
        return { [weak self] indexPath, model in
            self?.viewFactory.updateCellAt(indexPath, with: model)
        }
    }
    
    
    /// Updates visible cells, using `tableView.indexPathsForVisibleRows`, and update block. This may be more efficient than running `reloadData`, if number of your data models does not change, and the change you want to reflect is completely within models state.
    ///
    /// - Parameter closure: closure to run for each cell after update has been completed.
    open func updateVisibleCells(_ closure: ((UITableViewCell) -> Void)? = nil) {
        (tableView?.indexPathsForVisibleRows ?? []).forEach { indexPath in
            guard let model = storage.item(at: indexPath),
                let visibleCell = tableView?.cellForRow(at: indexPath)
            else { return }
            updateCellClosure()(indexPath, model)
            closure?(visibleCell)
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
    
    
    /// Immediately runs closure to provide access to both T and T.ModelType for `klass`.
    ///
    /// - Discussion: This is particularly useful for registering events, because near 1/3 of events don't have cell or view before they are getting run, which prevents view type from being known, and required developer to remember, which model is mapped to which cell.
    /// By using this container closure you will be able to provide compile-time safety for all events.
    /// - Parameters:
    ///   - klass: Class of reusable view to be used in configuration container
    ///   - closure: closure to run with view types.
    open func configureEvents<T:ModelTransfer>(for klass: T.Type, _ closure: (T.Type, T.ModelType.Type) -> Void) {
        closure(T.self, T.ModelType.self)
    }
}

// MARK: - Method signatures
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
    case moveRowAtIndexPathToIndexPath = "tableView:moveRowAtIndexPath:toIndexPath:"
    
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
    
    case leadingSwipeActionsConfigurationForRowAtIndexPath = "tableView:leadingSwipeActionsConfigurationForRowAtIndexPath:"
    case trailingSwipeActionsConfigurationForRowAtIndexPath = "tableView:trailingSwipeActionsConfigurationForRowAtIndexPath:"
    case targetIndexPathForMoveFromRowAtIndexPath = "tableView:targetIndexPathForMoveFromRowAtIndexPath:toProposedIndexPath:"
    case shouldUpdateFocusInContext = "tableView:shouldUpdateFocusInContext:"
    case didUpdateFocusInContextWithAnimationCoordinator = "tableView:didUpdateFocusInContext:withAnimationCoordinator:"
    case indexPathForPreferredFocusedViewInTableView = "indexPathForPreferredFocusedViewInTableView:"
    case shouldSpringLoadRowAtIndexPathWithContext = "tableView:shouldSpringLoadRowAtIndexPath:withContext:"
    
    /// UITableViewDragDelegate
    case itemsForBeginningDragSession = "tableView:itemsForBeginningDragSession:atIndexPath:"
    case itemsForAddingToDragSession = "tableView:itemsForAddingToDragSession:atIndexPath:point:"
    case dragPreviewParametersForRowAtIndexPath = "tableView:dragPreviewParametersForRowAtIndexPath:"
    case dragSessionWillBegin = "tableView:dragSessionWillBegin:"
    case dragSessionDidEnd = "tableView:dragSessionDidEnd:"
    case dragSessionAllowsMoveOperation = "tableView:dragSessionAllowsMoveOperation:"
    case dragSessionIsRestrictedToDraggingApplication = "tableView:dragSessionIsRestrictedToDraggingApplication:"
    
    /// UITableViewDropDelegate
    case performDropWithCoordinator = "tableView:performDropWithCoordinator:"
    case canHandleDropSession = "tableView:canHandleDropSession:"
    case dropSessionDidEnter = "tableView:dropSessionDidEnter:"
    case dropSessionDidUpdateWithDestinationIndexPath = "tableView:dropSessionDidUpdate:withDestinationIndexPath:"
    case dropSessionDidExit = "tableView:dropSessionDidExit:"
    case dropSessionDidEnd = "tableView:dropSessionDidEnd:"
    case dropPreviewParametersForRowAtIndexPath = "tableView:dropPreviewParametersForRowAtIndexPath:"
}
