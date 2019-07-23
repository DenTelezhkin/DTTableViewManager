//
//  DiffableDatasourcesTestCase.swift
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 7/23/19.
//  Copyright © 2019 Denys Telezhkin. All rights reserved.
//

import XCTest
@testable import DTTableViewManager
import DTModelStorage

@available(iOS 13, tvOS 13, *)
extension NSDiffableDataSourceSnapshot {
    static func snapshot(with block: (NSDiffableDataSourceSnapshot<SectionIdentifierType, ItemIdentifierType>) -> ()) -> NSDiffableDataSourceSnapshot {
        let snapshot = NSDiffableDataSourceSnapshot<SectionIdentifierType, ItemIdentifierType>()
        block(snapshot)
        return snapshot
    }
}

@available(iOS 13, tvOS 13, *)
extension NSDiffableDataSourceSnapshotReference {
    static func snapshot(with block: (NSDiffableDataSourceSnapshotReference) -> ()) -> NSDiffableDataSourceSnapshotReference {
        let snapshot = NSDiffableDataSourceSnapshotReference()
        block(snapshot)
        return snapshot
    }
}

@available(iOS 13, tvOS 13, *)
class DiffableDatasourcesTestCase: BaseTestCase {
    enum Section {
        case one
        case two
        case three
    }
    
    var dataSource: UITableViewDiffableDataSource<Section, Int>!
    
    override func setUp() {
        super.setUp()
        dataSource = controller.manager.configureDiffableDataSource(modelProvider: { $1 })
        controller.manager.register(NibCell.self)
    }
    
    func testMultipleSectionsWorkWithDiffableDataSources() {
        dataSource.apply(.snapshot(with: { snapshot in
            snapshot.appendSections([.one, .two])
            snapshot.appendItems([1,2], toSection: .one)
            snapshot.appendItems([3,4], toSection: .two)
        }))
        
        XCTAssert(controller.verifyItem(2, atIndexPath: indexPath(1, 0)))
        XCTAssert(controller.verifyItem(3, atIndexPath: indexPath(0, 1)))
        XCTAssertEqual(controller.manager.storage?.numberOfSections(), 2)
        XCTAssertEqual(controller.manager.storage?.numberOfItems(inSection: 0), 2)
        XCTAssertEqual(controller.manager.storage?.numberOfItems(inSection: 1), 2)
    }
    
    func testCellSelectionClosure()
    {
        controller = ReactingTestTableViewController()
        controller.tableView = AlwaysVisibleTableView()
        let _ = controller.view
        dataSource = controller.manager.configureDiffableDataSource(modelProvider: { $1 })
        controller.manager.register(SelectionReactingTableCell.self)
        var reactingCell : SelectionReactingTableCell?
        controller.manager.didSelect(SelectionReactingTableCell.self) { (cell, model, indexPath) in
            cell.indexPath = indexPath
            cell.model = model
            reactingCell = cell
        }
        
        dataSource.apply(.snapshot(with: { snapshot in
            snapshot.appendSections([.one])
            snapshot.appendItems([1,2], toSection: .one)
        }))
        controller.manager.tableDelegate?.tableView(controller.tableView, didSelectRowAt: indexPath(1, 0))
        
        XCTAssertEqual(reactingCell?.indexPath, indexPath(1, 0))
        XCTAssertEqual(reactingCell?.model, 2)
    }
}

@available(iOS 13, tvOS 13, *)
class DiffableDatasourceReferencesTestCase: BaseTestCase {
    enum Section {
        case one
        case two
        case three
    }
    
    var dataSourceReference: UITableViewDiffableDataSourceReference!
    
    override func setUp() {
        super.setUp()
        dataSourceReference = controller.manager.configureDiffableDataSource(modelProvider: { $1 })
        controller.manager.register(NibCell.self)
    }
    
    func testMultipleSectionsWorkWithDiffableDataSourceReferences() {
        dataSourceReference.applySnapshot(.snapshot(with: { snapshot in
            snapshot.appendSections(withIdentifiers: [Section.one, Section.two])
            snapshot.appendItems(withIdentifiers: [1,2], intoSectionWithIdentifier: Section.one)
            snapshot.appendItems(withIdentifiers: [3,4], intoSectionWithIdentifier: Section.two)
        }), animatingDifferences: false)
        
        XCTAssert(controller.verifyItem(2, atIndexPath: indexPath(1, 0)))
        XCTAssert(controller.verifyItem(3, atIndexPath: indexPath(0, 1)))
        XCTAssertEqual(controller.manager.storage?.numberOfSections(), 2)
        XCTAssertEqual(controller.manager.storage?.numberOfItems(inSection: 0), 2)
        XCTAssertEqual(controller.manager.storage?.numberOfItems(inSection: 1), 2)
    }
    
    func testCellSelectionClosure()
    {
        controller = ReactingTestTableViewController()
        controller.tableView = AlwaysVisibleTableView()
        let _ = controller.view
        dataSourceReference = controller.manager.configureDiffableDataSource(modelProvider: { $1 })
        controller.manager.register(SelectionReactingTableCell.self)
        var reactingCell : SelectionReactingTableCell?
        controller.manager.didSelect(SelectionReactingTableCell.self) { (cell, model, indexPath) in
            cell.indexPath = indexPath
            cell.model = model
            reactingCell = cell
        }
        
        dataSourceReference.applySnapshot(.snapshot(with: { snapshot in
            snapshot.appendSections(withIdentifiers: [Section.one, Section.two])
            snapshot.appendItems(withIdentifiers: [1,2], intoSectionWithIdentifier: Section.one)
        }), animatingDifferences: false)
        controller.manager.tableDelegate?.tableView(controller.tableView, didSelectRowAt: indexPath(1, 0))
        
        XCTAssertEqual(reactingCell?.indexPath, indexPath(1, 0))
        XCTAssertEqual(reactingCell?.model, 2)
    }
}
