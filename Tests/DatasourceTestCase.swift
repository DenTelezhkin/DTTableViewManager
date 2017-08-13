//
//  DatasourceTestCase.swift
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 18.07.15.
//  Copyright (c) 2015 Denys Telezhkin. All rights reserved.
//

import UIKit
import XCTest
import DTModelStorage
import DTTableViewManager
import Nimble

class DatasourceTestCase: XCTestCase {

    var controller : DTTestTableViewController!
    
    override func setUp() {
        super.setUp()
        
        controller = DTTestTableViewController()
        controller.tableView = AlwaysVisibleTableView()
        let _ = controller.view
        controller.manager.startManaging(withDelegate: controller)
        controller.manager.storage = MemoryStorage()
        
        controller.manager.register(NibCell.self)
    }
    
    func testTableItemAtIndexPath()
    {
        controller.manager.memoryStorage.addItems([3,2,1,6,4], toSection: 0)
        
        expect(self.controller.verifyItem(6, atIndexPath: indexPath(3, 0))) == true
        expect(self.controller.verifyItem(3, atIndexPath: indexPath(0, 0))) == true
        expect(self.controller.manager.memoryStorage.item(at: indexPath(56, 0))).to(beNil())
    }
    
    func testShouldReturnCorrectNumberOfTableItems()
    {
        controller.manager.memoryStorage.addItems([1,1,1,1], toSection: 0)
        controller.manager.memoryStorage.addItems([2,2,2], toSection: 1)
        let tableView = controller.tableView
        expect(self.controller.manager.tableDataSource?.tableView(tableView!, numberOfRowsInSection: 0)) == 4
        expect(self.controller.manager.tableDataSource?.tableView(tableView!, numberOfRowsInSection: 1)) == 3
    }
    
    func testShouldReturnCorrectNumberOfSections()
    {
        controller.manager.memoryStorage.addItem(1, toSection: 0)
        controller.manager.memoryStorage.addItem(4, toSection: 3)
        controller.manager.memoryStorage.addItem(2, toSection: 2)
        
        expect(self.controller.manager.tableDataSource?.numberOfSections(in:self.controller.tableView)) == 4
    }
    
    func testShouldSetSectionTitles()
    {
        controller.manager.memoryStorage.setSectionHeaderModels(["one","two"])
        let tableView = self.controller.tableView
        expect(self.controller.manager.tableDataSource?.tableView(tableView!, titleForHeaderInSection: 0)) == "one"
        expect(self.controller.manager.tableDataSource?.tableView(tableView!, titleForHeaderInSection: 1)) == "two"
    }
    
    func testSHouldSetSectionFooterTitles()
    {
        controller.manager.memoryStorage.setSectionFooterModels(["one","two"])
        let tableView = self.controller.tableView
        expect(self.controller.manager.tableDataSource?.tableView(tableView!, titleForFooterInSection: 0)) == "one"
        expect(self.controller.manager.tableDataSource?.tableView(tableView!, titleForFooterInSection: 1)) == "two"
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
        
        expect(self.controller.manager.memoryStorage.items(inSection: 0)?.count) == 2
    }
    
    func testShouldInsertTableItem()
    {
        controller.manager.memoryStorage.addItems([2,4,6], toSection: 0)
        try! controller.manager.memoryStorage.insertItem(1, to: indexPath(2, 0))
        
        expect(self.controller.manager.memoryStorage.items(inSection: 0)?.count) == 4
        expect(self.controller.verifyItem(1, atIndexPath: indexPath(2, 0))) == true
        expect(self.controller.verifyItem(6, atIndexPath: indexPath(3, 0))) == true
    }
    
    func testReplaceItem()
    {
        controller.manager.memoryStorage.addItems([1,3], toSection: 0)
        controller.manager.memoryStorage.addItems([4,6], toSection: 1)
        try! controller.manager.memoryStorage.replaceItem(3, with: 2)
        try! controller.manager.memoryStorage.replaceItem(4, with: 5)
        
        expect(self.controller.manager.memoryStorage.items(inSection: 0)?.count) == 2
        expect(self.controller.manager.memoryStorage.items(inSection: 1)?.count) == 2
        expect(self.controller.verifyItem(2, atIndexPath: indexPath(1, 0))) == true
        expect(self.controller.verifyItem(5, atIndexPath: indexPath(0, 1))) == true
    }
    
    func testRemoveItem()
    {
        controller.manager.memoryStorage.addItems([1,3,2,4], toSection: 0)
        controller.manager.memoryStorage.removeItems([1,4,3,5])
        
        expect(self.controller.manager.memoryStorage.items(inSection: 0)?.count) == 1
        expect(self.controller.verifyItem(2, atIndexPath: indexPath(0, 0))) == true
    }
    
    func testRemoveItems()
    {
        controller.manager.memoryStorage.addItems([1,2,3], toSection: 0)
        controller.manager.memoryStorage.removeAllItems()
        
        expect(self.controller.manager.memoryStorage.items(inSection: 0)?.count) == 0
    }
    
    func testMovingItems()
    {
        controller.manager.memoryStorage.addItems([1,2,3], toSection: 0)
        controller.manager.memoryStorage.moveItem(at: indexPath(0, 0), to: indexPath(2, 0))
        
        expect(self.controller.verifySection([2,3,1], withSectionNumber: 0)) == true
    }
    
    func testShouldNotCrashWhenMovingToBadRow()
    {
        controller.manager.memoryStorage.addItem([1,2,3], toSection: 0)
        
        controller.manager.memoryStorage.moveItem(at: indexPath(0, 0), to: indexPath(2, 1))
    }
    
    func testShouldNotCrashWhenMovingFromBadRow()
    {
        controller.manager.memoryStorage.addItem([1,2,3], toSection: 0)
        controller.manager.memoryStorage.moveItem(at: indexPath(0, 1), to: indexPath(0, 0))
    }
    
    func testShouldMoveSections()
    {
        controller.manager.memoryStorage.addItem(1, toSection: 0)
        controller.manager.memoryStorage.addItem(2, toSection: 1)
        controller.manager.memoryStorage.addItem(3, toSection: 2)
        
        controller.manager.memoryStorage.moveSection(0, toSection: 1)
        
        expect(self.controller.verifySection([2], withSectionNumber: 0)) == true
        expect(self.controller.verifySection([1], withSectionNumber: 1)) == true
        expect(self.controller.verifySection([3], withSectionNumber: 2)) == true
    }
    
    func testShouldDeleteSections()
    {
        controller.manager.memoryStorage.addItem(0, toSection: 0)
        controller.manager.memoryStorage.addItem(1, toSection: 1)
        controller.manager.memoryStorage.addItem(2, toSection: 2)
        
        controller.manager.memoryStorage.deleteSections(IndexSet(integer: 1))
        
        expect(self.controller.manager.memoryStorage.sections.count) == 2
        expect(self.controller.verifySection([2], withSectionNumber: 1)).to(beTruthy())
    }
    
    func testShouldShowTitlesOnEmptySection()
    {
        controller.manager.memoryStorage.setSectionHeaderModels(["Foo"])
        controller.manager.configuration.displayHeaderOnEmptySection = false
        expect(self.controller.manager.tableDataSource?.tableView(self.controller.tableView, titleForHeaderInSection: 0)).to(beNil())
    }
    
    func testShouldShowTitleOnEmptySectionFooter()
    {
        controller.manager.memoryStorage.setSectionFooterModels(["Foo"])
        controller.manager.configuration.displayFooterOnEmptySection = false
        expect(self.controller.manager.tableDataSource?.tableView(self.controller.tableView, titleForFooterInSection: 0)).to(beNil())
    }
    
    func testShouldShowViewHeaderOnEmptySEction()
    {
        controller.manager.registerHeader(NibView.self)
        controller.manager.configuration.displayHeaderOnEmptySection = false
        controller.manager.memoryStorage.setSectionHeaderModels([1])
        expect(self.controller.manager.tableDelegate?.tableView(self.controller.tableView, viewForHeaderInSection: 0)).to(beNil())
    }
    
    func testShouldShowViewFooterOnEmptySection()
    {
        controller.manager.registerFooter(NibView.self)
        controller.manager.configuration.displayFooterOnEmptySection = false
        controller.manager.memoryStorage.setSectionFooterModels([1])
        expect(self.controller.manager.tableDelegate?.tableView(self.controller.tableView, viewForFooterInSection: 0)).to(beNil())
    }
    
    func testSupplementaryKindsShouldBeSet()
    {
        expect(self.controller.manager.memoryStorage.supplementaryHeaderKind) == DTTableViewElementSectionHeader
        expect(self.controller.manager.memoryStorage.supplementaryFooterKind) == DTTableViewElementSectionFooter
    }
    
    func testHeaderViewShouldBeCreated()
    {
        controller.manager.registerHeader(NibHeaderFooterView.self)
        controller.manager.memoryStorage.setSectionHeaderModels([1])
        expect(self.controller.manager.tableDelegate?.tableView(self.controller.tableView, viewForHeaderInSection: 0)).to(beAKindOf(NibHeaderFooterView.self))
    }
    
    func testFooterViewShouldBeCreated()
    {
        controller.manager.registerFooter(NibHeaderFooterView.self)
        controller.manager.memoryStorage.setSectionFooterModels([1])
        expect(self.controller.manager.tableDelegate?.tableView(self.controller.tableView, viewForFooterInSection: 0)).to(beAKindOf(NibHeaderFooterView.self))
    }
    
    func testHeaderViewShouldBeCreatedFromXib()
    {
        controller.manager.registerNibNamed("NibHeaderFooterView", forHeader: NibHeaderFooterView.self)
        controller.manager.memoryStorage.setSectionHeaderModels([1])
        expect(self.controller.manager.tableDelegate?.tableView(self.controller.tableView, viewForHeaderInSection: 0)).to(beAKindOf(NibHeaderFooterView.self))
    }
    
    func testFooterViewShouldBeCreatedFromXib()
    {
        controller.manager.registerNibNamed("NibHeaderFooterView", forFooter: NibHeaderFooterView.self)
        controller.manager.memoryStorage.setSectionFooterModels([1])
        expect(self.controller.manager.tableDelegate?.tableView(self.controller.tableView, viewForFooterInSection: 0)).to(beAKindOf(NibHeaderFooterView.self))
    }

    func testTableHeaderModel() {
        controller.manager.memoryStorage.addItem(4)
        controller.manager.memoryStorage.setSectionHeaderModels(["1"])
        expect(self.controller.manager.memoryStorage.section(atIndex: 0)?.tableHeaderModel as? String) == "1"
        
        controller.manager.memoryStorage.section(atIndex: 0)?.tableHeaderModel = "2"
        
        expect(self.controller.manager.memoryStorage.section(atIndex: 0)?.tableHeaderModel as? String) == "2"
    }
    
    func testTableFooterModel() {
        controller.manager.memoryStorage.addItem(4)
        controller.manager.memoryStorage.setSectionFooterModels(["1"])
        expect(self.controller.manager.memoryStorage.section(atIndex: 0)?.tableFooterModel as? String) == "1"
        
        controller.manager.memoryStorage.section(atIndex: 0)?.tableFooterModel = "2"
        
        expect(self.controller.manager.memoryStorage.section(atIndex: 0)?.tableFooterModel as? String) == "2"
    }
    
    func testNilHeaderViewWithStyleTitle() {
        controller.manager.memoryStorage.setSectionHeaderModels(["Foo"])
        expect(self.controller.manager.tableDelegate?.tableView(self.controller.tableView, viewForHeaderInSection: 0)).to(beNil())
    }
    
    func testNilFooterViewWithStyleTitle() {
        controller.manager.memoryStorage.setSectionFooterModels(["Foo"])
        expect(self.controller.manager.tableDelegate?.tableView(self.controller.tableView, viewForFooterInSection: 0)).to(beNil())
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
}
