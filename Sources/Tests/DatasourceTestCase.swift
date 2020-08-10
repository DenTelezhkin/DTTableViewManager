//
//  DatasourceTestCase.swift
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 18.07.15.
//  Copyright (c) 2015 Denys Telezhkin. All rights reserved.
//

import UIKit
import XCTest
import DTTableViewManager

class DatasourceTestCase: BaseTestCase {
    
    override func setUp() {
        super.setUp()
        controller.manager.register(NibCell.self)
    }
    
    func testTableItemAtIndexPath()
    {
        controller.manager.memoryStorage.addItems([3,2,1,6,4], toSection: 0)
        
        XCTAssert(controller.verifyItem(6, atIndexPath: indexPath(3, 0)))
        XCTAssert(controller.verifyItem(3, atIndexPath: indexPath(0, 0)))
        XCTAssertNil(controller.manager.memoryStorage.item(at: indexPath(56, 0)))
    }
    
    func testShouldReturnCorrectNumberOfTableItems()
    {
        controller.manager.memoryStorage.addItems([1,1,1,1], toSection: 0)
        controller.manager.memoryStorage.addItems([2,2,2], toSection: 1)
        let tableView = controller.tableView
        XCTAssertEqual(controller.manager.tableDataSource?.tableView(tableView!, numberOfRowsInSection: 0), 4)
        XCTAssertEqual(controller.manager.tableDataSource?.tableView(tableView!, numberOfRowsInSection: 1), 3)
    }
    
    func testShouldReturnCorrectNumberOfSections()
    {
        controller.manager.memoryStorage.addItem(1, toSection: 0)
        controller.manager.memoryStorage.addItem(4, toSection: 3)
        controller.manager.memoryStorage.addItem(2, toSection: 2)
        
        XCTAssertEqual(controller.manager.tableDataSource?.numberOfSections(in: controller.tableView), 4)
    }
    
    func testShouldSetSectionTitles()
    {
        controller.manager.memoryStorage.setSectionHeaderModels(["one","two"])
        let tableView = self.controller.tableView
        XCTAssertEqual(controller.manager.tableDataSource?.tableView(tableView!, titleForHeaderInSection: 0), "one")
        XCTAssertEqual(controller.manager.tableDataSource?.tableView(tableView!, titleForHeaderInSection: 1), "two")
    }
    
    func testSHouldSetSectionFooterTitles()
    {
        controller.manager.memoryStorage.setSectionFooterModels(["one","two"])
        let tableView = controller.tableView
        XCTAssertEqual(controller.manager.tableDataSource?.tableView(tableView!, titleForFooterInSection: 0), "one")
        XCTAssertEqual(controller.manager.tableDataSource?.tableView(tableView!, titleForFooterInSection: 1), "two")
    }
    
    func testShouldHandleAbsenceOfHeadersFooters()
    {
        controller.manager.memoryStorage.addItem(1, toSection: 0)
        controller.manager.memoryStorage.addItem(2, toSection: 1)
        
        _ = controller.manager.tableDataSource?.tableView(controller.tableView, titleForHeaderInSection: 0)
        _ = controller.manager.tableDataSource?.tableView(controller.tableView, titleForFooterInSection: 1)
    }

    func testShouldAddTableItems()
    {
        controller.manager.memoryStorage.addItems([3,2], toSection: 0)
        
        XCTAssertEqual(controller.manager.memoryStorage.items(inSection: 0)?.count, 2)
    }
    
    func testShouldInsertTableItem()
    {
        controller.manager.memoryStorage.addItems([2,4,6], toSection: 0)
        try! controller.manager.memoryStorage.insertItem(1, to: indexPath(2, 0))
        
        XCTAssertEqual(controller.manager.memoryStorage.items(inSection: 0)?.count, 4)
        XCTAssert(controller.verifyItem(1, atIndexPath: indexPath(2, 0)))
        XCTAssert(controller.verifyItem(6, atIndexPath: indexPath(3, 0)))
    }
    
    func testReplaceItem()
    {
        controller.manager.memoryStorage.addItems([1,3], toSection: 0)
        controller.manager.memoryStorage.addItems([4,6], toSection: 1)
        try! controller.manager.memoryStorage.replaceItem(3, with: 2)
        try! controller.manager.memoryStorage.replaceItem(4, with: 5)
        
        XCTAssertEqual(controller.manager.memoryStorage.items(inSection: 0)?.count, 2)
        XCTAssertEqual(controller.manager.memoryStorage.items(inSection: 1)?.count, 2)
        XCTAssert(controller.verifyItem(2, atIndexPath: indexPath(1, 0)))
        XCTAssert(controller.verifyItem(5, atIndexPath: indexPath(0, 1)))
    }
    
    func testRemoveItem()
    {
        controller.manager.memoryStorage.addItems([1,3,2,4], toSection: 0)
        controller.manager.memoryStorage.removeItems([1,4,3,5])
        
        XCTAssertEqual(controller.manager.memoryStorage.items(inSection: 0)?.count, 1)
        XCTAssert(controller.verifyItem(2, atIndexPath: indexPath(0, 0)))
    }
    
    func testRemoveItems()
    {
        controller.manager.memoryStorage.addItems([1,2,3], toSection: 0)
        controller.manager.memoryStorage.removeAllItems()
        
        XCTAssertEqual(controller.manager.memoryStorage.items(inSection: 0)?.count, 0)
    }
    
    func testMovingItems()
    {
        controller.manager.memoryStorage.addItems([1,2,3], toSection: 0)
        controller.manager.memoryStorage.moveItem(at: indexPath(0, 0), to: indexPath(2, 0))
        
        XCTAssert(controller.verifySection([2,3,1], withSectionNumber: 0))
    }
    
    func testShouldNotCrashWhenMovingToBadRow()
    {
        controller.manager.memoryStorage.addItems([1,2,3], toSection: 0)
        controller.manager.memoryStorage.moveItem(at: indexPath(0, 0), to: indexPath(2, 1))
    }
    
    func testShouldNotCrashWhenMovingFromBadRow()
    {
        controller.manager.memoryStorage.addItems([1,2,3], toSection: 0)
        controller.manager.memoryStorage.moveItem(at: indexPath(0, 1), to: indexPath(0, 0))
    }
    
    func testShouldMoveSections()
    {
        controller.manager.memoryStorage.addItem(1, toSection: 0)
        controller.manager.memoryStorage.addItem(2, toSection: 1)
        controller.manager.memoryStorage.addItem(3, toSection: 2)
        
        controller.manager.memoryStorage.moveSection(0, toSection: 1)
        
        XCTAssert(controller.verifySection([2], withSectionNumber: 0))
        XCTAssert(controller.verifySection([1], withSectionNumber: 1))
        XCTAssert(controller.verifySection([3], withSectionNumber: 2))
    }
    
    func testShouldDeleteSections()
    {
        controller.manager.memoryStorage.addItem(0, toSection: 0)
        controller.manager.memoryStorage.addItem(1, toSection: 1)
        controller.manager.memoryStorage.addItem(2, toSection: 2)
        
        controller.manager.memoryStorage.deleteSections(IndexSet(integer: 1))
        
        XCTAssertEqual(controller.manager.memoryStorage.sections.count, 2)
        XCTAssert(controller.verifySection([2], withSectionNumber: 1))
    }
    
    func testShouldShowTitlesOnEmptySection()
    {
        controller.manager.memoryStorage.setSectionHeaderModels(["Foo"])
        controller.manager.configuration.displayHeaderOnEmptySection = false
        XCTAssertNil(controller.manager.tableDataSource?.tableView(controller.tableView, titleForHeaderInSection: 0))
    }
    
    func testShouldShowTitleOnEmptySectionFooter()
    {
        controller.manager.memoryStorage.setSectionFooterModels(["Foo"])
        controller.manager.configuration.displayFooterOnEmptySection = false
        XCTAssertNil(controller.manager.tableDataSource?.tableView(controller.tableView, titleForFooterInSection: 0))
    }
    
    func testShouldShowViewHeaderOnEmptySEction()
    {
        controller.manager.registerHeader(NibView.self)
        controller.manager.configuration.displayHeaderOnEmptySection = false
        controller.manager.memoryStorage.setSectionHeaderModels([1])
        XCTAssertNil(controller.manager.tableDelegate?.tableView(controller.tableView, viewForHeaderInSection: 0))
    }
    
    func testShouldShowViewFooterOnEmptySection()
    {
        controller.manager.registerFooter(NibView.self)
        controller.manager.configuration.displayFooterOnEmptySection = false
        controller.manager.memoryStorage.setSectionFooterModels([1])
        XCTAssertNil(controller.manager.tableDelegate?.tableView(self.controller.tableView, viewForFooterInSection: 0))
    }
    
    func testSupplementaryKindsShouldBeSet()
    {
        XCTAssertEqual(controller.manager.memoryStorage.supplementaryHeaderKind, DTTableViewElementSectionHeader)
        XCTAssertEqual(controller.manager.memoryStorage.supplementaryFooterKind, DTTableViewElementSectionFooter)
    }
    
    func testHeaderViewShouldBeCreated()
    {
        controller.manager.registerHeader(NibHeaderFooterView.self)
        controller.manager.memoryStorage.setSectionHeaderModels([1])
        XCTAssert(controller.manager.tableDelegate?.tableView(controller.tableView, viewForHeaderInSection: 0) is NibHeaderFooterView)
    }
    
    func testFooterViewShouldBeCreated()
    {
        controller.manager.registerFooter(NibHeaderFooterView.self)
        controller.manager.memoryStorage.setSectionFooterModels([1])
        XCTAssert(controller.manager.tableDelegate?.tableView(controller.tableView, viewForFooterInSection: 0) is NibHeaderFooterView)
    }
    
    func testHeaderViewShouldBeCreatedFromXib()
    {
        controller.manager.registerHeader(NibHeaderFooterView.self) { mapping in
            mapping.xibName = "NibHeaderFooterView"
        }
        controller.manager.memoryStorage.setSectionHeaderModels([1])
        XCTAssert(controller.manager.tableDelegate?.tableView(controller.tableView, viewForHeaderInSection: 0) is NibHeaderFooterView)
    }
    
    func testFooterViewShouldBeCreatedFromXib()
    {
        controller.manager.registerFooter(NibHeaderFooterView.self) { mapping in
            mapping.xibName = "NibHeaderFooterView"
        }
        controller.manager.memoryStorage.setSectionFooterModels([1])
        XCTAssert(controller.manager.tableDelegate?.tableView(controller.tableView, viewForFooterInSection: 0) is NibHeaderFooterView)
    }

    func testTableHeaderModel() {
        controller.manager.memoryStorage.addItem(4)
        controller.manager.memoryStorage.setSectionHeaderModels(["1"])
        XCTAssertEqual(controller.manager.memoryStorage.headerModel(forSection: 0) as? String, "1")
        
        controller.manager.memoryStorage.setSectionHeaderModels(["2"])
        
        XCTAssertEqual(controller.manager.memoryStorage.headerModel(forSection: 0) as? String, "2")
    }
    
    func testTableFooterModel() {
        controller.manager.memoryStorage.addItem(4)
        controller.manager.memoryStorage.setSectionFooterModels(["1"])
        XCTAssertEqual(controller.manager.memoryStorage.footerModel(forSection: 0) as? String, "1")
        
        controller.manager.memoryStorage.setSectionFooterModels(["2"])
        XCTAssertEqual(controller.manager.memoryStorage.footerModel(forSection: 0) as? String, "2")
    }
    
    func testNilHeaderViewWithStyleTitle() {
        controller.manager.memoryStorage.setSectionHeaderModels(["Foo"])
        XCTAssertNil(controller.manager.tableDelegate?.tableView(controller.tableView, viewForHeaderInSection: 0))
    }
    
    func testNilFooterViewWithStyleTitle() {
        controller.manager.memoryStorage.setSectionFooterModels(["Foo"])
        XCTAssertNil(controller.manager.tableDelegate?.tableView(controller.tableView, viewForFooterInSection: 0))
    }
    
    func testReloadRowsClosure() {
        let exp = expectation(description: "Reload row closure")
        controller.manager.tableViewUpdater = TableViewUpdater(tableView: controller.tableView, reloadRow: { indexPath,model in
            if indexPath.section == 0 && indexPath.item == 3 && (model as? Int) == 4 {
                exp.fulfill()
            }
        })
        controller.manager.memoryStorage.addItems([1,2,3,4,5])
        controller.manager.memoryStorage.reloadItem(4)
        waitForExpectations(timeout: 0.5, handler: nil)
    }
    
    func testTableViewUpdaterIsCalledWhenItsChanged() {
        let exp = expectation(description: "DidUpdateContent")
        let updater = TableViewUpdater(tableView: controller.tableView)
        updater.didUpdateContent = { _ in  exp.fulfill() }
        controller.manager.tableViewUpdater = updater
        
        waitForExpectations(timeout: 0.5, handler: nil)
    }
    
    func testNilModelInStorageLeadsToNilModelAnomaly() {
        let exp = expectation(description: "Nil model in storage")
        let model: Int?? = nil
        let anomaly = DTTableViewManagerAnomaly.nilCellModel(indexPath(0, 0))
        controller.manager.anomalyHandler.anomalyAction = exp.expect(anomaly: anomaly)
        controller.manager.memoryStorage.addItem(model)
        
        #if os(tvOS)
            let _ = controller.manager.tableDataSource?.tableView(controller.tableView, cellForRowAt: indexPath(0, 0))
        #endif
        
        waitForExpectations(timeout: 0.1)
        
        XCTAssertEqual(anomaly.debugDescription, "❗️[DTTableViewManager] UITableView requested a cell at [0, 0], however the model at that indexPath was nil.")
    }
    
    func testNilHeaderModelLeadsToAnomaly() {
        let exp = expectation(description: "Nil header model in storage")
        let model: Int? = nil
        let anomaly = DTTableViewManagerAnomaly.nilHeaderModel(0)
        controller.manager.anomalyHandler.anomalyAction = exp.expect(anomaly: anomaly)
        controller.manager.registerHeader(NibHeaderFooterView.self)
        controller.manager.memoryStorage.setSectionHeaderModels([model])
        controller.manager.configuration.displayHeaderOnEmptySection = true
        let _ = controller.manager.tableDelegate?.tableView(controller.tableView, viewForHeaderInSection: 0)
        waitForExpectations(timeout: 0.1)
        
        XCTAssertEqual(anomaly.debugDescription, "⚠️[DTTableViewManager] UITableView requested a header view at section 0, however the model was nil.")
    }
    
    func testNilFooterModelLeadsToAnomaly() {
        let exp = expectation(description: "Nil footer model in storage")
        let model: Int?? = nil
        let anomaly = DTTableViewManagerAnomaly.nilFooterModel(0)
        controller.manager.anomalyHandler.anomalyAction = exp.expect(anomaly: anomaly)
        controller.manager.registerFooter(NibHeaderFooterView.self)
        controller.manager.memoryStorage.setSectionFooterModels([model])
        controller.manager.configuration.displayFooterOnEmptySection = true
        let _ = controller.manager.tableDelegate?.tableView(controller.tableView, viewForFooterInSection: 0)
        waitForExpectations(timeout: 0.1)
        
        XCTAssertEqual(anomaly.debugDescription, "⚠️[DTTableViewManager] UITableView requested a footer view at section 0, however the model was nil.")
    }
    
    func testNilHeaderModelDoesNotLeadToAnomalyIfItShouldNotBeDisplayedInTheFirstPlace() {
        let exp = expectation(description: "Nil header model in storage")
        exp.isInverted = true
        let model: Int?? = nil
        controller.manager.configuration.displayHeaderOnEmptySection = false
        let anomaly = DTTableViewManagerAnomaly.nilHeaderModel(0)
        controller.manager.anomalyHandler.anomalyAction = exp.expect(anomaly: anomaly)
        controller.manager.registerHeader(NibHeaderFooterView.self)
        controller.manager.memoryStorage.setSectionHeaderModels([model])
        let _ = controller.manager.tableDelegate?.tableView(controller.tableView, viewForHeaderInSection: 0)
        waitForExpectations(timeout: 0.1)
    }
    
    func testNilFooterModelDoesNotLeadToAnomalyIfItShouldNotBeDisplayedInTheFirstPlace() {
        let exp = expectation(description: "Nil footer model in storage")
        exp.isInverted = true
        let model: Int?? = nil
        controller.manager.configuration.displayFooterOnEmptySection = false
        let anomaly = DTTableViewManagerAnomaly.nilFooterModel(0)
        controller.manager.anomalyHandler.anomalyAction = exp.expect(anomaly: anomaly)
        controller.manager.registerFooter(NibHeaderFooterView.self)
        controller.manager.memoryStorage.setSectionFooterModels([model])
        let _ = controller.manager.tableDelegate?.tableView(controller.tableView, viewForFooterInSection: 0)
        waitForExpectations(timeout: 0.1)
    }
    
    func testNoCellMappingsTriggerAnomaly() {
        let exp = expectation(description: "No cell mappings found for model")
        let anomaly = DTTableViewManagerAnomaly.noCellMappingFound(modelDescription: "3", indexPath: indexPath(0, 0))
        controller.manager.anomalyHandler.anomalyAction = exp.expect(anomaly: anomaly)
        controller.manager.memoryStorage.addItem("3")
        #if os(tvOS)
        let _ = controller.manager.tableDataSource?.tableView(controller.tableView, cellForRowAt: indexPath(0, 0))
        #endif

        waitForExpectations(timeout: 0.1)
        
        XCTAssertEqual(anomaly.debugDescription, "❗️[DTTableViewManager] UITableView requested a cell for model at [0, 0], but view model mapping for it was not found, model description: 3")
    }
    
    func testNoHeaderMappingTriggersToAnomaly() {
        let exp = expectation(description: "No header mapping found")
        let anomaly = DTTableViewManagerAnomaly.noHeaderFooterMappingFound(modelDescription: "0", indexPath: IndexPath(item: 0, section: 0))
        controller.manager.anomalyHandler.anomalyAction = exp.expect(anomaly: anomaly)
        controller.manager.memoryStorage.setSectionHeaderModels([0])
        controller.manager.configuration.displayHeaderOnEmptySection = true
        controller.manager.configuration.sectionHeaderStyle = .view
        let _ = controller.manager.tableDelegate?.tableView(controller.tableView, viewForHeaderInSection: 0)
        waitForExpectations(timeout: 0.1)
        
        XCTAssertEqual(anomaly.debugDescription, "❗️[DTTableViewManager] UITableView requested a header/footer view for model at [0, 0], but view model mapping for it was not found, model description: 0")
    }
    
    func testWrongReuseIdentifierLeadsToAnomaly() {
        let exp = expectation(description: "Wrong reuse identifier")
        let anomaly = DTTableViewManagerAnomaly.differentCellReuseIdentifier(mappingReuseIdentifier: "WrongReuseIdentifierCell",
                                                                             cellReuseIdentifier: "Foo")
        controller.manager.anomalyHandler.anomalyAction = exp.expect(anomaly: anomaly)
        controller.manager.register(WrongReuseIdentifierCell.self)
        
        waitForExpectations(timeout: 0.1)
        
        XCTAssertEqual(anomaly.debugDescription, "❗️[DTTableViewManager] Reuse identifier specified in InterfaceBuilder: Foo does not match reuseIdentifier used to register with UITableView: WrongReuseIdentifierCell. \n" +
            "If you are using XIB, please remove reuseIdentifier from XIB file, or change it to name of UITableViewCell subclass. If you are using Storyboards, please change UITableViewCell identifier to name of the class. \n" +
        "If you need different reuseIdentifier for any reason, you can change reuseIdentifier when registering mapping.")
    }
    
    func testWrongReuseIdentifierWithDifferentCellClassNameLeadsToAnomaly() {
        let exp = expectation(description: "Wrong reuse identifier")
        let anomaly = DTTableViewManagerAnomaly.differentCellReuseIdentifier(mappingReuseIdentifier: "WrongReuseIdentifierCell",
                                                                             cellReuseIdentifier: "Foo")
        controller.manager.anomalyHandler.anomalyAction = exp.expect(anomaly: anomaly)
        controller.manager.register(WrongReuseIdentifierCell.self) { mapping in
            mapping.xibName = "RandomNameWrongReuseIdentifierCell"
        }
        waitForExpectations(timeout: 0.1)
        
        XCTAssertEqual(anomaly.debugDescription, "❗️[DTTableViewManager] Reuse identifier specified in InterfaceBuilder: Foo does not match reuseIdentifier used to register with UITableView: WrongReuseIdentifierCell. \nIf you are using XIB, please remove reuseIdentifier from XIB file, or change it to name of UITableViewCell subclass. If you are using Storyboards, please change UITableViewCell identifier to name of the class. \nIf you need different reuseIdentifier for any reason, you can change reuseIdentifier when registering mapping.")
    }
    
    func testWrongTableViewCellClassComingFromXibLeadsToAnomaly() {
        let exp = expectation(description: "Wrong cell class")
        let anomaly = DTTableViewManagerAnomaly.differentCellClass(xibName: "RandomNibNameCell",
                                                                   cellClass: "BaseTestCell",
                                                                   expectedCellClass: "StringCell")
        controller.manager.anomalyHandler.anomalyAction = exp.expect(anomaly: anomaly)
        controller.manager.register(StringCell.self) { mapping in
            mapping.xibName = "RandomNibNameCell"
        }
        waitForExpectations(timeout: 0.1)
        
        XCTAssertEqual(anomaly.debugDescription, "⚠️[DTTableViewManager] Attempted to register xib RandomNibNameCell, but view found in a xib was of type BaseTestCell, while expected type is StringCell. This can prevent cells from being updated with models and react to events.")
    }
    
    func testWrongClassTableViewCellComingFromDequeue() {
        let exp = expectation(description: "Wrong cell class")
        let anomaly = DTTableViewManagerAnomaly.emptyXibFile(xibName: "EmptyXib",
                                                             expectedViewClass: "StringCell")
        controller.manager.anomalyHandler.anomalyAction = exp.expect(anomaly: anomaly)
        controller.manager.register(StringCell.self) { mapping in
            mapping.xibName = "EmptyXib"
        }
        waitForExpectations(timeout: 0.1)
        
        XCTAssertEqual(anomaly.debugDescription, "⚠️[DTTableViewManager] Attempted to register xib EmptyXib for StringCell, but this xib does not contain any views.")
    }
    
    func testWrongHeaderClassComingFromXibLeadsToAnomaly() {
        let exp = expectation(description: "Wrong header class")
        let anomaly = DTTableViewManagerAnomaly.differentHeaderFooterClass(xibName: "NibView",
                                                                           viewClass: "NibView",
                                                                           expectedViewClass: "ReactingHeaderFooterView")
        controller.manager.anomalyHandler.anomalyAction = exp.expect(anomaly: anomaly)
        controller.manager.registerHeader(ReactingHeaderFooterView.self) { mapping in
            mapping.xibName = "NibView"
        }
        waitForExpectations(timeout: 0.1)
        
        XCTAssertEqual(anomaly.debugDescription, "⚠️[DTTableViewManager] Attempted to register xib NibView, but view found in a xib was of type NibView, while expected type is ReactingHeaderFooterView. This can prevent headers/footers from being updated with models and react to events.")
    }
    
    func testWrongFooterClassComingFromXibLeadsToAnomaly() {
        let exp = expectation(description: "Wrong header class")
        let anomaly = DTTableViewManagerAnomaly.differentHeaderFooterClass(xibName: "NibView",
                                                                           viewClass: "NibView",
                                                                           expectedViewClass: "ReactingHeaderFooterView")
        controller.manager.anomalyHandler.anomalyAction = exp.expect(anomaly: anomaly)
        controller.manager.registerFooter(ReactingHeaderFooterView.self) { mapping in
            mapping.xibName = "NibView"
        }
        waitForExpectations(timeout: 0.1)
        
        XCTAssertEqual(anomaly.debugDescription, "⚠️[DTTableViewManager] Attempted to register xib NibView, but view found in a xib was of type NibView, while expected type is ReactingHeaderFooterView. This can prevent headers/footers from being updated with models and react to events.")
    }
}
