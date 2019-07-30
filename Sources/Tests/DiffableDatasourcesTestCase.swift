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
    
    func setItems(_ items: [Int]) {
        dataSource.apply(.snapshot(with: { snapshot in
            snapshot.appendSections([.one])
            snapshot.appendItems(items)
        }))
    }
    
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
        XCTAssertEqual(controller.manager.storage.numberOfSections(), 2)
        XCTAssertEqual(controller.manager.storage.numberOfItems(inSection: 0), 2)
        XCTAssertEqual(controller.manager.storage.numberOfItems(inSection: 1), 2)
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
    
    func testShouldShowTitlesOnEmptySection()
    {
        controller.manager.supplementaryStorage?.setSectionHeaderModels(["Foo"])
        controller.manager.configuration.displayHeaderOnEmptySection = false
        setItems([])
        XCTAssertNil(controller.manager.tableDataSource?.tableView(controller.tableView, titleForHeaderInSection: 0))
    }
    
    func testShouldShowTitleOnEmptySectionFooter()
    {
        controller.manager.supplementaryStorage?.setSectionFooterModels(["Foo"])
        controller.manager.configuration.displayFooterOnEmptySection = false
        setItems([])
        XCTAssertNil(controller.manager.tableDataSource?.tableView(controller.tableView, titleForFooterInSection: 0))
    }
    
    func testShouldShowViewHeaderOnEmptySEction()
    {
        controller.manager.registerHeader(NibView.self)
        controller.manager.configuration.displayHeaderOnEmptySection = false
        controller.manager.supplementaryStorage?.setSectionHeaderModels([1])
        setItems([])
        XCTAssertNil(controller.manager.tableDelegate?.tableView(controller.tableView, viewForHeaderInSection: 0))
    }
    
    func testShouldShowViewFooterOnEmptySection()
    {
        controller.manager.registerFooter(NibView.self)
        controller.manager.configuration.displayFooterOnEmptySection = false
        controller.manager.supplementaryStorage?.setSectionFooterModels([1])
        setItems([])
        XCTAssertNil(controller.manager.tableDelegate?.tableView(self.controller.tableView, viewForFooterInSection: 0))
    }
    
    func testSupplementaryKindsShouldBeSet()
    {
        XCTAssertEqual(controller.manager.supplementaryStorage?.supplementaryHeaderKind, DTTableViewElementSectionHeader)
        XCTAssertEqual(controller.manager.supplementaryStorage?.supplementaryFooterKind, DTTableViewElementSectionFooter)
    }
    
    func testHeaderViewShouldBeCreated()
    {
        controller.manager.registerHeader(NibHeaderFooterView.self)
        controller.manager.supplementaryStorage?.setSectionHeaderModels([1])
        setItems([1])
        XCTAssert(controller.manager.tableDelegate?.tableView(controller.tableView, viewForHeaderInSection: 0) is NibHeaderFooterView)
    }
    
    func testFooterViewShouldBeCreated()
    {
        controller.manager.registerFooter(NibHeaderFooterView.self)
        controller.manager.supplementaryStorage?.setSectionFooterModels([1])
        setItems([1])
        XCTAssert(controller.manager.tableDelegate?.tableView(controller.tableView, viewForFooterInSection: 0) is NibHeaderFooterView)
    }
    
    func testHeaderViewShouldBeCreatedFromXib()
    {
        controller.manager.registerNibNamed("NibHeaderFooterView", forHeader: NibHeaderFooterView.self)
        controller.manager.supplementaryStorage?.setSectionHeaderModels([1])
        setItems([1])
        XCTAssert(controller.manager.tableDelegate?.tableView(controller.tableView, viewForHeaderInSection: 0) is NibHeaderFooterView)
    }
    
    func testFooterViewShouldBeCreatedFromXib()
    {
        controller.manager.registerNibNamed("NibHeaderFooterView", forFooter: NibHeaderFooterView.self)
        controller.manager.supplementaryStorage?.setSectionFooterModels([1])
        setItems([1])
        XCTAssert(controller.manager.tableDelegate?.tableView(controller.tableView, viewForFooterInSection: 0) is NibHeaderFooterView)
    }
    
    func testNilHeaderViewWithStyleTitle() {
        controller.manager.supplementaryStorage?.setSectionHeaderModels(["Foo"])
        setItems([1])
        XCTAssertNil(controller.manager.tableDelegate?.tableView(controller.tableView, viewForHeaderInSection: 0))
    }
    
    func testNilFooterViewWithStyleTitle() {
        controller.manager.supplementaryStorage?.setSectionFooterModels(["Foo"])
        setItems([1])
        XCTAssertNil(controller.manager.tableDelegate?.tableView(controller.tableView, viewForFooterInSection: 0))
    }
    
    func testWillDisplayHeaderInSection() {
        let exp = expectation(description: "willDisplayHeaderInSection")
        controller.manager.willDisplayHeaderView(ReactingHeaderFooterView.self, { header, model, section  in
            exp.fulfill()
        })
        controller.manager.supplementaryStorage?.setSectionHeaderModels(["Foo"])
        setItems([])
        _ = controller.manager.tableDelegate?.tableView(controller.tableView, willDisplayHeaderView: ReactingHeaderFooterView(), forSection: 0)
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testWillDisplayFooterInSection() {
        let exp = expectation(description: "willDisplayFooterInSection")
        controller.manager.willDisplayFooterView(ReactingHeaderFooterView.self, { footer, model, section  in
            exp.fulfill()
        })
        controller.manager.supplementaryStorage?.setSectionFooterModels(["Foo"])
        setItems([])
        _ = controller.manager.tableDelegate?.tableView(controller.tableView, willDisplayFooterView: ReactingHeaderFooterView(), forSection: 0)
        waitForExpectations(timeout: 1, handler: nil)
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
        XCTAssertEqual(controller.manager.storage.numberOfSections(), 2)
        XCTAssertEqual(controller.manager.storage.numberOfItems(inSection: 0), 2)
        XCTAssertEqual(controller.manager.storage.numberOfItems(inSection: 1), 2)
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
