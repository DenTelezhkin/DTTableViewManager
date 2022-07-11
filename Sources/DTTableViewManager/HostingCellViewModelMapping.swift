//
//  HostingCellViewModelMapping.swift
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 22.06.2022.
//  Copyright © 2022 Denys Telezhkin. All rights reserved.
//

import Foundation
import DTModelStorage
import SwiftUI

@available(iOS 13, tvOS 13, *)
/// Configuration to be applied to `HostingTableViewCell`.
public struct HostingTableViewCellConfiguration<Content: View> {
    
    /// Parent view controller, that will have hosting controller added as a child, when cell is dequeued. Setting this property to nil causes assertionFailure.
    public weak var parentController: UIViewController?
    
    /// Closure, that allows customizing which UIHostingController is created for hosted cell.
    public var hostingControllerMaker: (Content) -> UIHostingController<Content> = { UIHostingController(rootView: $0) }
    
    /// Configuration handler for `HostingTableViewCell`, that is being run every time cell is updated.
    public var configureCell: (UITableViewCell) -> Void = { _ in }
    
    /// Background color set for HostingTableViewCell. Defaults to .clear.
    public var backgroundColor: UIColor? = .clear
    
    /// Background color set for HostingTableViewCell.contentView. Defaults to .clear.
    public var contentViewBackgroundColor: UIColor? = .clear
    
    /// Background color set for UIHostingViewController.view. Defaults to .clear.
    public var hostingViewBackgroundColor: UIColor? = .clear
    
    /// HostingTableViewCell selection style. Defaults to .none.
    public var selectionStyle: UITableViewCell.SelectionStyle = .none
}


@available(iOS 13, tvOS 13, *)
/// Cell - Model mapping for SwiftUI hosted cell.
open class HostingCellViewModelMapping<Content: View, Model>: CellViewModelMapping<Content, Model>, CellViewModelMappingProtocolGeneric {
    /// Cell type
    public typealias Cell = HostingTableViewCell<Content, Model>
    /// Model type
    public typealias Model = Model
    
    /// Configuration to use when updating cell
    public var configuration = HostingTableViewCellConfiguration<Content>()
    
    /// Custom subclass type of HostingTableViewCell. When set, resets reuseIdentifier to subclass type.
    public var hostingCellSubclass: HostingTableViewCell<Content, Model>.Type = HostingTableViewCell.self {
        didSet {
            reuseIdentifier = "\(hostingCellSubclass.self)"
        }
    }
    
    /// Reuse identifier to be used for reusable cells.
    public var reuseIdentifier : String
    
    private var _cellConfigurationHandler: ((UITableViewCell, Any, IndexPath) -> Void)?
    private var _cellDequeueClosure: ((_ containerView: UITableView, _ model: Any, _ indexPath: IndexPath) -> UITableViewCell?)?
    
    /// Creates hosting cell model mapping
    /// - Parameters:
    ///   - cellContent: closure, creating SwiftUI view
    ///   - parentViewController: parent view controller, to which UIHostingController will be added as child.
    ///   - mapping: mapping closure
    public init(cellContent: @escaping ((Model, IndexPath) -> Content),
                parentViewController: UIViewController?,
                mapping: ((HostingCellViewModelMapping<Content, Model>) -> Void)?) {
        reuseIdentifier = "\(HostingTableViewCell<Content, Model>.self)"
        super.init(viewClass: HostingTableViewCell<Content, Model>.self)
        configuration.parentController = parentViewController
        _cellDequeueClosure = { [weak self] tableView, model, indexPath in
            guard let self = self, let model = model as? Model else {
                return nil
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: self.reuseIdentifier, for: indexPath)
            if let cell = cell as? HostingTableViewCell<Content, Model> {
                cell.updateWith(rootView: cellContent(model, indexPath), configuration: self.configuration)
            }
            return cell
        }
        _cellConfigurationHandler = { [weak self] cell, model, indexPath in
            guard let cell = cell as? HostingTableViewCell<Content, Model>, let model = model as? Model,
            let configuration = self?.configuration else { return }
            cell.updateWith(rootView: cellContent(model, indexPath), configuration: configuration)
        }
        mapping?(self)
    }
    
    /// Updates cell with model
    /// - Parameters:
    ///   - cell: cell instance. Must be of `UITableViewCell`.Type.
    ///   - indexPath: indexPath of a cell
    ///   - model: model, mapped to a cell.
    open override func updateCell(cell: Any, at indexPath: IndexPath, with model: Any) {
        guard let cell = cell as? UITableViewCell else {
            preconditionFailure("Cannot update a cell, which is not a UITableViewCell")
        }
        _cellConfigurationHandler?(cell, model, indexPath)
    }
    
    /// Dequeues reusable cell for `model`, `indexPath` from `tableView`.
    /// - Parameters:
    ///   - tableView: UITableView instance to dequeue cell from
    ///   - model: model object, that was mapped to cell type.
    ///   - indexPath: IndexPath, at which cell is going to be displayed.
    /// - Returns: dequeued configured UITableViewCell instance.
    open override func dequeueConfiguredReusableCell(for tableView: UITableView, model: Any, indexPath: IndexPath) -> UITableViewCell? {
        guard let cell = _cellDequeueClosure?(tableView, model, indexPath) else {
            return nil
        }
        _cellConfigurationHandler?(cell, model, indexPath)
        return cell
    }
    
    @available(*, unavailable, message:"Dequeing collection view cell from UITableView is not supported")
    /// Unsupported method
    open override func dequeueConfiguredReusableCell(for collectionView: UICollectionView, model: Any, indexPath: IndexPath) -> UICollectionViewCell? {
        preconditionFailure("This method should not be used in UITableView cell view model mapping")
    }
}
