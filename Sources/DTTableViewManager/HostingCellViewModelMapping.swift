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

// swiftlint:disable missing_docs

@available(iOS 13, tvOS 13, *)
public struct HostingTableViewCellConfiguration {
    public weak var parentController: UIViewController?
    public var hostingController: (AnyView) -> UIHostingController<AnyView> = { UIHostingController(rootView: $0) }
    public var configureCell: (UITableViewCell) -> Void = { _ in }
    public var backgroundColor: UIColor? = .clear
    public var contentViewBackgroundColor: UIColor? = .clear
    public var hostingViewBackgroundColor: UIColor? = .clear
    public var selectionStyle: UITableViewCell.SelectionStyle = .none
}

@available(iOS 13, tvOS 13, *)
open class HostingCellViewModelMapping<Content: View, Model>: CellViewModelMapping<Content, Model>, CellViewModelMappingProtocolGeneric {
    public typealias Cell = HostingTableViewCell<Content, Model>
    public typealias Model = Model
    
    public var configuration = HostingTableViewCellConfiguration()
    
    public var hostingCellSubclass: HostingTableViewCell<Content, Model>.Type = HostingTableViewCell.self {
        didSet {
            reuseIdentifier = "\(hostingCellSubclass.self)"
        }
    }
    
    /// Reuse identifier to be used for reusable cells.
    public var reuseIdentifier : String
    
    private var _cellConfigurationHandler: ((UITableViewCell, Any, IndexPath) -> Void)?
    private var _cellDequeueClosure: ((_ containerView: UITableView, _ model: Any, _ indexPath: IndexPath) -> UITableViewCell?)?
    
    public init(cellContent: @escaping ((Model, IndexPath) -> Content), mapping: ((HostingCellViewModelMapping<Content, Model>) -> Void)?) {
        reuseIdentifier = "\(HostingTableViewCell<Content, Model>.self)"
        super.init(viewClass: HostingTableViewCell<Content, Model>.self)
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
    
    open override func updateCell(cell: Any, at indexPath: IndexPath, with model: Any) {
        guard let cell = cell as? UITableViewCell else {
            preconditionFailure("Cannot update a cell, which is not a UITableViewCell")
        }
        _cellConfigurationHandler?(cell, model, indexPath)
    }
    
    open override func dequeueConfiguredReusableCell(for tableView: UITableView, model: Any, indexPath: IndexPath) -> UITableViewCell? {
        guard let cell = _cellDequeueClosure?(tableView, model, indexPath) else {
            return nil
        }
        _cellConfigurationHandler?(cell, model, indexPath)
        return cell
    }
    
    open override func dequeueConfiguredReusableCell(for collectionView: UICollectionView, model: Any, indexPath: IndexPath) -> UICollectionViewCell? {
        preconditionFailure("This method should not be used in UITableView cell view model mapping")
    }
}
